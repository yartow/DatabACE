import type { Express } from "express";
import { createServer, type Server } from "http";
import { storage } from "./storage";
import { setupAuth, registerAuthRoutes, isAuthenticated } from "./replit_integrations/auth";
import { insertStudentSchema, insertEnrollmentSchema } from "@shared/schema";
import multer from "multer";

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
    const { role, familyId } = req.body;
    if (!role || !["teacher", "parent"].includes(role)) {
      return res.status(400).json({ message: "Invalid role" });
    }
    const existing = await storage.getUserProfile(userId);
    if (existing) {
      const updated = await storage.updateUserProfile(userId, { role, familyId: familyId || null });
      return res.json(updated);
    }
    const profile = await storage.createUserProfile({ userId, role, familyId: familyId || null });
    res.json(profile);
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
    const result = await storage.getEnrollmentsByStudent(parseInt(studentId));
    res.json(result);
  });

  app.post("/api/enrollments/course", isAuthenticated, async (req: any, res) => {
    const userId = req.user.claims.sub;
    const profile = await storage.getUserProfile(userId);
    if (!profile || profile.role !== "teacher") return res.status(403).json({ message: "Forbidden" });
    const { studentId, courseId, dateStarted } = req.body;
    if (!studentId || !courseId || !dateStarted) return res.status(400).json({ message: "studentId, courseId, and dateStarted are required" });
    const numbers = await storage.getPaceNumbersByCourse(courseId);
    if (numbers.length === 0) return res.status(400).json({ message: "No PACEs found for this course" });
    const rows = numbers.map(num => ({
      studentId: parseInt(studentId),
      courseId: parseInt(courseId),
      number: num,
      dateStarted,
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

  return httpServer;
}
