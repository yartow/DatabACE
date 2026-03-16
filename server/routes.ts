import type { Express } from "express";
import { createServer, type Server } from "http";
import { storage } from "./storage";
import { setupAuth, registerAuthRoutes, isAuthenticated } from "./replit_integrations/auth";
import { insertStudentSchema, insertEnrollmentSchema, insertPersonnelSchema, insertFamilySchema, insertParentSchema, insertSupplementaryActivitySchema, insertCourseSchema, insertPaceCourseSchema, insertPaceSchema, insertPaceVersionSchema, insertInventorySchema } from "@shared/schema";
import multer from "multer";
import crypto from "crypto";

const upload = multer({ storage: multer.memoryStorage() });

type ImportSessionRow = { studentId: number; courseId: number; number: string; dateStarted: string | null; dateEnded: string | null; grade: number | null; remarks: string | null };
type ImportConflict = { excelRow: ImportSessionRow; dbId: number };
type ImportSession = { newRows: ImportSessionRow[]; conflicts: ImportConflict[]; skippedIdentical: number; createdAt: number };
const importSessions = new Map<string, ImportSession>();

setInterval(() => {
  const now = Date.now();
  for (const [key, session] of importSessions) {
    if (now - session.createdAt > 30 * 60 * 1000) importSessions.delete(key);
  }
}, 5 * 60 * 1000);

export async function registerRoutes(
  httpServer: Server,
  app: Express
): Promise<Server> {
  await setupAuth(app);
  registerAuthRoutes(app);

  app.get("/api/profile", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    res.json(profile || null);
  });

  app.post("/api/profile", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const existing = await storage.getUserProfile(userId);
    if (existing) {
      return res.status(400).json({ message: "Profile already exists. Use an invitation link to create a new account." });
    }
    return res.status(403).json({ message: "Account creation requires an invitation. Please contact your school administrator." });
  });

  app.get("/api/students", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (profile?.role === "parent") {
      if (!profile.familyId) return res.json([]);
      const allStudents = await storage.getStudents();
      return res.json(allStudents.filter(s => s.familyId === profile.familyId));
    }
    const allStudents = await storage.getStudents();
    res.json(allStudents);
  });

  app.get("/api/students/:id", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    const student = await storage.getStudent(parseInt(req.params.id));
    if (!student) return res.status(404).json({ message: "Not found" });
    if (profile?.role === "parent" && student.familyId !== profile.familyId) {
      return res.status(403).json({ message: "Forbidden" });
    }
    res.json(student);
  });

  app.post("/api/students", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertStudentSchema.safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ message: "Invalid data", errors: parsed.error.flatten() });
    const student = await storage.createStudent(parsed.data);
    res.json(student);
  });

  app.patch("/api/students/:id", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertStudentSchema.partial().safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ message: "Invalid data", errors: parsed.error.flatten() });
    const student = await storage.updateStudent(parseInt(req.params.id), parsed.data);
    if (!student) return res.status(404).json({ message: "Student not found" });
    res.json(student);
  });

  app.delete("/api/students/:id", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    await storage.deleteStudent(parseInt(req.params.id));
    res.json({ success: true });
  });

  app.get("/api/courses", isAuthenticated, async (req, res) => {
    const c = await storage.getCourses();
    res.json(c);
  });

  app.get("/api/courses/template", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const type = (req.query.type as string) || "courses";
    try {
      const XLSX = await import("xlsx");
      const wb = XLSX.utils.book_new();
      if (type === "pace-courses") {
        const ws = XLSX.utils.aoa_to_sheet([
          ["id", "paceId", "courseId", "number", "alias"],
          [1, 1, 1, "1001", null],
        ]);
        ws["!cols"] = [8,8,8,10,8].map(w => ({ wch: w }));
        XLSX.utils.book_append_sheet(wb, ws, "PaceCourses");
        const buf = XLSX.write(wb, { type: "buffer", bookType: "xlsx" });
        res.setHeader("Content-Disposition", "attachment; filename=pace_courses_template.xlsx");
        res.setHeader("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        return res.send(Buffer.from(buf));
      }
      const allCourses = await storage.getCourses();
      const rows = allCourses.map(c => [c.id, c.aceAlias, c.icceAlias, c.icceId, c.certificateName, c.level, c.subjectId, c.subjectGroupId, c.courseType, c.passThreshold != null ? Math.round(c.passThreshold * 100) / 100 : null, c.credits ?? null, c.remarks]);
      const ws = XLSX.utils.aoa_to_sheet([
        ["id", "aceAlias", "icceAlias", "icceId", "certificateName", "level", "subjectId", "subjectGroupId", "courseType", "passThreshold", "credits", "remarks"],
        ...rows,
      ]);
      ws["!cols"] = [8,16,24,12,24,8,10,12,12,14,10,30].map(w => ({ wch: w }));
      XLSX.utils.book_append_sheet(wb, ws, "Courses");
      const buf = XLSX.write(wb, { type: "buffer", bookType: "xlsx" });
      res.setHeader("Content-Disposition", "attachment; filename=courses_template.xlsx");
      res.setHeader("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
      res.send(Buffer.from(buf));
    } catch (error: any) {
      res.status(500).json({ message: "Failed to generate template: " + error.message });
    }
  });

  app.get("/api/courses/:id", isAuthenticated, async (req, res) => {
    const c = await storage.getCourse(parseInt(req.params.id));
    if (!c) return res.status(404).json({ message: "Not found" });
    res.json(c);
  });

  app.patch("/api/courses/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertCourseSchema.partial().safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ message: "Invalid data", errors: parsed.error.flatten() });
    const result = await storage.updateCourse(parseInt(req.params.id), parsed.data);
    if (!result) return res.status(404).json({ message: "Not found" });
    res.json(result);
  });

  app.get("/api/paces", isAuthenticated, async (req, res) => {
    const p = await storage.getPaces();
    res.json(p);
  });

  app.patch("/api/paces/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertPaceSchema.partial().safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ message: "Invalid data", errors: parsed.error.flatten() });
    const result = await storage.updatePace(parseInt(req.params.id), parsed.data);
    if (!result) return res.status(404).json({ message: "Not found" });
    res.json(result);
  });

  app.get("/api/pace-courses", isAuthenticated, async (req: any, res) => {
    const { paceId, courseId } = req.query;
    if (paceId) {
      return res.json(await storage.getPaceCoursesByPace(parseInt(paceId)));
    }
    if (courseId) {
      return res.json(await storage.getPaceCoursesByCourse(parseInt(courseId)));
    }
    const pc = await storage.getPaceCourses();
    res.json(pc);
  });

  app.patch("/api/pace-courses/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertPaceCourseSchema.partial().safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ message: "Invalid data", errors: parsed.error.flatten() });
    const result = await storage.updatePaceCourse(parseInt(req.params.id), parsed.data);
    if (!result) return res.status(404).json({ message: "Not found" });
    res.json(result);
  });

  app.delete("/api/pace-courses/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    await storage.deletePaceCourse(parseInt(req.params.id));
    res.json({ ok: true });
  });

  app.post("/api/courses/create-with-paces", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const { paceData, ...courseData } = req.body;
    if (!Array.isArray(paceData)) return res.status(400).json({ message: "paceData must be an array" });

    const courseId = await storage.getNextCourseId();
    const course = await storage.createCourse({ ...courseData, id: courseId });

    const createdPaces = [];
    const createdPcLinks = [];
    let nextPaceId = await storage.getNextPaceId();
    let nextPcId = await storage.getNextPaceCourseId();

    for (const entry of paceData) {
      const num = parseInt(String(entry.number));
      if (isNaN(num)) continue;
      const pace = await storage.createPace({ id: nextPaceId, number: num });
      const pc = await storage.upsertPaceCourse({ id: nextPcId, paceId: nextPaceId, courseId, number: String(num) });
      createdPaces.push(pace);
      createdPcLinks.push(pc);
      nextPaceId++;
      nextPcId++;
    }

    res.json({ course, paces: createdPaces, paceCourses: createdPcLinks });
  });

  app.post("/api/courses/:courseId/paces", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const courseId = parseInt(req.params.courseId);
    const { paceData } = req.body;
    if (!Array.isArray(paceData)) return res.status(400).json({ message: "paceData must be an array" });

    const createdPaces = [];
    const createdPcLinks = [];
    let nextPaceId = await storage.getNextPaceId();
    let nextPcId = await storage.getNextPaceCourseId();
    const course = await storage.getCourse(courseId);
    if (!course) return res.status(404).json({ message: "Course not found" });

    for (const entry of paceData) {
      const num = parseInt(String(entry.number));
      if (isNaN(num)) continue;
      const pace = await storage.createPace({ id: nextPaceId, number: num });
      const pc = await storage.upsertPaceCourse({ id: nextPcId, paceId: nextPaceId, courseId, number: String(num) });
      createdPaces.push(pace);
      createdPcLinks.push(pc);
      nextPaceId++;
      nextPcId++;
    }

    res.json({ paces: createdPaces, paceCourses: createdPcLinks });
  });

  const courseImportSessions = new Map<string, {
    newCourses: any[]; conflictCourses: { excelRow: any; dbRow: any }[];
    newPcs: any[]; conflictPcs: { excelRow: any; dbRow: any }[];
    type: "courses" | "pace-courses"; skippedIdentical: number; createdAt: number;
  }>();

  setInterval(() => {
    const now = Date.now();
    for (const [key, session] of courseImportSessions) {
      if (now - session.createdAt > 30 * 60 * 1000) courseImportSessions.delete(key);
    }
  }, 5 * 60 * 1000);

  app.post("/api/courses/import", isAuthenticated, upload.single("file"), async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    if (!req.file) return res.status(400).json({ message: "No file uploaded" });
    const importType = (req.query.type as string) || "courses";

    try {
      const XLSX = await import("xlsx");
      const workbook = XLSX.read(req.file.buffer, { type: "buffer" });
      const targetSheet = importType === "pace-courses" ? "pacecourses" : "courses";
      const sheetName = workbook.SheetNames.find(n => n.toLowerCase().replace(/[^a-z]/g, "") === targetSheet) || workbook.SheetNames[0];
      const sheet = workbook.Sheets[sheetName];
      const rows: any[] = XLSX.utils.sheet_to_json(sheet);
      if (rows.length === 0) return res.status(400).json({ message: "No data rows found" });

      const sessionId = crypto.randomUUID();

      if (importType === "pace-courses") {
        const existingPcs = await storage.getPaceCourses();
        const existingPcMap = new Map(existingPcs.map(pc => [pc.id, pc]));
        const existingPaces = await storage.getPaces();
        const paceIds = new Set(existingPaces.map(p => p.id));
        const existingCourses = await storage.getCourses();
        const courseIds = new Set(existingCourses.map(c => c.id));

        const newPcs: any[] = [];
        const conflictPcs: { excelRow: any; dbRow: any }[] = [];
        let skippedIdentical = 0;
        const errors: string[] = [];

        for (let i = 0; i < rows.length; i++) {
          const row = rows[i];
          const id = parseInt(String(row.id));
          const paceId = parseInt(String(row.paceId));
          const courseId = parseInt(String(row.courseId));
          if (isNaN(id)) { errors.push(`Row ${i+2}: id is required`); continue; }
          if (isNaN(paceId) || !paceIds.has(paceId)) { errors.push(`Row ${i+2}: invalid paceId ${row.paceId}`); continue; }
          if (isNaN(courseId) || !courseIds.has(courseId)) { errors.push(`Row ${i+2}: invalid courseId ${row.courseId}`); continue; }
          const excelRow = { id, paceId, courseId, number: row.number != null ? String(row.number) : null, alias: row.alias != null ? parseInt(row.alias) : null };
          const existing = existingPcMap.get(id);
          if (!existing) { newPcs.push(excelRow); continue; }
          const changed = Object.keys(excelRow).some(k => k !== "id" && (excelRow as any)[k] !== (existing as any)[k]);
          if (!changed) { skippedIdentical++; continue; }
          conflictPcs.push({ excelRow, dbRow: existing });
        }

        courseImportSessions.set(sessionId, { newCourses: [], conflictCourses: [], newPcs, conflictPcs, type: "pace-courses", skippedIdentical, createdAt: Date.now() });
        return res.json({ sessionId, newCount: newPcs.length, conflictCount: conflictPcs.length, skippedIdentical, errors, conflicts: conflictPcs.map((c, i) => ({ index: i, excelRow: c.excelRow, dbRow: c.dbRow })) });
      }

      const existingCourses = await storage.getCourses();
      const existingCourseMap = new Map(existingCourses.map(c => [c.id, c]));
      const newCourses: any[] = [];
      const conflictCourses: { excelRow: any; dbRow: any }[] = [];
      let skippedIdentical = 0;
      const errors: string[] = [];
      const seenIds = new Set<number>();
      let skippedDuplicates = 0;

      for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        const id = parseInt(String(row.id));
        if (isNaN(id)) { errors.push(`Row ${i+2}: id is required and must be a whole number`); continue; }
        if (seenIds.has(id)) { skippedDuplicates++; continue; }
        seenIds.add(id);
        const excelRow = {
          id,
          aceAlias: row.aceAlias || null,
          icceAlias: row.icceAlias || row.course || null,
          icceId: row.icceId ? String(row.icceId).slice(0, 10) : null,
          certificateName: row.certificateName || null,
          level: row.level != null ? parseInt(row.level) : null,
          subjectId: row.subjectId != null ? parseInt(row.subjectId) : null,
          subjectGroupId: row.subjectGroupId != null ? parseInt(row.subjectGroupId) : null,
          courseType: row.courseType || null,
          passThreshold: row.passThreshold != null ? parseFloat(row.passThreshold) : null,
          credits: row.credits != null ? parseFloat(row.credits) : null,
          remarks: row.remarks ? String(row.remarks).slice(0, 3000) : null,
        };
        const existing = existingCourseMap.get(id);
        if (!existing) { newCourses.push(excelRow); continue; }
        const changed = Object.keys(excelRow).some(k => k !== "id" && (excelRow as any)[k] !== (existing as any)[k]);
        if (!changed) { skippedIdentical++; continue; }
        conflictCourses.push({ excelRow, dbRow: existing });
      }

      if (skippedDuplicates > 0) errors.push(`${skippedDuplicates} duplicate ID(s) within the file were skipped`);
      courseImportSessions.set(sessionId, { newCourses, conflictCourses, newPcs: [], conflictPcs: [], type: "courses", skippedIdentical, createdAt: Date.now() });
      res.json({ sessionId, newCount: newCourses.length, conflictCount: conflictCourses.length, skippedIdentical, errors, conflicts: conflictCourses.map((c, i) => ({ index: i, excelRow: c.excelRow, dbRow: c.dbRow })) });
    } catch (error: any) {
      res.status(400).json({ message: "Failed to parse file: " + error.message });
    }
  });

  app.post("/api/courses/import/resolve", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const { sessionId, choices, overrideAll } = req.body;
    if (!sessionId) return res.status(400).json({ message: "sessionId required" });
    const session = courseImportSessions.get(sessionId);
    if (!session) return res.status(404).json({ message: "Import session not found or expired" });
    courseImportSessions.delete(sessionId);

    try {
      let inserted = 0; let updated = 0;
      if (session.type === "pace-courses") {
        for (const row of session.newPcs) await storage.upsertPaceCourse(row) && inserted++;
        const resolvedChoices = overrideAll ? session.conflictPcs.map(() => "excel") : (choices || []);
        for (let i = 0; i < session.conflictPcs.length; i++) {
          if (resolvedChoices[i] === "excel") { await storage.upsertPaceCourse(session.conflictPcs[i].excelRow); updated++; }
        }
      } else {
        for (const row of session.newCourses) { await storage.upsertCourse(row); inserted++; }
        const resolvedChoices = overrideAll ? session.conflictCourses.map(() => "excel") : (choices || []);
        for (let i = 0; i < session.conflictCourses.length; i++) {
          if (resolvedChoices[i] === "excel") { await storage.upsertCourse(session.conflictCourses[i].excelRow); updated++; }
        }
      }
      res.json({ status: "done", inserted, updated, skipped: session.skippedIdentical });
    } catch (error: any) {
      res.status(400).json({ message: "Failed to apply: " + error.message });
    }
  });

  app.get("/api/pace-versions", isAuthenticated, async (_req: any, res) => {
    res.json(await storage.getPaceVersions());
  });

  app.post("/api/pace-versions", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertPaceVersionSchema.safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ message: "Invalid data", errors: parsed.error.flatten() });
    res.json(await storage.createPaceVersion(parsed.data));
  });

  app.patch("/api/pace-versions/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertPaceVersionSchema.partial().safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ message: "Invalid data", errors: parsed.error.flatten() });
    const result = await storage.updatePaceVersion(parseInt(req.params.id), parsed.data);
    if (!result) return res.status(404).json({ message: "Not found" });
    res.json(result);
  });

  app.delete("/api/pace-versions/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    await storage.deletePaceVersion(parseInt(req.params.id));
    res.json({ success: true });
  });

  app.get("/api/order-materials", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const term = parseInt(req.query.term as string);
    if (isNaN(term) || term < 1 || term > 5) return res.status(400).json({ message: "Invalid term (1–5 required)" });
    const yearTerm = req.query.yearTerm as string | undefined;
    res.json(await storage.getOrderMaterials(term, yearTerm || undefined));
  });

  app.get("/api/order-lists", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    res.json(await storage.getOrderLists());
  });

  app.get("/api/order-lists/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const result = await storage.getOrderListWithItems(parseInt(req.params.id));
    if (!result) return res.status(404).json({ message: "Order list not found" });
    res.json(result);
  });

  app.post("/api/order-lists", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const { name, term, yearTerm, items } = req.body;
    if (!name || !Array.isArray(items)) return res.status(400).json({ message: "name and items[] required" });
    const list = await storage.createOrderList(
      { name, term: term ?? null, yearTerm: yearTerm ?? null },
      items.map((it: any) => ({
        orderListId: 0,
        paceId: it.paceId ?? null,
        courseId: it.courseId ?? null,
        enrollmentNumber: it.enrollmentNumber ?? null,
        studentId: it.studentId,
        enrollmentId: it.enrollmentId ?? null,
        quantity: it.quantity ?? 1,
        initiallyToOrder: it.initiallyToOrder ?? null,
        fromInventory: it.fromInventory ?? null,
        finalToOrder: it.finalToOrder ?? null,
        delivered: false,
      })),
    );
    res.json(list);
  });

  app.patch("/api/order-lists/:listId/items/:itemId", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const listId = parseInt(req.params.listId);
    const itemId = parseInt(req.params.itemId);
    const existing = await storage.getOrderListItem(itemId);
    if (!existing) return res.status(404).json({ message: "Item not found" });
    if (existing.orderListId !== listId) return res.status(403).json({ message: "Item does not belong to this list" });
    const { delivered } = req.body;
    const item = await storage.updateOrderListItem(itemId, { delivered: !!delivered });
    res.json(item);
  });

  app.post("/api/order-lists/:id/process-delivery", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const count = await storage.processDelivery(parseInt(req.params.id));
    res.json({ processed: count });
  });

  app.get("/api/inventory", isAuthenticated, async (_req: any, res) => {
    res.json(await storage.getInventoryRich());
  });

  app.post("/api/inventory", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const { paceVersionsId, studentId, numberInPossession } = req.body;
    if (!paceVersionsId || !studentId) return res.status(400).json({ message: "paceVersionsId and studentId required" });
    const inv = await storage.upsertInventoryEntry(parseInt(paceVersionsId), parseInt(studentId), parseInt(numberInPossession) || 0);
    res.json(inv);
  });

  app.patch("/api/inventory/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertInventorySchema.partial().safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ message: "Invalid data", errors: parsed.error.flatten() });
    const result = await storage.updateInventoryEntry(parseInt(req.params.id), parsed.data);
    if (!result) return res.status(404).json({ message: "Not found" });
    res.json(result);
  });

  app.delete("/api/inventory/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    await storage.deleteInventoryEntry(parseInt(req.params.id));
    res.json({ success: true });
  });

  const inventoryImportSessions = new Map<string, {
    newRows: any[]; conflicts: { excelRow: any; dbRow: any }[]; skippedIdentical: number; createdAt: number;
  }>();

  setInterval(() => {
    const now = Date.now();
    for (const [key, session] of inventoryImportSessions) {
      if (now - session.createdAt > 30 * 60 * 1000) inventoryImportSessions.delete(key);
    }
  }, 5 * 60 * 1000);

  app.get("/api/inventory/template", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    try {
      const XLSX = await import("xlsx");
      const wb = XLSX.utils.book_new();

      const [allPvs, allPaces, invRows] = await Promise.all([
        storage.getPaceVersions(),
        storage.getPaces(),
        storage.getInventoryRich(),
      ]);
      const paceNumberMap = new Map(allPaces.map(p => [p.id, p.number]));
      const INV_NAMES: Record<number, string> = { 9996: "Inventory Kindergarten", 9997: "Inventory ABCs", 9998: "Inventory Juniors", 9999: "Inventory Seniors" };

      // ── Sheet 1: PaceVersions ──
      const pvDataRows = allPvs.map(pv => [pv.id, pv.paceId, paceNumberMap.get(pv.paceId) ?? null, pv.yearRevised, pv.type, pv.edition]);
      const pvWs = XLSX.utils.aoa_to_sheet([
        ["id", "paceId", "paceNumber (info)", "yearRevised", "type", "edition"],
        ...pvDataRows,
      ]);
      pvWs["!cols"] = [8, 8, 16, 12, 12, 10].map(w => ({ wch: w }));
      XLSX.utils.book_append_sheet(wb, pvWs, "PaceVersions");

      // ── Sheet 2: Inventory ──
      const seen = new Set<string>();
      const invDataRows: any[][] = [];
      for (const r of invRows) {
        const key = `${r.paceVersionId}-${r.studentId}`;
        if (seen.has(key)) continue;
        seen.add(key);
        const name = INV_NAMES[r.studentId] ?? `${r.studentCallName} ${r.studentSurname}`.trim();
        invDataRows.push([r.paceVersionId, r.studentId, name, r.numberInPossession]);
      }
      const invWs = XLSX.utils.aoa_to_sheet([
        ["paceVersionsId", "studentId", "studentName (info)", "numberInPossession"],
        ...invDataRows,
      ]);
      invWs["!cols"] = [16, 12, 26, 20].map(w => ({ wch: w }));
      XLSX.utils.book_append_sheet(wb, invWs, "Inventory");

      // ── Sheet 3: Instructions ──
      const instrWs = XLSX.utils.aoa_to_sheet([
        ["Inventory & PaceVersions Import Template – Instructions"],
        [""],
        ["Sheet: PaceVersions"],
        ["Column", "Required", "Description"],
        ["id", "No (leave empty for new rows)", "Existing PaceVersion ID. If filled and found → update; if empty → insert new."],
        ["paceId", "Yes", "PACE ID (must exist in paces table)"],
        ["paceNumber (info)", "No", "Read-only reference column – not imported"],
        ["yearRevised", "No", "Year the PACE was revised (number)"],
        ["type", "No", "One of: PACE, Score Key, Material"],
        ["edition", "No", "Edition number (integer)"],
        [""],
        ["Sheet: Inventory"],
        ["Column", "Required", "Description"],
        ["paceVersionsId", "Yes", "PaceVersion ID (must exist in pace_versions table)"],
        ["studentId", "Yes", "Student ID (use 9996–9999 for inventory storage locations)"],
        ["studentName (info)", "No", "Read-only reference column – not imported"],
        ["numberInPossession", "Yes", "Number of copies"],
        [""],
        ["Inventory location IDs:"],
        ["9996", "Inventory Kindergarten"],
        ["9997", "Inventory ABCs"],
        ["9998", "Inventory Juniors"],
        ["9999", "Inventory Seniors"],
      ]);
      instrWs["!cols"] = [{ wch: 24 }, { wch: 34 }, { wch: 60 }];
      XLSX.utils.book_append_sheet(wb, instrWs, "Instructions");

      const buf = XLSX.write(wb, { type: "buffer", bookType: "xlsx" });
      res.setHeader("Content-Disposition", "attachment; filename=inventory_template.xlsx");
      res.setHeader("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
      res.send(Buffer.from(buf));
    } catch (error: any) {
      res.status(500).json({ message: "Failed to generate template: " + error.message });
    }
  });

  app.post("/api/inventory/import", isAuthenticated, upload.single("file"), async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    if (!req.file) return res.status(400).json({ message: "No file uploaded" });
    try {
      const XLSX = await import("xlsx");
      const workbook = XLSX.read(req.file.buffer, { type: "buffer" });

      const findSheet = (name: string) => {
        const key = workbook.SheetNames.find(n => n.toLowerCase().replace(/[^a-z]/g, "") === name);
        return key ? workbook.Sheets[key] : null;
      };

      // ── Process PaceVersions sheet (direct upsert) ──
      let pvInserted = 0; let pvUpdated = 0;
      const pvErrors: string[] = [];
      const pvSheet = findSheet("paceversions");
      if (pvSheet) {
        const pvRows: any[] = XLSX.utils.sheet_to_json(pvSheet);
        const allPvsForImport = await storage.getPaceVersions();
        const pvMapForImport = new Map(allPvsForImport.map(pv => [pv.id, pv]));
        const allPacesForImport = await storage.getPaces();
        const paceIdsForImport = new Set(allPacesForImport.map(p => p.id));
        const VALID_TYPES = ["PACE", "Score Key", "Material"];
        for (let i = 0; i < pvRows.length; i++) {
          const row = pvRows[i];
          const paceId = row.paceId != null ? parseInt(String(row.paceId)) : NaN;
          if (isNaN(paceId) || !paceIdsForImport.has(paceId)) { pvErrors.push(`PaceVersions row ${i + 2}: invalid paceId`); continue; }
          const typeVal = row.type ? String(row.type).trim() : null;
          if (typeVal && !VALID_TYPES.includes(typeVal)) { pvErrors.push(`PaceVersions row ${i + 2}: type must be one of PACE, Score Key, Material`); continue; }
          const data = {
            paceId,
            yearRevised: row.yearRevised != null ? parseInt(String(row.yearRevised)) : null,
            type: (typeVal as any) || null,
            edition: row.edition != null ? parseInt(String(row.edition)) : null,
          };
          const existingId = row.id != null ? parseInt(String(row.id)) : NaN;
          if (!isNaN(existingId) && pvMapForImport.has(existingId)) {
            await storage.updatePaceVersion(existingId, data);
            pvUpdated++;
          } else {
            await storage.createPaceVersion(data);
            pvInserted++;
          }
        }
      }

      // ── Process Inventory sheet (session-based) ──
      const invSheet = findSheet("inventory") || workbook.Sheets[workbook.SheetNames[0]];
      const rows: any[] = XLSX.utils.sheet_to_json(invSheet);

      const allPvs = await storage.getPaceVersions();
      const pvIds = new Set(allPvs.map(pv => pv.id));
      const allStudents = await storage.getStudents();
      const studentIds = new Set(allStudents.map(s => s.id));
      const existingInv = await storage.getInventoryRich();
      const existingMap = new Map(existingInv.map(r => [`${r.paceVersionId}-${r.studentId}`, r]));

      const newRows: any[] = [];
      const conflicts: { excelRow: any; dbRow: any }[] = [];
      let skippedIdentical = 0;
      const errors: string[] = [];

      for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        const paceVersionsId = parseInt(String(row.paceVersionsId));
        const studentId = parseInt(String(row.studentId));
        const numberInPossession = parseInt(String(row.numberInPossession));
        if (isNaN(paceVersionsId) || !pvIds.has(paceVersionsId)) { errors.push(`Row ${i+2}: invalid paceVersionsId`); continue; }
        if (isNaN(studentId) || !studentIds.has(studentId)) { errors.push(`Row ${i+2}: invalid studentId`); continue; }
        if (isNaN(numberInPossession)) { errors.push(`Row ${i+2}: numberInPossession must be a number`); continue; }
        const key = `${paceVersionsId}-${studentId}`;
        const existing = existingMap.get(key);
        const excelRow = { paceVersionsId, studentId, numberInPossession };
        if (!existing) { newRows.push(excelRow); continue; }
        if (existing.numberInPossession === numberInPossession) { skippedIdentical++; continue; }
        conflicts.push({ excelRow, dbRow: { paceVersionsId, studentId, numberInPossession: existing.numberInPossession, inventoryId: existing.inventoryId } });
      }

      let sessionId: string | null = null;
      if (rows.length > 0) {
        sessionId = crypto.randomUUID();
        inventoryImportSessions.set(sessionId, { newRows, conflicts, skippedIdentical, createdAt: Date.now() });
      }
      res.json({ pvInserted, pvUpdated, pvErrors, sessionId, newCount: newRows.length, conflictCount: conflicts.length, skippedIdentical, errors, conflicts: conflicts.map((c, i) => ({ index: i, excelRow: c.excelRow, dbRow: c.dbRow })) });
    } catch (error: any) {
      res.status(400).json({ message: "Failed to parse file: " + error.message });
    }
  });

  app.post("/api/inventory/import/resolve", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const { sessionId, choices, overrideAll } = req.body;
    const session = inventoryImportSessions.get(sessionId);
    if (!session) return res.status(404).json({ message: "Import session not found or expired" });
    inventoryImportSessions.delete(sessionId);
    try {
      let inserted = 0; let updated = 0;
      for (const row of session.newRows) { await storage.upsertInventoryEntry(row.paceVersionsId, row.studentId, row.numberInPossession); inserted++; }
      const resolvedChoices = overrideAll ? session.conflicts.map(() => "excel") : (choices || []);
      for (let i = 0; i < session.conflicts.length; i++) {
        if (resolvedChoices[i] === "excel") { const c = session.conflicts[i]; await storage.updateInventoryEntry(c.dbRow.inventoryId, { numberInPossession: c.excelRow.numberInPossession }); updated++; }
      }
      res.json({ status: "done", inserted, updated, skipped: session.skippedIdentical });
    } catch (error: any) {
      res.status(400).json({ message: "Failed to apply: " + error.message });
    }
  });

  app.get("/api/subjects", isAuthenticated, async (_req: any, res) => {
    const result = await storage.getSubjects();
    res.json(result);
  });

  app.get("/api/dates", isAuthenticated, async (req: any, res) => {
    const { term } = req.query;
    if (term) {
      return res.json(await storage.getDatesByTerm(parseInt(term)));
    }
    const d = await storage.getDates();
    res.json(d);
  });

  app.get("/api/dates/term-weeks", isAuthenticated, async (_req: any, res) => {
    const rows = await storage.getTermWeekCounts();
    res.json(rows);
  });

  app.get("/api/enrollments", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile) return res.status(403).json({ message: "Forbidden" });
    const { studentId } = req.query;
    if (!studentId) return res.status(400).json({ message: "studentId query parameter required" });
    const sid = parseInt(studentId);
    if (profile.role === "parent") {
      const student = await storage.getStudent(sid);
      if (!student || student.familyId !== profile.familyId) return res.status(403).json({ message: "Forbidden" });
    }
    const result = await storage.getEnrollmentsByStudent(sid);
    res.json(result);
  });

  app.post("/api/enrollments/course", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const { studentId, courseId, dateStarted, term, paces: selectedPaces } = req.body;
    if (!studentId || !courseId) return res.status(400).json({ message: "studentId and courseId are required" });
    let paceEntries: { number: string; isRepeat: boolean }[];
    if (selectedPaces && Array.isArray(selectedPaces) && selectedPaces.length > 0) {
      paceEntries = selectedPaces.map((p: any) => ({ number: String(p.number), isRepeat: !!p.isRepeat }));
    } else {
      const numbers = await storage.getPaceNumbersByCourse(courseId);
      if (numbers.length === 0) return res.status(400).json({ message: "No PACEs found for this course" });
      paceEntries = numbers.map(n => ({ number: String(n), isRepeat: false }));
    }
    const termVal = term != null ? parseInt(String(term)) : null;
    const rows = paceEntries.map(p => ({
      studentId: parseInt(studentId),
      courseId: parseInt(courseId),
      number: p.number,
      dateStarted: dateStarted || null,
      dateEnded: null,
      grade: null,
      remarks: null,
      term: termVal && !isNaN(termVal) ? termVal : null,
      isRepeat: p.isRepeat,
    }));
    const created = await storage.createEnrollments(rows);
    res.json(created);
  });

  app.patch("/api/enrollments/:id", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertEnrollmentSchema.partial().safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ message: "Invalid data", errors: parsed.error.flatten() });
    const enrollment = await storage.updateEnrollment(parseInt(req.params.id), parsed.data);
    if (!enrollment) return res.status(404).json({ message: "Not found" });
    const userSetTermManually = ("term" in parsed.data) || ("yearTerm" in parsed.data);
    if (parsed.data.dateEnded && !userSetTermManually) {
      await storage.backfillEnrollmentTerms();
      const refreshed = await storage.getEnrollment(parseInt(req.params.id));
      if (refreshed) return res.json(refreshed);
    }
    res.json(enrollment);
  });

  app.delete("/api/enrollments/course/:studentId/:courseId", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    await storage.deleteEnrollmentsByCourse(parseInt(req.params.studentId), parseInt(req.params.courseId));
    res.json({ success: true });
  });

  app.delete("/api/enrollments/:id", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    await storage.deleteEnrollment(parseInt(req.params.id));
    res.json({ success: true });
  });

  app.get("/api/personnel", isAuthenticated, async (_req: any, res) => {
    res.json(await storage.getPersonnel());
  });

  app.post("/api/personnel", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertPersonnelSchema.safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ message: "Invalid data", errors: parsed.error.flatten() });
    const validGroups = ["Kindergarten", "ABCs", "Juniors", "Seniors"];
    const validTypes = ["Supervisor", "Monitor", "Intern", "Secretary", "Board Member", "Principal"];
    if (!validGroups.includes(parsed.data.group)) return res.status(400).json({ message: "Invalid group" });
    if (!validTypes.includes(parsed.data.type)) return res.status(400).json({ message: "Invalid type" });
    res.json(await storage.createPersonnel(parsed.data));
  });

  app.patch("/api/personnel/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertPersonnelSchema.partial().safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ message: "Invalid data", errors: parsed.error.flatten() });
    const validGroups = ["Kindergarten", "ABCs", "Juniors", "Seniors"];
    const validTypes = ["Supervisor", "Monitor", "Intern", "Secretary", "Board Member", "Principal"];
    if (parsed.data.group && !validGroups.includes(parsed.data.group)) return res.status(400).json({ message: "Invalid group" });
    if (parsed.data.type && !validTypes.includes(parsed.data.type)) return res.status(400).json({ message: "Invalid type" });
    const result = await storage.updatePersonnel(parseInt(req.params.id), parsed.data);
    if (!result) return res.status(404).json({ message: "Not found" });
    res.json(result);
  });

  app.delete("/api/personnel/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    await storage.deletePersonnel(parseInt(req.params.id));
    res.json({ success: true });
  });

  app.get("/api/families", isAuthenticated, async (_req: any, res) => {
    res.json(await storage.getFamilies());
  });

  app.post("/api/families", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertFamilySchema.safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ message: "Invalid data", errors: parsed.error.flatten() });
    res.json(await storage.createFamily(parsed.data));
  });

  app.patch("/api/families/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertFamilySchema.partial().safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ message: "Invalid data", errors: parsed.error.flatten() });
    const result = await storage.updateFamily(parseInt(req.params.id), parsed.data);
    if (!result) return res.status(404).json({ message: "Not found" });
    res.json(result);
  });

  app.delete("/api/families/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    await storage.deleteFamily(parseInt(req.params.id));
    res.json({ success: true });
  });

  app.get("/api/parents", isAuthenticated, async (_req: any, res) => {
    res.json(await storage.getParents());
  });

  app.post("/api/parents", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertParentSchema.safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ message: "Invalid data", errors: parsed.error.flatten() });
    if (parsed.data.phoneNumber) parsed.data.phoneNumber = parsed.data.phoneNumber.replace(/[\s\-()]/g, "");
    res.json(await storage.createParent(parsed.data));
  });

  app.patch("/api/parents/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertParentSchema.partial().safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ message: "Invalid data", errors: parsed.error.flatten() });
    if (parsed.data.phoneNumber) parsed.data.phoneNumber = parsed.data.phoneNumber.replace(/[\s\-()]/g, "");
    const result = await storage.updateParent(parseInt(req.params.id), parsed.data);
    if (!result) return res.status(404).json({ message: "Not found" });
    res.json(result);
  });

  app.delete("/api/parents/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    await storage.deleteParent(parseInt(req.params.id));
    res.json({ success: true });
  });

  app.get("/api/dashboard/stats", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    const allStudents = await storage.getStudents();
    const allCourses = await storage.getCourses();
    const allPaces = await storage.getPaces();
    const allPaceCourses = await storage.getPaceCourses();

    const studentCount = profile?.role === "parent"
      ? (profile.familyId ? allStudents.filter(s => s.familyId === profile.familyId).length : 0)
      : allStudents.length;

    res.json({
      totalStudents: studentCount,
      totalCourses: allCourses.length,
      totalPaces: allPaces.length,
      totalPaceCourses: allPaceCourses.length,
    });
  });

  app.get("/api/enrollments/template", isAuthenticated, async (_req: any, res) => {
    try {
      const XLSX = await import("xlsx");
      const wb = XLSX.utils.book_new();
      const headers = [["studentId", "courseId", "number", "dateStarted", "dateEnded", "grade", "remarks"]];
      const example = [[1, 1, 1001, "2025-09-01", "2025-10-15", 85, "Good work"]];
      const ws = XLSX.utils.aoa_to_sheet([...headers, ...example]);
      ws["!cols"] = [{ wch: 12 }, { wch: 12 }, { wch: 12 }, { wch: 14 }, { wch: 14 }, { wch: 8 }, { wch: 30 }];
      XLSX.utils.book_append_sheet(wb, ws, "Enrollments");

      const instrWs = XLSX.utils.aoa_to_sheet([
        ["Enrollment Import Template - Instructions"],
        [""],
        ["Column", "Required", "Description"],
        ["studentId", "Yes", "The student ID number"],
        ["courseId", "Yes", "The course ID number"],
        ["number", "Yes", "The PACE number (e.g. 1001, 1002...)"],
        ["dateStarted", "No", "Date format: YYYY-MM-DD"],
        ["dateEnded", "No", "Date format: YYYY-MM-DD"],
        ["grade", "No", "Numeric grade (0-100)"],
        ["remarks", "No", "Optional text remarks"],
      ]);
      instrWs["!cols"] = [{ wch: 14 }, { wch: 10 }, { wch: 50 }];
      XLSX.utils.book_append_sheet(wb, instrWs, "Instructions");

      const buf = XLSX.write(wb, { type: "buffer", bookType: "xlsx" });
      res.setHeader("Content-Disposition", "attachment; filename=enrollment_template.xlsx");
      res.setHeader("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
      res.send(Buffer.from(buf));
    } catch (error: any) {
      res.status(500).json({ message: "Failed to generate template: " + error.message });
    }
  });

  app.post("/api/enrollments/import", isAuthenticated, upload.single("file"), async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });

    if (!req.file) return res.status(400).json({ message: "No file uploaded" });

    try {
      const XLSX = await import("xlsx");
      const workbook = XLSX.read(req.file.buffer, { type: "buffer" });
      const sheetName = workbook.SheetNames.find(n => n.toLowerCase() === "enrollments") || workbook.SheetNames[0];
      if (!sheetName) return res.status(400).json({ message: "No sheets found in workbook" });

      const sheet = workbook.Sheets[sheetName];
      const rows: any[] = XLSX.utils.sheet_to_json(sheet);

      if (rows.length === 0) return res.status(400).json({ message: "No data rows found in the spreadsheet" });

      const allStudents = await storage.getStudents();
      const allCourses = await storage.getCourses();
      const studentIds = new Set(allStudents.map(s => s.id));
      const courseIds = new Set(allCourses.map(c => c.id));

      function parseExcelDate(val: any): string | null {
        if (!val) return null;
        if (typeof val === "number") {
          const d = new Date(Date.UTC(1899, 11, 30 + val));
          return d.toISOString().split("T")[0];
        }
        const s = String(val).trim();
        if (!/^\d{4}-\d{2}-\d{2}$/.test(s)) return undefined as any;
        const parts = s.split("-");
        const month = parseInt(parts[1]);
        const day = parseInt(parts[2]);
        if (month < 1 || month > 12 || day < 1 || day > 31) return undefined as any;
        return s;
      }

      function strictInt(val: any): number {
        if (typeof val === "number" && Number.isInteger(val)) return val;
        const s = String(val).trim();
        if (!/^\d+$/.test(s)) return NaN;
        return parseInt(s);
      }

      const errors: string[] = [];
      type ValidRow = { studentId: number; courseId: number; number: string; dateStarted: string | null; dateEnded: string | null; grade: number | null; remarks: string | null };
      const validRows: ValidRow[] = [];

      for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        const rowNum = i + 2;

        const studentId = strictInt(row.studentId);
        const courseId = strictInt(row.courseId);
        const number = row.number !== undefined && row.number !== null && String(row.number).trim() !== "" ? String(row.number).trim() : "";

        if (isNaN(studentId) || isNaN(courseId)) {
          errors.push(`Row ${rowNum}: studentId and courseId are required and must be whole numbers`);
          continue;
        }

        if (!number) {
          errors.push(`Row ${rowNum}: number is required`);
          continue;
        }

        if (!studentIds.has(studentId)) {
          errors.push(`Row ${rowNum}: student with ID ${studentId} does not exist`);
          continue;
        }

        if (!courseIds.has(courseId)) {
          errors.push(`Row ${rowNum}: course with ID ${courseId} does not exist`);
          continue;
        }

        const dateStarted = parseExcelDate(row.dateStarted);
        if (dateStarted === undefined) {
          errors.push(`Row ${rowNum}: invalid dateStarted format "${row.dateStarted}". Use YYYY-MM-DD`);
          continue;
        }

        const dateEnded = parseExcelDate(row.dateEnded);
        if (dateEnded === undefined) {
          errors.push(`Row ${rowNum}: invalid dateEnded format "${row.dateEnded}". Use YYYY-MM-DD`);
          continue;
        }

        let grade: number | null = null;
        if (row.grade !== undefined && row.grade !== null && row.grade !== "") {
          grade = typeof row.grade === "number" ? row.grade : parseFloat(String(row.grade).trim());
          if (isNaN(grade) || grade < 0 || grade > 100) {
            errors.push(`Row ${rowNum}: grade must be a number between 0 and 100`);
            continue;
          }
        }

        validRows.push({
          studentId,
          courseId,
          number,
          dateStarted,
          dateEnded,
          grade,
          remarks: row.remarks ? String(row.remarks) : null,
        });
      }

      if (validRows.length === 0) {
        return res.status(400).json({ message: "No valid rows to import", errors });
      }

      const existingEnrollments = await storage.getAllEnrollments();
      const existingMap = new Map<string, typeof existingEnrollments[0]>();
      existingEnrollments.forEach(e => {
        existingMap.set(`${e.studentId}-${e.courseId}-${e.number}`, e);
      });

      const newRows: ValidRow[] = [];
      const skippedIdentical: number[] = [];
      const conflictList: ImportConflict[] = [];
      const seenKeys = new Set<string>();
      const skippedDuplicates: number[] = [];

      for (let i = 0; i < validRows.length; i++) {
        const row = validRows[i];
        const key = `${row.studentId}-${row.courseId}-${row.number}`;

        if (seenKeys.has(key)) {
          skippedDuplicates.push(i);
          continue;
        }
        seenKeys.add(key);

        const existing = existingMap.get(key);

        if (!existing) {
          newRows.push(row);
        } else {
          const sameData =
            (existing.dateStarted || null) === (row.dateStarted || null) &&
            (existing.dateEnded || null) === (row.dateEnded || null) &&
            (existing.grade ?? null) === (row.grade ?? null) &&
            (existing.remarks || null) === (row.remarks || null);

          if (sameData) {
            skippedIdentical.push(i);
          } else {
            conflictList.push({ excelRow: row, dbId: existing.id });
          }
        }
      }

      if (skippedDuplicates.length > 0) {
        errors.push(`${skippedDuplicates.length} duplicate row(s) within the file were skipped`);
      }

      if (conflictList.length > 0) {
        const sessionId = crypto.randomUUID();
        importSessions.set(sessionId, {
          newRows,
          conflicts: conflictList,
          skippedIdentical: skippedIdentical.length,
          createdAt: Date.now(),
        });

        const conflictDetails = await Promise.all(conflictList.map(async c => {
          const dbRow = await storage.getEnrollment(c.dbId);
          return {
            excelRow: c.excelRow,
            dbRow: dbRow ? {
              id: dbRow.id,
              studentId: dbRow.studentId,
              courseId: dbRow.courseId,
              number: dbRow.number,
              dateStarted: dbRow.dateStarted,
              dateEnded: dbRow.dateEnded,
              grade: dbRow.grade,
              remarks: dbRow.remarks,
            } : null,
          };
        }));

        return res.json({
          status: "conflicts",
          sessionId,
          newRowCount: newRows.length,
          skippedIdentical: skippedIdentical.length,
          conflicts: conflictDetails.filter(c => c.dbRow !== null),
          errors: errors.length > 0 ? errors : undefined,
        });
      }

      let imported = 0;
      if (newRows.length > 0) {
        const created = await storage.createEnrollments(newRows);
        imported = created.length;
      }
      await storage.backfillEnrollmentTerms();

      res.json({
        status: "done",
        imported,
        skipped: skippedIdentical.length + skippedDuplicates.length + (rows.length - validRows.length),
        errors: errors.length > 0 ? errors : undefined,
      });
    } catch (error: any) {
      res.status(400).json({ message: "Failed to process import: " + error.message });
    }
  });

  app.post("/api/enrollments/import/resolve", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });

    try {
      const { sessionId, choices } = req.body;

      if (!sessionId || typeof sessionId !== "string") {
        return res.status(400).json({ message: "Missing sessionId" });
      }

      const session = importSessions.get(sessionId);
      if (!session) {
        return res.status(400).json({ message: "Import session expired or not found. Please re-upload the file." });
      }

      if (!Array.isArray(choices) || choices.length !== session.conflicts.length) {
        return res.status(400).json({ message: `Invalid choices array. Expected ${session.conflicts.length} item(s), got ${Array.isArray(choices) ? choices.length : "non-array"}.` });
      }

      importSessions.delete(sessionId);

      let imported = 0;
      let updated = 0;

      if (session.newRows.length > 0) {
        const created = await storage.createEnrollments(session.newRows);
        imported = created.length;
      }

      for (let i = 0; i < session.conflicts.length; i++) {
        const choice = choices[i];
        if (choice === "excel") {
          const conflict = session.conflicts[i];
          await storage.updateEnrollment(conflict.dbId, {
            dateStarted: conflict.excelRow.dateStarted,
            dateEnded: conflict.excelRow.dateEnded,
            grade: conflict.excelRow.grade,
            remarks: conflict.excelRow.remarks,
          });
          updated++;
        }
      }

      await storage.backfillEnrollmentTerms();
      res.json({ status: "done", imported, updated, skipped: session.skippedIdentical });
    } catch (error: any) {
      res.status(400).json({ message: "Failed to apply resolutions: " + error.message });
    }
  });

  app.get("/api/subject-groups", isAuthenticated, async (_req: any, res) => {
    res.json(await storage.getSubjectGroups());
  });

  app.get("/api/supplementary-activities", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile) return res.status(403).json({ message: "Forbidden" });
    const { studentId } = req.query;
    if (!studentId) return res.status(400).json({ message: "studentId query parameter required" });
    const sid = parseInt(studentId);
    if (profile.role === "parent") {
      const student = await storage.getStudent(sid);
      if (!student || student.familyId !== profile.familyId) return res.status(403).json({ message: "Forbidden" });
    }
    res.json(await storage.getSupplementaryActivitiesByStudent(sid));
  });

  app.post("/api/supplementary-activities", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertSupplementaryActivitySchema.safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ message: "Invalid data", errors: parsed.error.flatten() });
    res.json(await storage.createSupplementaryActivity(parsed.data));
  });

  app.patch("/api/supplementary-activities/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertSupplementaryActivitySchema.partial().safeParse(req.body);
    if (!parsed.success) return res.status(400).json({ message: "Invalid data", errors: parsed.error.flatten() });
    const result = await storage.updateSupplementaryActivity(parseInt(req.params.id), parsed.data);
    if (!result) return res.status(404).json({ message: "Not found" });
    res.json(result);
  });

  app.delete("/api/supplementary-activities/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    await storage.deleteSupplementaryActivity(parseInt(req.params.id));
    res.json({ success: true });
  });

  app.post("/api/upload/excel", isAuthenticated, upload.single("file"), async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });

    if (!req.file) return res.status(400).json({ message: "No file uploaded" });

    try {
      const XLSX = await import("xlsx");
      const workbook = XLSX.read(req.file.buffer, { type: "buffer" });
      const sheetNames = workbook.SheetNames;
      const results: Record<string, any[]> = {};

      for (const sheetName of sheetNames) {
        const sheet = workbook.Sheets[sheetName];
        const data = XLSX.utils.sheet_to_json(sheet);
        results[sheetName] = data;
      }

      res.json({
        sheets: sheetNames,
        data: results,
        rowCounts: Object.fromEntries(sheetNames.map(n => [n, results[n].length])),
      });
    } catch (error: any) {
      res.status(400).json({ message: "Failed to parse Excel file: " + error.message });
    }
  });

  app.get("/api/invitations", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher" || !profile.isAdmin) return res.status(403).json({ message: "Admin access required" });
    const all = await storage.getInvitations();
    res.json(all);
  });

  app.post("/api/invitations", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher" || !profile.isAdmin) return res.status(403).json({ message: "Admin access required" });
    const { role, familyId, email } = req.body;
    if (!role || !["teacher", "parent"].includes(role)) return res.status(400).json({ message: "Invalid role" });
    if (role === "parent" && !familyId) return res.status(400).json({ message: "Family is required for parent invitations" });
    const token = crypto.randomUUID();
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
    const inv = await storage.createInvitation({
      token,
      role,
      familyId: familyId || null,
      email: email || null,
      createdBy: req.user.claims.sub,
      expiresAt,
    });
    res.json(inv);
  });

  app.delete("/api/invitations/:id", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher" || !profile.isAdmin) return res.status(403).json({ message: "Admin access required" });
    await storage.deleteInvitation(parseInt(req.params.id));
    res.json({ success: true });
  });

  app.get("/api/invitations/redeem/:token", async (req, res) => {
    const inv = await storage.getInvitationByToken(req.params.token);
    if (!inv) return res.status(404).json({ message: "Invitation not found" });
    const expired = new Date() > inv.expiresAt;
    const family = inv.familyId ? await storage.getFamily(inv.familyId) : null;
    res.json({
      role: inv.role,
      familyId: inv.familyId,
      familyName: family ? `${family.firstName} ${family.lastName}` : null,
      email: inv.email,
      expired,
      used: !!inv.usedBy,
    });
  });

  app.post("/api/invitations/redeem/:token", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const existing = await storage.getUserProfile(userId);
    if (existing) return res.status(400).json({ message: "You already have an account" });
    const inv = await storage.getInvitationByToken(req.params.token);
    if (!inv) return res.status(404).json({ message: "Invitation not found" });
    if (inv.usedBy) return res.status(400).json({ message: "This invitation has already been used" });
    if (new Date() > inv.expiresAt) return res.status(400).json({ message: "This invitation has expired" });
    const marked = await storage.markInvitationUsed(req.params.token, userId);
    if (!marked) return res.status(400).json({ message: "This invitation has already been used" });
    const profile = await storage.createUserProfile({
      userId,
      role: inv.role,
      familyId: inv.familyId || null,
      isAdmin: false,
    });
    res.json(profile);
  });

  app.get("/api/admin/users", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher" || !profile.isAdmin) return res.status(403).json({ message: "Admin access required" });
    const users = await storage.getAllUserProfilesWithUsers();
    res.json(users);
  });

  app.patch("/api/admin/users/:userId", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher" || !profile.isAdmin) return res.status(403).json({ message: "Admin access required" });
    const targetUserId = req.params.userId;
    if (targetUserId === req.user.claims.sub) return res.status(400).json({ message: "Cannot modify your own admin status" });
    const { isAdmin } = req.body;
    if (typeof isAdmin !== "boolean") return res.status(400).json({ message: "isAdmin must be a boolean" });
    const updated = await storage.updateUserProfile(targetUserId, { isAdmin });
    if (!updated) return res.status(404).json({ message: "User not found" });
    res.json(updated);
  });

  app.delete("/api/admin/users/:userId", isAuthenticated, async (req: any, res) => {
    const profile = await storage.getUserProfile(req.user.claims.sub);
    if (!profile || profile.role !== "teacher" || !profile.isAdmin) return res.status(403).json({ message: "Admin access required" });
    const targetUserId = req.params.userId;
    if (targetUserId === req.user.claims.sub) return res.status(400).json({ message: "Cannot delete your own account" });
    await storage.deleteUserProfile(targetUserId);
    res.json({ success: true });
  });

  return httpServer;
}
