export * from "./models/auth";

import { relations } from "drizzle-orm";
import { pgTable, text, integer, real, boolean, pgEnum } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";
import { users } from "./models/auth";

export const roleEnum = pgEnum("user_role", ["teacher", "parent"]);

export const userProfiles = pgTable("user_profiles", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  userId: text("user_id").notNull().references(() => users.id),
  role: roleEnum("role").notNull().default("parent"),
  familyId: integer("family_id"),
});

export const students = pgTable("students", {
  id: integer("id").primaryKey(),
  surname: text("surname").notNull(),
  firstNames: text("first_names"),
  callName: text("call_name").notNull(),
  alias: text("alias").notNull(),
});

export const courses = pgTable("courses", {
  id: integer("id").primaryKey(),
  aceAlias: text("ace_alias"),
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
  number: integer("number"),
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
});

export const enrollments = pgTable("enrollments", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  studentId: integer("student_id").notNull().references(() => students.id),
  courseId: integer("course_id").notNull().references(() => courses.id),
  dateStarted: text("date_started").notNull(),
  dateEnded: text("date_ended"),
  grade: real("grade"),
  remarks: text("remarks"),
});

export const enrollmentsRelations = relations(enrollments, ({ one }) => ({
  student: one(students, { fields: [enrollments.studentId], references: [students.id] }),
  course: one(courses, { fields: [enrollments.courseId], references: [courses.id] }),
}));

export const studentsRelations = relations(students, ({ many }) => ({
  enrollments: many(enrollments),
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

export const insertStudentSchema = createInsertSchema(students);
export const insertCourseSchema = createInsertSchema(courses);
export const insertPaceSchema = createInsertSchema(paces);
export const insertPaceCourseSchema = createInsertSchema(paceCourses);
export const insertDateSchema = createInsertSchema(dates);
export const insertEnrollmentSchema = createInsertSchema(enrollments).omit({ id: true });
export const insertUserProfileSchema = createInsertSchema(userProfiles).omit({ id: true });

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
