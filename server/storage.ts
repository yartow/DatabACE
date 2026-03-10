import {
  students, courses, paces, paceCourses, dates, userProfiles, enrollments, subjects,
  personnel, families, parents, supplementaryActivities, subjectGroups, invitations,
  type Student, type Course, type Pace, type PaceCourse, type DateEntry, type UserProfile, type Enrollment, type Subject,
  type Personnel, type Family, type Parent, type SupplementaryActivity, type SubjectGroup,
  type Invitation, type InsertInvitation,
  type InsertStudent, type InsertUserProfile, type InsertEnrollment,
  type InsertPersonnel, type InsertFamily, type InsertParent, type InsertSupplementaryActivity,
  type InsertCourse, type InsertPaceCourse,
} from "@shared/schema";
import { db } from "./db";
import { eq, and, isNull } from "drizzle-orm";
import { users } from "@shared/models/auth";

export interface IStorage {
  getStudents(): Promise<Student[]>;
  getStudent(id: number): Promise<Student | undefined>;
  createStudent(data: InsertStudent): Promise<Student>;
  updateStudent(id: number, data: Partial<InsertStudent>): Promise<Student | undefined>;
  deleteStudent(id: number): Promise<void>;

  getCourses(): Promise<Course[]>;
  getCourse(id: number): Promise<Course | undefined>;
  updateCourse(id: number, data: Partial<InsertCourse>): Promise<Course | undefined>;

  getPaces(): Promise<Pace[]>;

  getPaceCourses(): Promise<PaceCourse[]>;
  getPaceCoursesByPace(paceId: number): Promise<PaceCourse[]>;
  getPaceCoursesByCourse(courseId: number): Promise<PaceCourse[]>;
  updatePaceCourse(id: number, data: Partial<InsertPaceCourse>): Promise<PaceCourse | undefined>;

  getSubjects(): Promise<Subject[]>;

  getSubjectGroups(): Promise<SubjectGroup[]>;

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

  getPersonnel(): Promise<Personnel[]>;
  getPersonnelById(id: number): Promise<Personnel | undefined>;
  createPersonnel(data: InsertPersonnel): Promise<Personnel>;
  updatePersonnel(id: number, data: Partial<InsertPersonnel>): Promise<Personnel | undefined>;
  deletePersonnel(id: number): Promise<void>;

  getFamilies(): Promise<Family[]>;
  getFamily(id: number): Promise<Family | undefined>;
  createFamily(data: InsertFamily): Promise<Family>;
  updateFamily(id: number, data: Partial<InsertFamily>): Promise<Family | undefined>;
  deleteFamily(id: number): Promise<void>;

  getParents(): Promise<Parent[]>;
  getParent(id: number): Promise<Parent | undefined>;
  createParent(data: InsertParent): Promise<Parent>;
  updateParent(id: number, data: Partial<InsertParent>): Promise<Parent | undefined>;
  deleteParent(id: number): Promise<void>;

  getSupplementaryActivitiesByStudent(studentId: number): Promise<SupplementaryActivity[]>;
  createSupplementaryActivity(data: InsertSupplementaryActivity): Promise<SupplementaryActivity>;
  updateSupplementaryActivity(id: number, data: Partial<InsertSupplementaryActivity>): Promise<SupplementaryActivity | undefined>;
  deleteSupplementaryActivity(id: number): Promise<void>;

  createInvitation(data: InsertInvitation): Promise<Invitation>;
  getInvitations(): Promise<Invitation[]>;
  getInvitationByToken(token: string): Promise<Invitation | undefined>;
  markInvitationUsed(token: string, userId: string): Promise<Invitation | undefined>;
  deleteInvitation(id: number): Promise<void>;

  getAllUserProfilesWithUsers(): Promise<(UserProfile & { email?: string | null; firstName?: string | null; lastName?: string | null })[]>;
  deleteUserProfile(userId: string): Promise<void>;
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
  async updateCourse(id: number, data: Partial<InsertCourse>): Promise<Course | undefined> {
    const [c] = await db.update(courses).set(data).where(eq(courses.id, id)).returning();
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
  async updatePaceCourse(id: number, data: Partial<InsertPaceCourse>): Promise<PaceCourse | undefined> {
    const [pc] = await db.update(paceCourses).set(data).where(eq(paceCourses.id, id)).returning();
    return pc;
  }

  async getSubjects(): Promise<Subject[]> {
    return db.select().from(subjects);
  }

  async getSubjectGroups(): Promise<SubjectGroup[]> {
    return db.select().from(subjectGroups);
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
    const numbers = [...new Set(rows.map(r => r.number).filter((n): n is string => n !== null).map(n => parseInt(n, 10)).filter(n => !isNaN(n)))].sort((a, b) => a - b);
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

  async getPersonnel(): Promise<Personnel[]> {
    return db.select().from(personnel);
  }
  async getPersonnelById(id: number): Promise<Personnel | undefined> {
    const [p] = await db.select().from(personnel).where(eq(personnel.id, id));
    return p;
  }
  async createPersonnel(data: InsertPersonnel): Promise<Personnel> {
    const [p] = await db.insert(personnel).values(data).returning();
    return p;
  }
  async updatePersonnel(id: number, data: Partial<InsertPersonnel>): Promise<Personnel | undefined> {
    const [p] = await db.update(personnel).set(data).where(eq(personnel.id, id)).returning();
    return p;
  }
  async deletePersonnel(id: number): Promise<void> {
    await db.delete(personnel).where(eq(personnel.id, id));
  }

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
  async updateFamily(id: number, data: Partial<InsertFamily>): Promise<Family | undefined> {
    const [f] = await db.update(families).set(data).where(eq(families.id, id)).returning();
    return f;
  }
  async deleteFamily(id: number): Promise<void> {
    await db.delete(families).where(eq(families.id, id));
  }

  async getParents(): Promise<Parent[]> {
    return db.select().from(parents);
  }
  async getParent(id: number): Promise<Parent | undefined> {
    const [p] = await db.select().from(parents).where(eq(parents.id, id));
    return p;
  }
  async createParent(data: InsertParent): Promise<Parent> {
    const [p] = await db.insert(parents).values(data).returning();
    return p;
  }
  async updateParent(id: number, data: Partial<InsertParent>): Promise<Parent | undefined> {
    const [p] = await db.update(parents).set(data).where(eq(parents.id, id)).returning();
    return p;
  }
  async deleteParent(id: number): Promise<void> {
    await db.delete(parents).where(eq(parents.id, id));
  }

  async getSupplementaryActivitiesByStudent(studentId: number): Promise<SupplementaryActivity[]> {
    return db.select().from(supplementaryActivities).where(eq(supplementaryActivities.studentId, studentId));
  }
  async createSupplementaryActivity(data: InsertSupplementaryActivity): Promise<SupplementaryActivity> {
    const [sa] = await db.insert(supplementaryActivities).values(data).returning();
    return sa;
  }
  async updateSupplementaryActivity(id: number, data: Partial<InsertSupplementaryActivity>): Promise<SupplementaryActivity | undefined> {
    const [sa] = await db.update(supplementaryActivities).set(data).where(eq(supplementaryActivities.id, id)).returning();
    return sa;
  }
  async deleteSupplementaryActivity(id: number): Promise<void> {
    await db.delete(supplementaryActivities).where(eq(supplementaryActivities.id, id));
  }

  async createInvitation(data: InsertInvitation): Promise<Invitation> {
    const [inv] = await db.insert(invitations).values(data).returning();
    return inv;
  }
  async getInvitations(): Promise<Invitation[]> {
    return db.select().from(invitations);
  }
  async getInvitationByToken(token: string): Promise<Invitation | undefined> {
    const [inv] = await db.select().from(invitations).where(eq(invitations.token, token));
    return inv;
  }
  async markInvitationUsed(token: string, userId: string): Promise<Invitation | undefined> {
    const [inv] = await db.update(invitations)
      .set({ usedBy: userId, usedAt: new Date() })
      .where(and(eq(invitations.token, token), isNull(invitations.usedBy)))
      .returning();
    return inv;
  }
  async deleteInvitation(id: number): Promise<void> {
    await db.delete(invitations).where(eq(invitations.id, id));
  }

  async getAllUserProfilesWithUsers(): Promise<(UserProfile & { email?: string | null; firstName?: string | null; lastName?: string | null })[]> {
    const rows = await db
      .select({
        id: userProfiles.id,
        userId: userProfiles.userId,
        role: userProfiles.role,
        familyId: userProfiles.familyId,
        isAdmin: userProfiles.isAdmin,
        email: users.email,
        firstName: users.firstName,
        lastName: users.lastName,
      })
      .from(userProfiles)
      .leftJoin(users, eq(userProfiles.userId, users.id));
    return rows;
  }
  async deleteUserProfile(userId: string): Promise<void> {
    await db.delete(userProfiles).where(eq(userProfiles.userId, userId));
  }
}

export const storage = new DatabaseStorage();
