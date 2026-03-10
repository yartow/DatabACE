import type { Express } from "express";
import { createServer, type Server } from "http";
import { storage } from "./storage";
import { setupAuth, registerAuthRoutes, isAuthenticated } from "./replit_integrations/auth";
import { insertStudentSchema, insertEnrollmentSchema, insertPersonnelSchema, insertFamilySchema, insertParentSchema, insertSupplementaryActivitySchema, insertCourseSchema, insertPaceCourseSchema } from "@shared/schema";
import multer from "multer";
import crypto from "crypto";

const upload = multer({ storage: multer.memoryStorage() });

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
    const allStudents = await storage.getStudents();
    res.json(allStudents);
  });

  app.get("/api/students/:id", isAuthenticated, async (req, res) => {
    const student = await storage.getStudent(parseInt(req.params.id));
    if (!student) return res.status(404).json({ message: "Not found" });
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
    const { studentId, courseId, dateStarted } = req.body;
    if (!studentId || !courseId) return res.status(400).json({ message: "studentId and courseId are required" });
    const numbers = await storage.getPaceNumbersByCourse(courseId);
    if (numbers.length === 0) return res.status(400).json({ message: "No PACEs found for this course" });
    const rows = numbers.map(num => ({
      studentId: parseInt(studentId),
      courseId: parseInt(courseId),
      number: num,
      dateStarted: dateStarted || null,
      dateEnded: null,
      grade: null,
      remarks: null,
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
    const allStudents = await storage.getStudents();
    const allCourses = await storage.getCourses();
    const allPaces = await storage.getPaces();
    const allPaceCourses = await storage.getPaceCourses();

    res.json({
      totalStudents: allStudents.length,
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
      const validRows: { studentId: number; courseId: number; number: number; dateStarted: string | null; dateEnded: string | null; grade: number | null; remarks: string | null }[] = [];

      for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        const rowNum = i + 2;

        const studentId = strictInt(row.studentId);
        const courseId = strictInt(row.courseId);
        const number = strictInt(row.number);

        if (isNaN(studentId) || isNaN(courseId) || isNaN(number)) {
          errors.push(`Row ${rowNum}: studentId, courseId, and number are required and must be whole numbers`);
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

      const created = await storage.createEnrollments(validRows);

      res.json({
        imported: created.length,
        skipped: rows.length - validRows.length,
        errors: errors.length > 0 ? errors : undefined,
      });
    } catch (error: any) {
      res.status(400).json({ message: "Failed to process import: " + error.message });
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
