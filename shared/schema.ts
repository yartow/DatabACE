export * from "./models/auth";

import { relations, sql } from "drizzle-orm";
import { pgTable, text, integer, real, boolean, pgEnum, varchar, timestamp } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";
import { users } from "./models/auth";

export const roleEnum = pgEnum("user_role", ["teacher", "parent"]);

export const userProfiles = pgTable("user_profiles", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  userId: text("user_id").notNull().references(() => users.id),
  role: roleEnum("role").notNull().default("parent"),
  familyId: integer("family_id"),
  isAdmin: boolean("is_admin").notNull().default(false),
});

export const invitations = pgTable("invitations", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  token: text("token").notNull().unique(),
  role: roleEnum("role").notNull(),
  familyId: integer("family_id"),
  email: text("email"),
  createdBy: text("created_by").notNull(),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  usedBy: text("used_by"),
  usedAt: timestamp("used_at"),
  expiresAt: timestamp("expires_at").notNull(),
});

export const families = pgTable("families", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  firstName: text("first_name").notNull(),
  lastName: text("last_name").notNull(),
  address: text("address"),
  city: text("city"),
  postalCode: text("postal_code"),
});

export const students = pgTable("students", {
  id: integer("id").primaryKey().generatedByDefaultAsIdentity(),
  surname: text("surname").notNull(),
  firstNames: text("first_names"),
  callName: text("call_name").notNull(),
  alias: text("alias").notNull(),
  isDyslexic: boolean("is_dyslexic").notNull().default(false),
  active: boolean("active").notNull().default(true),
  reasonInactive: text("reason_inactive"),
  remarks: text("remarks"),
  dateOfBirth: text("date_of_birth"),
  familyId: integer("family_id").references(() => families.id),
  group: text("group"),
});

export const personnel = pgTable("personnel", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  firstName: text("first_name").notNull(),
  lastName: text("last_name").notNull(),
  group: text("group").notNull(),
  type: text("type").notNull(),
  rank: integer("rank"),
  email: text("email"),
  isAdmin: boolean("is_admin").default(false).notNull(),
});

export const parents = pgTable("parents", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  firstName: text("first_name").notNull(),
  lastName: text("last_name").notNull(),
  phoneNumber: text("phone_number"),
  familyId: integer("family_id").references(() => families.id),
});

export const subjectGroups = pgTable("subject_groups", {
  id: integer("id").primaryKey(),
  subjectGroup: text("subject_group").notNull(),
  remarks: varchar("remarks", { length: 1200 }),
});

export const subjects = pgTable("subjects", {
  id: integer("id").primaryKey(),
  subject: text("subject").notNull(),
  colorId: integer("color_id"),
  color: text("color"),
  colorCode: text("color_code"),
  subjectGroupId: integer("subject_group_id").references(() => subjectGroups.id),
});

export const courses = pgTable("courses", {
  id: integer("id").primaryKey(),
  aceAlias: text("ace_alias"),
  icceAlias: text("icce_alias"),
  certificateName: text("certificate_name"),
  level: integer("level"),
  paceNrStart: integer("pace_nr_start"),
  paceNrEnd: integer("pace_nr_end"),
  paceCount: integer("pace_count"),
  starValue: integer("star_value"),
  subjectId: integer("subject_id"),
  subjectTemp: text("subject_temp"),
  subjectAbb: text("subject_abb"),
  specification: text("specification"),
  subjectGroupId: integer("subject_group_id"),
  subjectGroup: text("subject_group"),
  courseType: text("course_type"),
  course: text("course"),
  passThreshold: real("pass_threshold"),
});

export const paces = pgTable("paces", {
  id: integer("id").primaryKey(),
  courseId: integer("course_id"),
  number: integer("number"),
  specificationAbb: text("specification_abb"),
  code2: text("code2"),
  alias: integer("alias"),
  subject: integer("subject"),
  edition: integer("edition"),
  editionOrder: integer("edition_order"),
  type: text("type"),
  subjectGroupId: text("subject_group_id"),
  starValue: integer("star_value"),
});

export const paceCourses = pgTable("pace_courses", {
  id: integer("id").primaryKey(),
  paceId: integer("pace_id").notNull().references(() => paces.id),
  courseId: integer("course_id").notNull().references(() => courses.id),
  alias: integer("alias"),
  number: varchar("number", { length: 10 }),
  code: text("code"),
  creditValuePace: real("credit_value_pace"),
  passThreshold: real("pass_threshold"),
  active: integer("active"),
});

export const dates = pgTable("dates", {
  id: integer("id").primaryKey(),
  date: integer("date"),
  weekend: integer("weekend"),
  holiday: integer("holiday"),
  dayOff: integer("day_off"),
  weekDay: text("week_day"),
  remark: text("remark"),
  term: integer("term"),
  termWeek: integer("term_week"),
  week: integer("week"),
  yearTerm: text("year_term"),
});

export const enrollments = pgTable("enrollments", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  studentId: integer("student_id").notNull().references(() => students.id),
  courseId: integer("course_id").notNull().references(() => courses.id),
  number: varchar("number", { length: 10 }).notNull(),
  dateStarted: text("date_started"),
  dateEnded: text("date_ended"),
  grade: real("grade"),
  remarks: text("remarks"),
});

export const supplementaryActivities = pgTable("supplementary_activities", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  studentId: integer("student_id").notNull().references(() => students.id),
  yearTerm: text("year_term"),
  term: integer("term"),
  grade: varchar("grade", { length: 4 }),
  activity: text("activity").notNull(),
});

export const enrollmentsRelations = relations(enrollments, ({ one }) => ({
  student: one(students, { fields: [enrollments.studentId], references: [students.id] }),
  course: one(courses, { fields: [enrollments.courseId], references: [courses.id] }),
}));

export const studentsRelations = relations(students, ({ many }) => ({
  enrollments: many(enrollments),
  supplementaryActivities: many(supplementaryActivities),
}));

export const supplementaryActivitiesRelations = relations(supplementaryActivities, ({ one }) => ({
  student: one(students, { fields: [supplementaryActivities.studentId], references: [students.id] }),
}));

export const userProfilesRelations = relations(userProfiles, ({ one }) => ({
  user: one(users, { fields: [userProfiles.userId], references: [users.id] }),
}));

export const paceCoursesRelations = relations(paceCourses, ({ one }) => ({
  pace: one(paces, { fields: [paceCourses.paceId], references: [paces.id] }),
  course: one(courses, { fields: [paceCourses.courseId], references: [courses.id] }),
}));

export const coursesRelations = relations(courses, ({ many }) => ({
  paceCourses: many(paceCourses),
}));

export const pacesRelations = relations(paces, ({ many }) => ({
  paceCourses: many(paceCourses),
}));

export const insertStudentSchema = createInsertSchema(students).omit({ id: true });
export const insertCourseSchema = createInsertSchema(courses);
export const insertPaceSchema = createInsertSchema(paces);
export const insertPaceCourseSchema = createInsertSchema(paceCourses);
export const insertDateSchema = createInsertSchema(dates);
export const insertEnrollmentSchema = createInsertSchema(enrollments).omit({ id: true });
export const insertUserProfileSchema = createInsertSchema(userProfiles).omit({ id: true });
export const insertSubjectSchema = createInsertSchema(subjects);
export const insertPersonnelSchema = createInsertSchema(personnel).omit({ id: true });
export const insertFamilySchema = createInsertSchema(families).omit({ id: true });
export const insertParentSchema = createInsertSchema(parents).omit({ id: true });
export const insertSubjectGroupSchema = createInsertSchema(subjectGroups);
export const insertSupplementaryActivitySchema = createInsertSchema(supplementaryActivities).omit({ id: true });
export const insertInvitationSchema = createInsertSchema(invitations).omit({ id: true });

export type Student = typeof students.$inferSelect;
export type InsertStudent = z.infer<typeof insertStudentSchema>;
export type Course = typeof courses.$inferSelect;
export type InsertCourse = z.infer<typeof insertCourseSchema>;
export type Pace = typeof paces.$inferSelect;
export type InsertPace = z.infer<typeof insertPaceSchema>;
export type PaceCourse = typeof paceCourses.$inferSelect;
export type InsertPaceCourse = z.infer<typeof insertPaceCourseSchema>;
export type DateEntry = typeof dates.$inferSelect;
export type InsertDate = z.infer<typeof insertDateSchema>;
export type Enrollment = typeof enrollments.$inferSelect;
export type InsertEnrollment = z.infer<typeof insertEnrollmentSchema>;
export type UserProfile = typeof userProfiles.$inferSelect;
export type InsertUserProfile = z.infer<typeof insertUserProfileSchema>;
export type Subject = typeof subjects.$inferSelect;
export type InsertSubject = z.infer<typeof insertSubjectSchema>;
export type Personnel = typeof personnel.$inferSelect;
export type InsertPersonnel = z.infer<typeof insertPersonnelSchema>;
export type Family = typeof families.$inferSelect;
export type InsertFamily = z.infer<typeof insertFamilySchema>;
export type Parent = typeof parents.$inferSelect;
export type InsertParent = z.infer<typeof insertParentSchema>;
export type SubjectGroup = typeof subjectGroups.$inferSelect;
export type InsertSubjectGroup = z.infer<typeof insertSubjectGroupSchema>;
export type SupplementaryActivity = typeof supplementaryActivities.$inferSelect;
export type InsertSupplementaryActivity = z.infer<typeof insertSupplementaryActivitySchema>;
export type Invitation = typeof invitations.$inferSelect;
export type InsertInvitation = z.infer<typeof insertInvitationSchema>;
