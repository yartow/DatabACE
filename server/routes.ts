import type { Express } from "express";
import { createServer, type Server } from "http";
import { storage } from "./storage";
import { setupAuth, registerAuthRoutes, isAuthenticated } from "./replit_integrations/auth";
import multer from "multer";
import * as XLSX from "xlsx";
import { insertStudentSchema, insertSubjectSchema, insertTermSchema, insertGradeSchema, insertMaterialSchema, insertStudentSubjectSchema, insertUserProfileSchema } from "@shared/schema";

const upload = multer({ storage: multer.memoryStorage() });

async function getProfileAndStudentIds(userId: string) {
  const profile = await storage.getUserProfile(userId);
  if (!profile) return { profile: null, allowedStudentIds: [] as number[] };
  if (profile.role === "teacher") {
    const allStudents = await storage.getStudents();
    return { profile, allowedStudentIds: allStudents.map(s => s.id) };
  }
  if (profile.familyId) {
    const familyStudents = await storage.getStudentsByFamily(profile.familyId);
    return { profile, allowedStudentIds: familyStudents.map(s => s.id) };
  }
  return { profile, allowedStudentIds: [] as number[] };
}

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
    const { role, familyId } = req.body;
    if (!role || !["teacher", "parent"].includes(role)) {
      return res.status(400).json({ message: "Invalid role" });
    }
    if (role === "parent" && !familyId) {
      return res.status(400).json({ message: "Family is required for parents" });
    }
    const existing = await storage.getUserProfile(userId);
    if (existing) {
      const updated = await storage.updateUserProfile(userId, { role, familyId: familyId || null });
      return res.json(updated);
    }
    const profile = await storage.createUserProfile({ userId, role, familyId: familyId || null });
    res.json(profile);
  });

  app.get("/api/profiles", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const profiles = await storage.getAllUserProfiles();
    res.json(profiles);
  });

  app.get("/api/families", isAuthenticated, async (req, res) => {
    const fams = await storage.getFamilies();
    res.json(fams);
  });

  app.post("/api/families", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const { name } = req.body;
    if (!name || typeof name !== "string") return res.status(400).json({ message: "Name is required" });
    const family = await storage.createFamily({ name });
    res.json(family);
  });

  app.get("/api/students", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const { profile, allowedStudentIds } = await getProfileAndStudentIds(userId);
    if (!profile) return res.json([]);
    if (profile.role === "teacher") {
      return res.json(await storage.getStudents());
    }
    if (profile.familyId) {
      return res.json(await storage.getStudentsByFamily(profile.familyId));
    }
    res.json([]);
  });

  app.get("/api/students/:id", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const { profile, allowedStudentIds } = await getProfileAndStudentIds(userId);
    const studentId = parseInt(req.params.id);
    if (!profile) return res.status(403).json({ message: "Forbidden" });
    if (profile.role !== "teacher" && !allowedStudentIds.includes(studentId)) {
      return res.status(403).json({ message: "Forbidden" });
    }
    const student = await storage.getStudent(studentId);
    if (!student) return res.status(404).json({ message: "Not found" });
    res.json(student);
  });

  app.post("/api/students", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertStudentSchema.parse(req.body);
    const student = await storage.createStudent(parsed);
    res.json(student);
  });

  app.patch("/api/students/:id", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const student = await storage.updateStudent(parseInt(req.params.id), req.body);
    res.json(student);
  });

  app.delete("/api/students/:id", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    await storage.deleteStudent(parseInt(req.params.id));
    res.json({ success: true });
  });

  app.get("/api/subjects", isAuthenticated, async (req, res) => {
    const subs = await storage.getSubjects();
    res.json(subs);
  });

  app.post("/api/subjects", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertSubjectSchema.parse(req.body);
    const subject = await storage.createSubject(parsed);
    res.json(subject);
  });

  app.get("/api/terms", isAuthenticated, async (req, res) => {
    const t = await storage.getTerms();
    res.json(t);
  });

  app.post("/api/terms", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertTermSchema.parse(req.body);
    const term = await storage.createTerm(parsed);
    res.json(term);
  });

  app.get("/api/grades", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const { profile, allowedStudentIds } = await getProfileAndStudentIds(userId);
    if (!profile) return res.json([]);

    const { studentId, termId } = req.query;

    if (studentId) {
      const sid = parseInt(studentId);
      if (profile.role !== "teacher" && !allowedStudentIds.includes(sid)) {
        return res.status(403).json({ message: "Forbidden" });
      }
      if (termId) {
        return res.json(await storage.getGradesByStudentAndTerm(sid, parseInt(termId)));
      }
      return res.json(await storage.getGradesByStudent(sid));
    }

    if (profile.role === "teacher") {
      return res.json(await storage.getGrades());
    }

    const allGrades = await storage.getGrades();
    res.json(allGrades.filter(g => allowedStudentIds.includes(g.studentId)));
  });

  app.post("/api/grades", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertGradeSchema.parse(req.body);
    const grade = await storage.createGrade(parsed);
    res.json(grade);
  });

  app.patch("/api/grades/:id", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const grade = await storage.updateGrade(parseInt(req.params.id), req.body);
    res.json(grade);
  });

  app.delete("/api/grades/:id", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    await storage.deleteGrade(parseInt(req.params.id));
    res.json({ success: true });
  });

  app.get("/api/materials", isAuthenticated, async (req: any, res) => {
    const { subjectId } = req.query;
    if (subjectId) {
      const m = await storage.getMaterialsBySubject(parseInt(subjectId));
      return res.json(m);
    }
    const m = await storage.getMaterials();
    res.json(m);
  });

  app.post("/api/materials", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertMaterialSchema.parse(req.body);
    const material = await storage.createMaterial(parsed);
    res.json(material);
  });

  app.patch("/api/materials/:id", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const material = await storage.updateMaterial(parseInt(req.params.id), req.body);
    res.json(material);
  });

  app.get("/api/student-subjects", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const { profile, allowedStudentIds } = await getProfileAndStudentIds(userId);
    if (!profile) return res.json([]);

    const { studentId } = req.query;
    if (studentId) {
      const sid = parseInt(studentId);
      if (profile.role !== "teacher" && !allowedStudentIds.includes(sid)) {
        return res.status(403).json({ message: "Forbidden" });
      }
      return res.json(await storage.getStudentSubjectsByStudent(sid));
    }

    if (profile.role === "teacher") {
      return res.json(await storage.getStudentSubjects());
    }

    const allSS = await storage.getStudentSubjects();
    res.json(allSS.filter(ss => allowedStudentIds.includes(ss.studentId)));
  });

  app.post("/api/student-subjects", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const parsed = insertStudentSubjectSchema.parse(req.body);
    const ss = await storage.createStudentSubject(parsed);
    res.json(ss);
  });

  app.patch("/api/student-subjects/:id", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const ss = await storage.updateStudentSubject(parseInt(req.params.id), req.body);
    res.json(ss);
  });

  app.post("/api/upload/excel", isAuthenticated, upload.single("file"), async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });

    if (!req.file) return res.status(400).json({ message: "No file uploaded" });

    try {
      const workbook = XLSX.read(req.file.buffer, { type: "buffer" });
      const sheetNames = workbook.SheetNames;
      const results: Record<string, any[]> = {};

      for (const sheetName of sheetNames) {
        const sheet = workbook.Sheets[sheetName];
        const data = XLSX.utils.sheet_to_json(sheet);
        results[sheetName] = data;
      }

      res.json({ sheets: sheetNames, data: results, rowCounts: Object.fromEntries(sheetNames.map(n => [n, results[n].length])) });
    } catch (error: any) {
      res.status(400).json({ message: "Failed to parse Excel file: " + error.message });
    }
  });

  app.post("/api/import/grades", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });

    const { rows } = req.body;
    if (!Array.isArray(rows)) return res.status(400).json({ message: "rows must be an array" });

    let imported = 0;
    for (const row of rows) {
      try {
        const parsed = insertGradeSchema.parse({
          studentId: parseInt(row.studentId),
          subjectId: parseInt(row.subjectId),
          termId: parseInt(row.termId),
          score: parseInt(row.score),
          maxScore: row.maxScore ? parseInt(row.maxScore) : 100,
          comment: row.comment || null,
        });
        await storage.createGrade(parsed);
        imported++;
      } catch (e) {
        console.error("Failed to import grade row:", e);
      }
    }

    res.json({ imported, total: rows.length });
  });

  app.get("/api/dashboard/stats", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const { profile, allowedStudentIds } = await getProfileAndStudentIds(userId);

    const allStudents = profile?.role === "teacher"
      ? await storage.getStudents()
      : profile?.familyId
        ? await storage.getStudentsByFamily(profile.familyId)
        : [];
    const allSubjects = await storage.getSubjects();
    const allTerms = await storage.getTerms();
    const allGrades = await storage.getGrades();
    const relevantGrades = profile?.role === "teacher"
      ? allGrades
      : allGrades.filter(g => allowedStudentIds.includes(g.studentId));

    res.json({
      totalStudents: allStudents.length,
      totalSubjects: allSubjects.length,
      totalTerms: allTerms.length,
      totalGrades: relevantGrades.length,
    });
  });

  return httpServer;
}
