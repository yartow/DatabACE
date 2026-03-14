import {
  students, courses, paces, paceCourses, dates, userProfiles, enrollments, subjects,
  personnel, families, parents, supplementaryActivities, subjectGroups, invitations,
  paceVersions, inventory,
  type Student, type Course, type Pace, type PaceCourse, type DateEntry, type UserProfile, type Enrollment, type Subject,
  type Personnel, type Family, type Parent, type SupplementaryActivity, type SubjectGroup,
  type Invitation, type InsertInvitation,
  type InsertStudent, type InsertUserProfile, type InsertEnrollment,
  type InsertPersonnel, type InsertFamily, type InsertParent, type InsertSupplementaryActivity,
  type InsertCourse, type InsertPaceCourse, type InsertPace,
  type PaceVersion, type InsertPaceVersion, type Inventory, type InsertInventory,
} from "@shared/schema";
import { db } from "./db";
import { eq, and, isNull, sql } from "drizzle-orm";
import { users } from "@shared/models/auth";

export type InventoryRow = {
  inventoryId: number;
  paceVersionId: number;
  yearRevised: number | null;
  type: "PACE" | "Score Key" | "Material" | null;
  edition: number | null;
  paceId: number;
  paceNumber: number | null;
  courseId: number | null;
  courseName: string | null;
  studentId: number;
  studentSurname: string;
  studentCallName: string;
  numberInPossession: number | null;
};

export interface IStorage {
  getStudents(): Promise<Student[]>;
  getStudent(id: number): Promise<Student | undefined>;
  createStudent(data: InsertStudent): Promise<Student>;
  updateStudent(id: number, data: Partial<InsertStudent>): Promise<Student | undefined>;
  deleteStudent(id: number): Promise<void>;

  getCourses(): Promise<Course[]>;
  getCourse(id: number): Promise<Course | undefined>;
  createCourse(data: InsertCourse): Promise<Course>;
  updateCourse(id: number, data: Partial<InsertCourse>): Promise<Course | undefined>;
  getNextCourseId(): Promise<number>;
  upsertCourse(data: InsertCourse): Promise<Course>;

  getPaces(): Promise<Pace[]>;
  createPace(data: InsertPace): Promise<Pace>;
  getNextPaceId(): Promise<number>;
  upsertPace(data: InsertPace): Promise<Pace>;
  updatePace(id: number, data: Partial<InsertPace>): Promise<Pace | undefined>;

  getPaceCourses(): Promise<PaceCourse[]>;
  getPaceCoursesByPace(paceId: number): Promise<PaceCourse[]>;
  getPaceCoursesByCourse(courseId: number): Promise<PaceCourse[]>;
  updatePaceCourse(id: number, data: Partial<InsertPaceCourse>): Promise<PaceCourse | undefined>;
  createPaceCourseBatch(data: InsertPaceCourse[]): Promise<PaceCourse[]>;
  getNextPaceCourseId(): Promise<number>;
  upsertPaceCourse(data: InsertPaceCourse): Promise<PaceCourse>;

  getSubjects(): Promise<Subject[]>;
  getSubjectGroups(): Promise<SubjectGroup[]>;

  getDates(): Promise<DateEntry[]>;
  getDatesByTerm(term: number): Promise<DateEntry[]>;
  getTermWeekCounts(): Promise<{ yearTerm: string; term: number; weeks: number }[]>;
  backfillEnrollmentTerms(): Promise<number>;

  getEnrollmentsByStudent(studentId: number): Promise<Enrollment[]>;
  getAllEnrollments(): Promise<Enrollment[]>;
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

  deletePaceCourse(id: number): Promise<void>;

  getPaceVersions(): Promise<PaceVersion[]>;
  createPaceVersion(data: InsertPaceVersion): Promise<PaceVersion>;
  updatePaceVersion(id: number, data: Partial<InsertPaceVersion>): Promise<PaceVersion | undefined>;
  deletePaceVersion(id: number): Promise<void>;

  getInventoryRich(): Promise<InventoryRow[]>;
  createInventoryEntry(data: InsertInventory): Promise<Inventory>;
  updateInventoryEntry(id: number, data: Partial<InsertInventory>): Promise<Inventory | undefined>;
  deleteInventoryEntry(id: number): Promise<void>;
  upsertInventoryEntry(paceVersionsId: number, studentId: number, numberInPossession: number): Promise<Inventory>;
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
  async getNextCourseId(): Promise<number> {
    const [r] = await db.select({ maxId: sql<number>`COALESCE(MAX(id), 0)` }).from(courses);
    return (r.maxId || 0) + 1;
  }
  async createCourse(data: InsertCourse): Promise<Course> {
    const [c] = await db.insert(courses).values(data).returning();
    return c;
  }
  async upsertCourse(data: InsertCourse): Promise<Course> {
    const [c] = await db.insert(courses).values(data)
      .onConflictDoUpdate({ target: courses.id, set: { ...data } })
      .returning();
    return c;
  }
  async updateCourse(id: number, data: Partial<InsertCourse>): Promise<Course | undefined> {
    const [c] = await db.update(courses).set(data).where(eq(courses.id, id)).returning();
    return c;
  }

  async getPaces(): Promise<Pace[]> {
    return db.select().from(paces);
  }
  async getNextPaceId(): Promise<number> {
    const [r] = await db.select({ maxId: sql<number>`COALESCE(MAX(id), 0)` }).from(paces);
    return (r.maxId || 0) + 1;
  }
  async createPace(data: InsertPace): Promise<Pace> {
    const [p] = await db.insert(paces).values(data).returning();
    return p;
  }
  async upsertPace(data: InsertPace): Promise<Pace> {
    const [p] = await db.insert(paces).values(data)
      .onConflictDoUpdate({ target: paces.id, set: { ...data } })
      .returning();
    return p;
  }
  async updatePace(id: number, data: Partial<InsertPace>): Promise<Pace | undefined> {
    const [p] = await db.update(paces).set(data).where(eq(paces.id, id)).returning();
    return p;
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
  async getNextPaceCourseId(): Promise<number> {
    const [r] = await db.select({ maxId: sql<number>`COALESCE(MAX(id), 0)` }).from(paceCourses);
    return (r.maxId || 0) + 1;
  }
  async createPaceCourseBatch(data: InsertPaceCourse[]): Promise<PaceCourse[]> {
    if (data.length === 0) return [];
    return db.insert(paceCourses).values(data).returning();
  }
  async upsertPaceCourse(data: InsertPaceCourse): Promise<PaceCourse> {
    const [pc] = await db.insert(paceCourses).values(data)
      .onConflictDoUpdate({ target: paceCourses.id, set: { ...data } })
      .returning();
    return pc;
  }
  async deletePaceCourse(id: number): Promise<void> {
    await db.delete(paceCourses).where(eq(paceCourses.id, id));
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
  async getTermWeekCounts(): Promise<{ yearTerm: string; term: number; weeks: number }[]> {
    const result = await db.execute(sql`
      SELECT year_term, term, MAX(term_week) AS weeks
      FROM dates
      WHERE term IS NOT NULL AND term_week IS NOT NULL AND weekend = 0 AND holiday = 0
      GROUP BY year_term, term
      ORDER BY year_term, term
    `);
    const rowData: any[] = (result as any).rows ?? result;
    return rowData.map((r: any) => ({ yearTerm: String(r.year_term), term: Number(r.term), weeks: Number(r.weeks) }));
  }

  async backfillEnrollmentTerms(): Promise<number> {
    const result = await db.execute(sql`
      UPDATE enrollments
      SET
        term = COALESCE(term, (
          SELECT d.term
          FROM dates d
          WHERE (DATE '1899-12-30' + d.date * INTERVAL '1 day')::date = enrollments.date_ended::date
            AND d.term IS NOT NULL
          LIMIT 1
        )),
        year_term = CASE
          WHEN date_ended IS NOT NULL THEN
            CASE
              WHEN EXTRACT(MONTH FROM date_ended::date) >= 8 THEN
                LPAD((EXTRACT(YEAR FROM date_ended::date)::int % 100)::text, 2, '0')
                || '–'
                || LPAD(((EXTRACT(YEAR FROM date_ended::date)::int + 1) % 100)::text, 2, '0')
              ELSE
                LPAD(((EXTRACT(YEAR FROM date_ended::date)::int - 1) % 100)::text, 2, '0')
                || '–'
                || LPAD((EXTRACT(YEAR FROM date_ended::date)::int % 100)::text, 2, '0')
            END
          ELSE NULL
        END
      WHERE date_ended IS NOT NULL
    `);
    return (result as any).rowCount ?? 0;
  }

  async getEnrollmentsByStudent(studentId: number): Promise<Enrollment[]> {
    return db.select().from(enrollments).where(eq(enrollments.studentId, studentId));
  }
  async getAllEnrollments(): Promise<Enrollment[]> {
    return db.select().from(enrollments);
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

  async getPaceVersions(): Promise<PaceVersion[]> {
    return db.select().from(paceVersions);
  }
  async createPaceVersion(data: InsertPaceVersion): Promise<PaceVersion> {
    const [pv] = await db.insert(paceVersions).values(data).returning();
    return pv;
  }
  async updatePaceVersion(id: number, data: Partial<InsertPaceVersion>): Promise<PaceVersion | undefined> {
    const [pv] = await db.update(paceVersions).set(data).where(eq(paceVersions.id, id)).returning();
    return pv;
  }
  async deletePaceVersion(id: number): Promise<void> {
    await db.delete(paceVersions).where(eq(paceVersions.id, id));
  }

  async getInventoryRich(): Promise<InventoryRow[]> {
    const rows = await db
      .select({
        inventoryId: inventory.id,
        paceVersionId: paceVersions.id,
        yearRevised: paceVersions.yearRevised,
        type: paceVersions.type,
        edition: paceVersions.edition,
        paceId: paces.id,
        paceNumber: paces.number,
        courseId: paceCourses.courseId,
        courseName: courses.icceAlias,
        studentId: students.id,
        studentSurname: students.surname,
        studentCallName: students.callName,
        numberInPossession: inventory.numberInPossession,
      })
      .from(inventory)
      .innerJoin(paceVersions, eq(inventory.paceVersionsId, paceVersions.id))
      .innerJoin(paces, eq(paceVersions.paceId, paces.id))
      .innerJoin(students, eq(inventory.studentId, students.id))
      .leftJoin(paceCourses, eq(paceCourses.paceId, paces.id))
      .leftJoin(courses, eq(paceCourses.courseId, courses.id));
    return rows as InventoryRow[];
  }
  async createInventoryEntry(data: InsertInventory): Promise<Inventory> {
    const [inv] = await db.insert(inventory).values(data).returning();
    return inv;
  }
  async updateInventoryEntry(id: number, data: Partial<InsertInventory>): Promise<Inventory | undefined> {
    const [inv] = await db.update(inventory).set(data).where(eq(inventory.id, id)).returning();
    return inv;
  }
  async deleteInventoryEntry(id: number): Promise<void> {
    await db.delete(inventory).where(eq(inventory.id, id));
  }
  async upsertInventoryEntry(paceVersionsId: number, studentId: number, numberInPossession: number): Promise<Inventory> {
    const existing = await db.select().from(inventory)
      .where(and(eq(inventory.paceVersionsId, paceVersionsId), eq(inventory.studentId, studentId)));
    if (existing.length > 0) {
      const [inv] = await db.update(inventory)
        .set({ numberInPossession })
        .where(eq(inventory.id, existing[0].id))
        .returning();
      return inv;
    }
    const [inv] = await db.insert(inventory).values({ paceVersionsId, studentId, numberInPossession }).returning();
    return inv;
  }
}

export const storage = new DatabaseStorage();
