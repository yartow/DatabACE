import {
  students, courses, paces, paceCourses, dates, userProfiles, enrollments, subjects,
  type Student, type Course, type Pace, type PaceCourse, type DateEntry, type UserProfile, type Enrollment, type Subject,
  type InsertStudent, type InsertUserProfile, type InsertEnrollment,
} from "@shared/schema";
import { db } from "./db";
import { eq, and } from "drizzle-orm";

export interface IStorage {
  getStudents(): Promise<Student[]>;
  getStudent(id: number): Promise<Student | undefined>;
  createStudent(data: InsertStudent): Promise<Student>;
  updateStudent(id: number, data: Partial<InsertStudent>): Promise<Student | undefined>;
  deleteStudent(id: number): Promise<void>;

  getCourses(): Promise<Course[]>;
  getCourse(id: number): Promise<Course | undefined>;

  getPaces(): Promise<Pace[]>;

  getPaceCourses(): Promise<PaceCourse[]>;
  getPaceCoursesByPace(paceId: number): Promise<PaceCourse[]>;
  getPaceCoursesByCourse(courseId: number): Promise<PaceCourse[]>;

  getSubjects(): Promise<Subject[]>;

  getDates(): Promise<DateEntry[]>;
  getDatesByTerm(term: number): Promise<DateEntry[]>;

  getEnrollmentsByStudent(studentId: number): Promise<Enrollment[]>;
  getEnrollment(id: number): Promise<Enrollment | undefined>;
  createEnrollment(data: InsertEnrollment): Promise<Enrollment>;
  createEnrollments(data: InsertEnrollment[]): Promise<Enrollment[]>;
  updateEnrollment(id: number, data: Partial<InsertEnrollment>): Promise<Enrollment | undefined>;
  deleteEnrollment(id: number): Promise<void>;
  deleteEnrollmentsByCourse(studentId: number, courseId: number): Promise<void>;
  getPaceNumbersByCourse(courseId: number): Promise<number[]>;

  getUserProfile(userId: string): Promise<UserProfile | undefined>;
  createUserProfile(data: InsertUserProfile): Promise<UserProfile>;
  updateUserProfile(userId: string, data: Partial<InsertUserProfile>): Promise<UserProfile | undefined>;
  getAllUserProfiles(): Promise<UserProfile[]>;
}

export class DatabaseStorage implements IStorage {
  async getStudents(): Promise<Student[]> {
    return db.select().from(students);
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

  async getCourses(): Promise<Course[]> {
    return db.select().from(courses);
  }
  async getCourse(id: number): Promise<Course | undefined> {
    const [c] = await db.select().from(courses).where(eq(courses.id, id));
    return c;
  }

  async getPaces(): Promise<Pace[]> {
    return db.select().from(paces);
  }

  async getPaceCourses(): Promise<PaceCourse[]> {
    return db.select().from(paceCourses);
  }
  async getPaceCoursesByPace(paceId: number): Promise<PaceCourse[]> {
    return db.select().from(paceCourses).where(eq(paceCourses.paceId, paceId));
  }
  async getPaceCoursesByCourse(courseId: number): Promise<PaceCourse[]> {
    return db.select().from(paceCourses).where(eq(paceCourses.courseId, courseId));
  }

  async getSubjects(): Promise<Subject[]> {
    return db.select().from(subjects);
  }

  async getDates(): Promise<DateEntry[]> {
    return db.select().from(dates);
  }
  async getDatesByTerm(term: number): Promise<DateEntry[]> {
    return db.select().from(dates).where(eq(dates.term, term));
  }

  async getEnrollmentsByStudent(studentId: number): Promise<Enrollment[]> {
    return db.select().from(enrollments).where(eq(enrollments.studentId, studentId));
  }
  async getEnrollment(id: number): Promise<Enrollment | undefined> {
    const [e] = await db.select().from(enrollments).where(eq(enrollments.id, id));
    return e;
  }
  async createEnrollment(data: InsertEnrollment): Promise<Enrollment> {
    const [e] = await db.insert(enrollments).values(data).returning();
    return e;
  }
  async createEnrollments(data: InsertEnrollment[]): Promise<Enrollment[]> {
    if (data.length === 0) return [];
    return db.insert(enrollments).values(data).returning();
  }
  async updateEnrollment(id: number, data: Partial<InsertEnrollment>): Promise<Enrollment | undefined> {
    const [e] = await db.update(enrollments).set(data).where(eq(enrollments.id, id)).returning();
    return e;
  }
  async deleteEnrollment(id: number): Promise<void> {
    await db.delete(enrollments).where(eq(enrollments.id, id));
  }
  async deleteEnrollmentsByCourse(studentId: number, courseId: number): Promise<void> {
    await db.delete(enrollments).where(and(eq(enrollments.studentId, studentId), eq(enrollments.courseId, courseId)));
  }
  async getPaceNumbersByCourse(courseId: number): Promise<number[]> {
    const rows = await db.select({ number: paceCourses.number }).from(paceCourses).where(eq(paceCourses.courseId, courseId));
    const numbers = [...new Set(rows.map(r => r.number).filter((n): n is number => n !== null))].sort((a, b) => a - b);
    return numbers;
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
