import { db } from "./db";
import { students, courses, paces, paceCourses, dates, subjectGroups, subjects } from "@shared/schema";
import { eq } from "drizzle-orm";
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

function computeYearTerm(excelDateSerial: number): string {
  const utcDays = Math.floor(excelDateSerial - 25569);
  const d = new Date(utcDays * 86400 * 1000);
  const month = d.getUTCMonth();
  const year = d.getUTCFullYear();
  const startYear = month >= 7 ? year : year - 1;
  const endYear = startYear + 1;
  const s = String(startYear).slice(-2);
  const e = String(endYear).slice(-2);
  return `${s}\u2013${e}`;
}

export async function seedDatabase() {
  const existingStudents = await db.select().from(students);
  if (existingStudents.length > 0) {
    console.log("Database already seeded, skipping...");

    const existingSg = await db.select().from(subjectGroups);
    if (existingSg.length === 0) {
      await seedSubjectGroups();
    }

    const checkDates = await db.select().from(dates);
    if (checkDates.length > 0 && !checkDates[0].yearTerm) {
      await backfillYearTerm();
    }

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

  const courseSheet = workbook.Sheets["Course"];
  const courseData = XLSX.utils.sheet_to_json(courseSheet) as any[];
  const icceMap = new Map<number, { icceAlias: string | null; certificateName: string | null }>();
  const courseRange = XLSX.utils.decode_range(courseSheet["!ref"]!);
  for (let r = 1; r <= courseRange.e.r; r++) {
    const idCell = courseSheet[XLSX.utils.encode_cell({ r, c: 0 })];
    if (!idCell || idCell.v === undefined) continue;
    const cellC = courseSheet[XLSX.utils.encode_cell({ r, c: 2 })];
    const cellD = courseSheet[XLSX.utils.encode_cell({ r, c: 3 })];
    const icceAlias = cellC && cellC.v && cellC.v !== 0 ? String(cellC.v) : null;
    const certName = cellD && cellD.v && cellD.v !== 0 ? String(cellD.v) : null;
    if (icceAlias || certName) {
      icceMap.set(Number(idCell.v), { icceAlias, certificateName: certName });
    }
  }
  console.log(`Importing ${courseData.length} courses (${icceMap.size} with ICCE names)...`);
  for (const row of courseData) {
    const icceInfo = icceMap.get(row.ID);
    await db.insert(courses).values({
      id: row.ID,
      aceAlias: safeStr(row.ACE_Alias),
      icceAlias: icceInfo?.icceAlias || null,
      certificateName: icceInfo?.certificateName || null,
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
      yearTerm: row.Date ? computeYearTerm(row.Date) : null,
    }));
    await db.insert(dates).values(batch);
  }

  await seedSubjectGroups();

  console.log("Database seeded successfully from Excel file!");
}

async function seedSubjectGroups() {
  const XLSX = await import("xlsx");
  const filePath = path.join(process.cwd(), "attached_assets", "WORKBOOK_v0.3_1772895537061.xlsx");
  const fileBuffer = fs.readFileSync(filePath);
  const workbook = XLSX.read(fileBuffer, { type: "buffer" });

  const courseData = XLSX.utils.sheet_to_json(workbook.Sheets["Course"]) as any[];

  const sgMap = new Map<number, string>();
  courseData.forEach((r: any) => {
    if (r.SubjectGroupID != null && r.SubjectGroup__ != null) {
      sgMap.set(r.SubjectGroupID, r.SubjectGroup__);
    }
  });

  console.log(`Seeding ${sgMap.size} subject groups...`);
  for (const [id, name] of sgMap) {
    await db.insert(subjectGroups).values({ id, subjectGroup: name }).onConflictDoNothing();
  }

  const subjectSgMap = new Map<number, number>();
  courseData.forEach((r: any) => {
    if (r.SubjectID != null && r.SubjectGroupID != null && !subjectSgMap.has(r.SubjectID)) {
      subjectSgMap.set(r.SubjectID, r.SubjectGroupID);
    }
  });

  console.log(`Updating ${subjectSgMap.size} subjects with subjectGroupId...`);
  for (const [subjectId, sgId] of subjectSgMap) {
    await db.update(subjects).set({ subjectGroupId: sgId }).where(eq(subjects.id, subjectId));
  }
}

async function backfillYearTerm() {
  console.log("Backfilling yearTerm for dates...");
  const allDates = await db.select().from(dates);
  for (const d of allDates) {
    if (d.date) {
      const yt = computeYearTerm(d.date);
      await db.update(dates).set({ yearTerm: yt }).where(eq(dates.id, d.id));
    }
  }
  console.log("YearTerm backfill complete.");
}
