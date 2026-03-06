export * from "./models/auth";

import { sql, relations } from "drizzle-orm";
import { pgTable, text, varchar, integer, boolean, timestamp, pgEnum } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod";
import { users } from "./models/auth";

export const roleEnum = pgEnum("user_role", ["teacher", "parent"]);

export const userProfiles = pgTable("user_profiles", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  userId: varchar("user_id").notNull().references(() => users.id),
  role: roleEnum("role").notNull().default("parent"),
  familyId: integer("family_id").references(() => families.id),
});

export const families = pgTable("families", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  name: text("name").notNull(),
});

export const students = pgTable("students", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  firstName: text("first_name").notNull(),
  lastName: text("last_name").notNull(),
  familyId: integer("family_id").notNull().references(() => families.id),
  classGroup: text("class_group"),
  dateOfBirth: text("date_of_birth"),
});

export const subjects = pgTable("subjects", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  name: text("name").notNull(),
  code: text("code").notNull().unique(),
});

export const terms = pgTable("terms", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  name: text("name").notNull(),
  year: integer("year").notNull(),
  startDate: text("start_date"),
  endDate: text("end_date"),
});

export const grades = pgTable("grades", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  studentId: integer("student_id").notNull().references(() => students.id),
  subjectId: integer("subject_id").notNull().references(() => subjects.id),
  termId: integer("term_id").notNull().references(() => terms.id),
  score: integer("score").notNull(),
  maxScore: integer("max_score").notNull().default(100),
  comment: text("comment"),
});

export const materials = pgTable("materials", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  subjectId: integer("subject_id").notNull().references(() => subjects.id),
  name: text("name").notNull(),
  type: text("type").notNull().default("book"),
  ordered: boolean("ordered").notNull().default(false),
  received: boolean("received").notNull().default(false),
});

export const studentSubjects = pgTable("student_subjects", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  studentId: integer("student_id").notNull().references(() => students.id),
  subjectId: integer("subject_id").notNull().references(() => subjects.id),
  passed: boolean("passed").notNull().default(false),
  examined: boolean("examined").notNull().default(false),
  examDate: text("exam_date"),
});

export const familiesRelations = relations(families, ({ many }) => ({
  students: many(students),
  userProfiles: many(userProfiles),
}));

export const studentsRelations = relations(students, ({ one, many }) => ({
  family: one(families, { fields: [students.familyId], references: [families.id] }),
  grades: many(grades),
  studentSubjects: many(studentSubjects),
}));

export const subjectsRelations = relations(subjects, ({ many }) => ({
  grades: many(grades),
  materials: many(materials),
  studentSubjects: many(studentSubjects),
}));

export const gradesRelations = relations(grades, ({ one }) => ({
  student: one(students, { fields: [grades.studentId], references: [students.id] }),
  subject: one(subjects, { fields: [grades.subjectId], references: [subjects.id] }),
  term: one(terms, { fields: [grades.termId], references: [terms.id] }),
}));

export const materialsRelations = relations(materials, ({ one }) => ({
  subject: one(subjects, { fields: [materials.subjectId], references: [subjects.id] }),
}));

export const studentSubjectsRelations = relations(studentSubjects, ({ one }) => ({
  student: one(students, { fields: [studentSubjects.studentId], references: [students.id] }),
  subject: one(subjects, { fields: [studentSubjects.subjectId], references: [subjects.id] }),
}));

export const userProfilesRelations = relations(userProfiles, ({ one }) => ({
  user: one(users, { fields: [userProfiles.userId], references: [users.id] }),
  family: one(families, { fields: [userProfiles.familyId], references: [families.id] }),
}));

export const insertFamilySchema = createInsertSchema(families).omit({ id: true });
export const insertStudentSchema = createInsertSchema(students).omit({ id: true });
export const insertSubjectSchema = createInsertSchema(subjects).omit({ id: true });
export const insertTermSchema = createInsertSchema(terms).omit({ id: true });
export const insertGradeSchema = createInsertSchema(grades).omit({ id: true });
export const insertMaterialSchema = createInsertSchema(materials).omit({ id: true });
export const insertStudentSubjectSchema = createInsertSchema(studentSubjects).omit({ id: true });
export const insertUserProfileSchema = createInsertSchema(userProfiles).omit({ id: true });

export type InsertFamily = z.infer<typeof insertFamilySchema>;
export type InsertStudent = z.infer<typeof insertStudentSchema>;
export type InsertSubject = z.infer<typeof insertSubjectSchema>;
export type InsertTerm = z.infer<typeof insertTermSchema>;
export type InsertGrade = z.infer<typeof insertGradeSchema>;
export type InsertMaterial = z.infer<typeof insertMaterialSchema>;
export type InsertStudentSubject = z.infer<typeof insertStudentSubjectSchema>;
export type InsertUserProfile = z.infer<typeof insertUserProfileSchema>;

export type Family = typeof families.$inferSelect;
export type Student = typeof students.$inferSelect;
export type Subject = typeof subjects.$inferSelect;
export type Term = typeof terms.$inferSelect;
export type Grade = typeof grades.$inferSelect;
export type Material = typeof materials.$inferSelect;
export type StudentSubject = typeof studentSubjects.$inferSelect;
export type UserProfile = typeof userProfiles.$inferSelect;
