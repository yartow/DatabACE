import { storage } from "./storage";
import { db } from "./db";
import { families, students, subjects, terms, grades, materials, studentSubjects } from "@shared/schema";

export async function seedDatabase() {
  const existingSubjects = await storage.getSubjects();
  if (existingSubjects.length > 0) {
    console.log("Database already seeded, skipping...");
    return;
  }

  console.log("Seeding database...");

  const [fam1] = await db.insert(families).values({ name: "Al-Rashid" }).returning();
  const [fam2] = await db.insert(families).values({ name: "Van der Berg" }).returning();
  const [fam3] = await db.insert(families).values({ name: "Johnson" }).returning();

  const [s1] = await db.insert(students).values({ firstName: "Amira", lastName: "Al-Rashid", familyId: fam1.id, classGroup: "Grade 8A" }).returning();
  const [s2] = await db.insert(students).values({ firstName: "Tariq", lastName: "Al-Rashid", familyId: fam1.id, classGroup: "Grade 6B" }).returning();
  const [s3] = await db.insert(students).values({ firstName: "Lotte", lastName: "Van der Berg", familyId: fam2.id, classGroup: "Grade 8A" }).returning();
  const [s4] = await db.insert(students).values({ firstName: "Daniel", lastName: "Johnson", familyId: fam3.id, classGroup: "Grade 7C" }).returning();

  const subjectData = [
    { name: "Mathematics", code: "MATH" },
    { name: "English Language", code: "ENG" },
    { name: "Science", code: "SCI" },
    { name: "History", code: "HIST" },
    { name: "Geography", code: "GEO" },
    { name: "Art & Design", code: "ART" },
    { name: "Physical Education", code: "PE" },
    { name: "Music", code: "MUS" },
  ];

  const createdSubjects = [];
  for (const sub of subjectData) {
    const [created] = await db.insert(subjects).values(sub).returning();
    createdSubjects.push(created);
  }

  const [term1] = await db.insert(terms).values({ name: "Term 1", year: 2025, startDate: "2025-09-01", endDate: "2025-12-20" }).returning();
  const [term2] = await db.insert(terms).values({ name: "Term 2", year: 2026, startDate: "2026-01-06", endDate: "2026-03-28" }).returning();
  const [term3] = await db.insert(terms).values({ name: "Term 3", year: 2026, startDate: "2026-04-14", endDate: "2026-07-18" }).returning();

  const allStudents = [s1, s2, s3, s4];
  const scoreRanges: Record<number, [number, number]> = {
    [s1.id]: [65, 95],
    [s2.id]: [55, 85],
    [s3.id]: [70, 98],
    [s4.id]: [50, 80],
  };

  for (const student of allStudents) {
    for (const subject of createdSubjects) {
      await db.insert(studentSubjects).values({
        studentId: student.id,
        subjectId: subject.id,
        passed: Math.random() > 0.2,
        examined: Math.random() > 0.3,
        examDate: Math.random() > 0.5 ? "2026-02-15" : null,
      });

      for (const term of [term1, term2]) {
        const [min, max] = scoreRanges[student.id];
        const score = Math.floor(Math.random() * (max - min + 1)) + min;
        await db.insert(grades).values({
          studentId: student.id,
          subjectId: subject.id,
          termId: term.id,
          score,
          maxScore: 100,
          comment: score >= 80 ? "Excellent progress" : score >= 60 ? "Good work, keep improving" : "Needs additional support",
        });
      }
    }
  }

  const materialData = [
    { subjectId: createdSubjects[0].id, name: "Mathematics Textbook Year 8", type: "book", ordered: true, received: true },
    { subjectId: createdSubjects[0].id, name: "Calculator (Scientific)", type: "equipment", ordered: true, received: false },
    { subjectId: createdSubjects[1].id, name: "English Literature Anthology", type: "book", ordered: true, received: true },
    { subjectId: createdSubjects[1].id, name: "Grammar Workbook", type: "book", ordered: false, received: false },
    { subjectId: createdSubjects[2].id, name: "Science Lab Manual", type: "book", ordered: true, received: true },
    { subjectId: createdSubjects[2].id, name: "Safety Goggles", type: "equipment", ordered: true, received: true },
    { subjectId: createdSubjects[3].id, name: "World History Textbook", type: "book", ordered: false, received: false },
    { subjectId: createdSubjects[4].id, name: "Atlas & Map Collection", type: "book", ordered: true, received: false },
    { subjectId: createdSubjects[5].id, name: "Sketchbook A3", type: "equipment", ordered: true, received: true },
    { subjectId: createdSubjects[6].id, name: "Sports Kit", type: "equipment", ordered: false, received: false },
  ];

  for (const mat of materialData) {
    await db.insert(materials).values(mat);
  }

  console.log("Database seeded successfully!");
}
