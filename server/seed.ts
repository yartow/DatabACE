import { db } from "./db";
import { students, courses, paces, paceCourses, dates } from "@shared/schema";
import path from "path";
import fs from "fs";

function safeInt(val: any): number | null {
  if (val === undefined || val === null || val === "" || val === "?") return null;
  const n = Number(val);
  return isNaN(n) ? null : n;
}

function safeReal(val: any): number | null {
  if (val === undefined || val === null || val === "" || val === "?") return null;
  const n = Number(val);
  return isNaN(n) ? null : n;
}

function safeStr(val: any): string | null {
  if (val === undefined || val === null || val === "?") return null;
  return String(val);
}

function excelSerialToDateStr(serial: number): string {
  const utcDays = Math.floor(serial - 25569);
  const d = new Date(utcDays * 86400 * 1000);
  return d.toISOString().split("T")[0];
}

export async function seedDatabase() {
  const existingStudents = await db.select().from(students);
  if (existingStudents.length > 0) {
    console.log("Database already seeded, skipping...");
    return;
  }

  console.log("Seeding database from Excel file...");

  const XLSX = await import("xlsx");
  const filePath = path.join(process.cwd(), "attached_assets", "WORKBOOK_v0.3_1772895537061.xlsx");
  const fileBuffer = fs.readFileSync(filePath);
  const workbook = XLSX.read(fileBuffer, { type: "buffer" });

  const studentData = XLSX.utils.sheet_to_json(workbook.Sheets["Student"]) as any[];
  console.log(`Importing ${studentData.length} students...`);
  for (const row of studentData) {
    await db.insert(students).values({
      id: row.ID,
      surname: row.Surname,
      firstNames: row.FirstNames || null,
      callName: row.CallName,
      alias: row.Alias,
    });
  }

  const courseData = XLSX.utils.sheet_to_json(workbook.Sheets["Course"]) as any[];
  console.log(`Importing ${courseData.length} courses...`);
  for (const row of courseData) {
    await db.insert(courses).values({
      id: row.ID,
      aceAlias: safeStr(row.ACE_Alias),
      level: safeInt(row.Level),
      paceNrStart: safeInt(row.PaceNrStart),
      paceNrEnd: safeInt(row.PaceNrEnd),
      paceCount: safeInt(row.PaceCount__),
      starValue: safeInt(row.StarValue),
      subjectId: safeInt(row.SubjectID),
      subjectTemp: safeStr(row.Subject_temp),
      subjectAbb: safeStr(row.SubjectAbb),
      specification: safeStr(row.Specification),
      subjectGroupId: safeInt(row.SubjectGroupID),
      subjectGroup: safeStr(row.SubjectGroup__),
      courseType: safeStr(row.CourseType),
      course: safeStr(row.Course),
      passThreshold: safeReal(row.PassThreshold),
    });
  }

  const paceData = XLSX.utils.sheet_to_json(workbook.Sheets["PACE"]) as any[];
  console.log(`Importing ${paceData.length} PACEs...`);
  const batchSize = 100;
  for (let i = 0; i < paceData.length; i += batchSize) {
    const batch = paceData.slice(i, i + batchSize).map(row => ({
      id: row.ID,
      courseId: safeInt(row.CourseID),
      number: safeInt(row.Number),
      specificationAbb: safeStr(row.SpecificationAbb),
      code2: safeStr(row.Code2),
      alias: safeInt(row.Alias__),
      subject: safeInt(row.Subject),
      edition: safeInt(row.Edition),
      editionOrder: safeInt(row.EditionOrder),
      type: safeStr(row.Type),
      subjectGroupId: safeStr(row.SubjectGroupID__),
      starValue: safeInt(row.StarValue),
    }));
    await db.insert(paces).values(batch);
  }

  const paceCourseData = XLSX.utils.sheet_to_json(workbook.Sheets["PaceCourse"]) as any[];
  const paceIds = new Set(paceData.map((r: any) => r.ID));
  const courseIds = new Set(courseData.map((r: any) => r.ID));
  const seenPcIds = new Set<number>();
  const validPaceCourses = paceCourseData.filter((row: any) => {
    if (!paceIds.has(row.PaceID) || !courseIds.has(row.CourseID)) return false;
    if (seenPcIds.has(row.ID)) return false;
    seenPcIds.add(row.ID);
    return true;
  });
  const skipped = paceCourseData.length - validPaceCourses.length;
  console.log(`Importing ${validPaceCourses.length} PaceCourses (${skipped} skipped: missing refs or duplicates)...`);
  for (let i = 0; i < validPaceCourses.length; i += batchSize) {
    const batch = validPaceCourses.slice(i, i + batchSize).map((row: any) => ({
      id: row.ID,
      paceId: row.PaceID,
      courseId: row.CourseID,
      alias: safeInt(row.Alias__),
      number: safeInt(row.Number__),
      code: safeStr(row.Code__),
      creditValuePace: safeInt(row.CreditValuePace),
      passThreshold: safeReal(row.PassThreshold__),
      active: safeInt(row.Active),
    }));
    await db.insert(paceCourses).values(batch);
  }

  const dateData = XLSX.utils.sheet_to_json(workbook.Sheets["Date"]) as any[];
  console.log(`Importing ${dateData.length} dates...`);
  for (let i = 0; i < dateData.length; i += batchSize) {
    const batch = dateData.slice(i, i + batchSize).map(row => ({
      id: row.ID,
      date: safeInt(row.Date),
      weekend: safeInt(row.Weekend),
      holiday: safeInt(row.Holiday),
      dayOff: safeInt(row.DayOff),
      weekDay: safeStr(row.WeekDay),
      remark: safeStr(row.Remark),
      term: safeInt(row.Term),
      termWeek: safeInt(row.TermWeek),
      week: safeInt(row.Week),
    }));
    await db.insert(dates).values(batch);
  }

  console.log("Database seeded successfully from Excel file!");
}
