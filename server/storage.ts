import {
  families, students, subjects, terms, grades, materials, studentSubjects, userProfiles,
  type Family, type Student, type Subject, type Term, type Grade, type Material,
  type StudentSubject, type UserProfile,
  type InsertFamily, type InsertStudent, type InsertSubject, type InsertTerm,
  type InsertGrade, type InsertMaterial, type InsertStudentSubject, type InsertUserProfile,
} from "@shared/schema";
import { db } from "./db";
import { eq, and } from "drizzle-orm";

export interface IStorage {
  getFamilies(): Promise<Family[]>;
  getFamily(id: number): Promise<Family | undefined>;
  createFamily(data: InsertFamily): Promise<Family>;

  getStudents(): Promise<Student[]>;
  getStudentsByFamily(familyId: number): Promise<Student[]>;
  getStudent(id: number): Promise<Student | undefined>;
  createStudent(data: InsertStudent): Promise<Student>;
  updateStudent(id: number, data: Partial<InsertStudent>): Promise<Student | undefined>;
  deleteStudent(id: number): Promise<void>;

  getSubjects(): Promise<Subject[]>;
  getSubject(id: number): Promise<Subject | undefined>;
  createSubject(data: InsertSubject): Promise<Subject>;

  getTerms(): Promise<Term[]>;
  getTerm(id: number): Promise<Term | undefined>;
  createTerm(data: InsertTerm): Promise<Term>;

  getGrades(): Promise<Grade[]>;
  getGradesByStudent(studentId: number): Promise<Grade[]>;
  getGradesByStudentAndTerm(studentId: number, termId: number): Promise<Grade[]>;
  createGrade(data: InsertGrade): Promise<Grade>;
  updateGrade(id: number, data: Partial<InsertGrade>): Promise<Grade | undefined>;
  deleteGrade(id: number): Promise<void>;

  getMaterials(): Promise<Material[]>;
  getMaterialsBySubject(subjectId: number): Promise<Material[]>;
  createMaterial(data: InsertMaterial): Promise<Material>;
  updateMaterial(id: number, data: Partial<InsertMaterial>): Promise<Material | undefined>;

  getStudentSubjects(): Promise<StudentSubject[]>;
  getStudentSubjectsByStudent(studentId: number): Promise<StudentSubject[]>;
  createStudentSubject(data: InsertStudentSubject): Promise<StudentSubject>;
  updateStudentSubject(id: number, data: Partial<InsertStudentSubject>): Promise<StudentSubject | undefined>;

  getUserProfile(userId: string): Promise<UserProfile | undefined>;
  createUserProfile(data: InsertUserProfile): Promise<UserProfile>;
  updateUserProfile(userId: string, data: Partial<InsertUserProfile>): Promise<UserProfile | undefined>;
  getAllUserProfiles(): Promise<UserProfile[]>;
}

export class DatabaseStorage implements IStorage {
  async getFamilies(): Promise<Family[]> {
    return db.select().from(families);
  }
  async getFamily(id: number): Promise<Family | undefined> {
    const [f] = await db.select().from(families).where(eq(families.id, id));
    return f;
  }
  async createFamily(data: InsertFamily): Promise<Family> {
    const [f] = await db.insert(families).values(data).returning();
    return f;
  }

  async getStudents(): Promise<Student[]> {
    return db.select().from(students);
  }
  async getStudentsByFamily(familyId: number): Promise<Student[]> {
    return db.select().from(students).where(eq(students.familyId, familyId));
  }
  async getStudent(id: number): Promise<Student | undefined> {
    const [s] = await db.select().from(students).where(eq(students.id, id));
    return s;
  }
  async createStudent(data: InsertStudent): Promise<Student> {
    const [s] = await db.insert(students).values(data).returning();
    return s;
  }
  async updateStudent(id: number, data: Partial<InsertStudent>): Promise<Student | undefined> {
    const [s] = await db.update(students).set(data).where(eq(students.id, id)).returning();
    return s;
  }
  async deleteStudent(id: number): Promise<void> {
    await db.delete(students).where(eq(students.id, id));
  }

  async getSubjects(): Promise<Subject[]> {
    return db.select().from(subjects);
  }
  async getSubject(id: number): Promise<Subject | undefined> {
    const [s] = await db.select().from(subjects).where(eq(subjects.id, id));
    return s;
  }
  async createSubject(data: InsertSubject): Promise<Subject> {
    const [s] = await db.insert(subjects).values(data).returning();
    return s;
  }

  async getTerms(): Promise<Term[]> {
    return db.select().from(terms);
  }
  async getTerm(id: number): Promise<Term | undefined> {
    const [t] = await db.select().from(terms).where(eq(terms.id, id));
    return t;
  }
  async createTerm(data: InsertTerm): Promise<Term> {
    const [t] = await db.insert(terms).values(data).returning();
    return t;
  }

  async getGrades(): Promise<Grade[]> {
    return db.select().from(grades);
  }
  async getGradesByStudent(studentId: number): Promise<Grade[]> {
    return db.select().from(grades).where(eq(grades.studentId, studentId));
  }
  async getGradesByStudentAndTerm(studentId: number, termId: number): Promise<Grade[]> {
    return db.select().from(grades).where(and(eq(grades.studentId, studentId), eq(grades.termId, termId)));
  }
  async createGrade(data: InsertGrade): Promise<Grade> {
    const [g] = await db.insert(grades).values(data).returning();
    return g;
  }
  async updateGrade(id: number, data: Partial<InsertGrade>): Promise<Grade | undefined> {
    const [g] = await db.update(grades).set(data).where(eq(grades.id, id)).returning();
    return g;
  }
  async deleteGrade(id: number): Promise<void> {
    await db.delete(grades).where(eq(grades.id, id));
  }

  async getMaterials(): Promise<Material[]> {
    return db.select().from(materials);
  }
  async getMaterialsBySubject(subjectId: number): Promise<Material[]> {
    return db.select().from(materials).where(eq(materials.subjectId, subjectId));
  }
  async createMaterial(data: InsertMaterial): Promise<Material> {
    const [m] = await db.insert(materials).values(data).returning();
    return m;
  }
  async updateMaterial(id: number, data: Partial<InsertMaterial>): Promise<Material | undefined> {
    const [m] = await db.update(materials).set(data).where(eq(materials.id, id)).returning();
    return m;
  }

  async getStudentSubjects(): Promise<StudentSubject[]> {
    return db.select().from(studentSubjects);
  }
  async getStudentSubjectsByStudent(studentId: number): Promise<StudentSubject[]> {
    return db.select().from(studentSubjects).where(eq(studentSubjects.studentId, studentId));
  }
  async createStudentSubject(data: InsertStudentSubject): Promise<StudentSubject> {
    const [ss] = await db.insert(studentSubjects).values(data).returning();
    return ss;
  }
  async updateStudentSubject(id: number, data: Partial<InsertStudentSubject>): Promise<StudentSubject | undefined> {
    const [ss] = await db.update(studentSubjects).set(data).where(eq(studentSubjects.id, id)).returning();
    return ss;
  }

  async getUserProfile(userId: string): Promise<UserProfile | undefined> {
    const [p] = await db.select().from(userProfiles).where(eq(userProfiles.userId, userId));
    return p;
  }
  async createUserProfile(data: InsertUserProfile): Promise<UserProfile> {
    const [p] = await db.insert(userProfiles).values(data).returning();
    return p;
  }
  async updateUserProfile(userId: string, data: Partial<InsertUserProfile>): Promise<UserProfile | undefined> {
    const [p] = await db.update(userProfiles).set(data).where(eq(userProfiles.userId, userId)).returning();
    return p;
  }
  async getAllUserProfiles(): Promise<UserProfile[]> {
    return db.select().from(userProfiles);
  }
}

export const storage = new DatabaseStorage();
