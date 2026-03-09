import { useQuery } from "@tanstack/react-query";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Skeleton } from "@/components/ui/skeleton";
import { useState, useMemo } from "react";
import type { Student, Course, Enrollment, DateEntry } from "@shared/schema";

const TERMS = [1, 2, 3, 4, 5];
const SCHOOL_NAME = "Ceder Academy";

function formatGrade(grade: number | null | undefined): string {
  if (grade === null || grade === undefined) return "";
  if (Number.isInteger(grade)) return `${grade}%`;
  return `${parseFloat(grade.toFixed(1))}%`;
}

function excelDateToKey(excelDate: number): string {
  const msPerDay = 86400000;
  const excelEpochMs = Date.UTC(1899, 11, 30);
  const utcMs = excelEpochMs + excelDate * msPerDay;
  const d = new Date(utcMs);
  return `${d.getUTCFullYear()}-${String(d.getUTCMonth() + 1).padStart(2, "0")}-${String(d.getUTCDate()).padStart(2, "0")}`;
}

interface TermData {
  avgGrade: number | null;
  count: number;
}

interface CourseTermData {
  course: Course;
  terms: Record<number, TermData>;
  termGradeSum: Record<number, number>;
  ytd: TermData;
  ytdGradeSum: number;
}

interface CategoryBlock {
  name: string;
  courses: CourseTermData[];
  avgTerms: Record<number, TermData>;
  avgYtd: TermData;
}

export default function SPCPage() {
  const [selectedStudentId, setSelectedStudentId] = useState<string>("");

  const { data: students, isLoading: studentsLoading } = useQuery<Student[]>({ queryKey: ["/api/students"] });
  const { data: courses } = useQuery<Course[]>({ queryKey: ["/api/courses"] });
  const { data: allDates } = useQuery<DateEntry[]>({ queryKey: ["/api/dates"] });

  const selectedStudent = useMemo(() => {
    if (!selectedStudentId || !students) return null;
    return students.find(s => s.id === parseInt(selectedStudentId)) || null;
  }, [selectedStudentId, students]);

  const { data: enrollments, isLoading: enrollmentsLoading } = useQuery<Enrollment[]>({
    queryKey: ["/api/enrollments", selectedStudentId],
    queryFn: async () => {
      const res = await fetch(`/api/enrollments?studentId=${selectedStudentId}`, { credentials: "include" });
      if (!res.ok) throw new Error("Failed");
      return res.json();
    },
    enabled: !!selectedStudentId,
  });

  const datesMap = useMemo(() => {
    const map = new Map<string, DateEntry>();
    allDates?.forEach(d => {
      if (d.date !== null && d.date !== undefined) {
        map.set(excelDateToKey(d.date), d);
      }
    });
    return map;
  }, [allDates]);

  const courseMap = useMemo(() => {
    const map = new Map<number, Course>();
    courses?.forEach(c => map.set(c.id, c));
    return map;
  }, [courses]);

  const yearTerm = useMemo(() => {
    if (!allDates) return "25–26";
    const withYt = allDates.find(d => d.yearTerm);
    return withYt?.yearTerm || "25–26";
  }, [allDates]);

  const categoryBlocks = useMemo((): CategoryBlock[] => {
    if (!enrollments || !courses) return [];

    const getTermForEnrollment = (e: Enrollment): number | null => {
      if (!e.dateStarted) return null;
      const dateEntry = datesMap.get(e.dateStarted);
      return dateEntry?.term ?? null;
    };

    const courseEnrollments = new Map<number, Enrollment[]>();
    enrollments.forEach(e => {
      const list = courseEnrollments.get(e.courseId) || [];
      list.push(e);
      courseEnrollments.set(e.courseId, list);
    });

    const courseTermDataMap = new Map<number, CourseTermData>();
    courseEnrollments.forEach((enrs, courseId) => {
      const course = courseMap.get(courseId);
      if (!course) return;

      const termBuckets: Record<number, number[]> = {};
      TERMS.forEach(t => { termBuckets[t] = []; });
      const allGrades: number[] = [];
      let totalCount = 0;

      enrs.forEach(e => {
        const term = getTermForEnrollment(e);
        if (e.grade !== null && e.grade !== undefined) {
          allGrades.push(e.grade);
          totalCount++;
          if (term && termBuckets[term]) {
            termBuckets[term].push(e.grade);
          }
        }
      });

      const terms: Record<number, TermData> = {};
      const termGradeSum: Record<number, number> = {};
      TERMS.forEach(t => {
        const grades = termBuckets[t];
        const sum = grades.reduce((a, b) => a + b, 0);
        termGradeSum[t] = sum;
        terms[t] = {
          avgGrade: grades.length > 0 ? sum / grades.length : null,
          count: grades.length,
        };
      });

      const ytdSum = allGrades.reduce((a, b) => a + b, 0);
      courseTermDataMap.set(courseId, {
        course,
        terms,
        termGradeSum,
        ytd: {
          avgGrade: allGrades.length > 0 ? ytdSum / allGrades.length : null,
          count: totalCount,
        },
        ytdGradeSum: ytdSum,
      });
    });

    const groupMap = new Map<string, CourseTermData[]>();
    courseTermDataMap.forEach((ctd) => {
      const groupName = ctd.course.subjectGroup || "Other";
      const list = groupMap.get(groupName) || [];
      list.push(ctd);
      groupMap.set(groupName, list);
    });

    const groupOrder = [
      "Core Academic Studies",
      "Christian Studies",
      "Core Expanded Studies",
      "Applied Studies",
      "Coursework",
    ];

    const blocks: CategoryBlock[] = [];
    const processedGroups = new Set<string>();

    function buildBlock(groupName: string, coursesInGroup: CourseTermData[]): CategoryBlock {
      coursesInGroup.sort((a, b) => (a.course.level ?? 0) - (b.course.level ?? 0));

      const avgTerms: Record<number, TermData> = {};
      TERMS.forEach(t => {
        const totalGradeSum = coursesInGroup.reduce((sum, c) => sum + c.termGradeSum[t], 0);
        const totalCount = coursesInGroup.reduce((sum, c) => sum + c.terms[t].count, 0);
        avgTerms[t] = {
          avgGrade: totalCount > 0 ? totalGradeSum / totalCount : null,
          count: totalCount,
        };
      });

      const ytdGradeSum = coursesInGroup.reduce((sum, c) => sum + c.ytdGradeSum, 0);
      const ytdCount = coursesInGroup.reduce((sum, c) => sum + c.ytd.count, 0);

      return {
        name: groupName,
        courses: coursesInGroup,
        avgTerms,
        avgYtd: {
          avgGrade: ytdCount > 0 ? ytdGradeSum / ytdCount : null,
          count: ytdCount,
        },
      };
    }

    groupOrder.forEach(groupName => {
      const coursesInGroup = groupMap.get(groupName);
      if (!coursesInGroup || coursesInGroup.length === 0) return;
      processedGroups.add(groupName);
      blocks.push(buildBlock(groupName, coursesInGroup));
    });

    groupMap.forEach((coursesInGroup, groupName) => {
      if (processedGroups.has(groupName)) return;
      blocks.push(buildBlock(groupName, coursesInGroup));
    });

    return blocks;
  }, [enrollments, courses, courseMap, datesMap]);

  const sortedStudents = useMemo(() => {
    if (!students) return [];
    return [...students].sort((a, b) => {
      if (a.active !== b.active) return a.active ? -1 : 1;
      return a.callName.localeCompare(b.callName);
    });
  }, [students]);

  const today = new Date().toLocaleDateString("en-GB", { day: "2-digit", month: "long", year: "numeric" });

  if (studentsLoading) {
    return (
      <div className="yr-page">
        <Skeleton className="h-8 w-48" />
        <Skeleton className="h-12 w-64" />
        <Skeleton className="h-96 w-full" />
      </div>
    );
  }

  return (
    <div className="p-4 md:p-6 space-y-4" data-testid="spc-page">
      <div className="flex items-center gap-4 flex-wrap print:hidden">
        <Select value={selectedStudentId} onValueChange={setSelectedStudentId}>
          <SelectTrigger className="w-[280px]" data-testid="select-student">
            <SelectValue placeholder="Choose a student..." />
          </SelectTrigger>
          <SelectContent>
            {sortedStudents.map(s => (
              <SelectItem key={s.id} value={String(s.id)} data-testid={`option-student-${s.id}`}>
                {s.callName} {s.surname}{!s.active ? " (inactive)" : ""}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        {selectedStudent && (
          <button
            className="text-sm text-muted-foreground underline hover:text-foreground print:hidden"
            onClick={() => window.print()}
            data-testid="button-print"
          >
            Print Report
          </button>
        )}
      </div>

      {!selectedStudent && (
        <div className="yr-page">
          <p className="text-center text-muted-foreground py-20 text-lg">Select a student above to view their Year Report.</p>
        </div>
      )}

      {selectedStudent && enrollmentsLoading && (
        <div className="yr-page">
          <Skeleton className="h-[100px] w-full" />
          <Skeleton className="h-[100px] w-full mt-4" />
          <Skeleton className="h-[300px] w-full mt-4" />
          <Skeleton className="h-[200px] w-full mt-4" />
        </div>
      )}

      {selectedStudent && enrollments && !enrollmentsLoading && (
        <div className="yr-page" data-testid="year-report">
          {/* Title Section */}
          <div className="yr-title" data-testid="yr-title">
            <div className="yr-logo">
              <span className="yr-logo-text" data-testid="text-logo">Ceder</span>
            </div>
            <div className="yr-report-center">
              <span className="yr-report-heading" data-testid="text-report-title">Year Report</span>
              <span className="yr-school-name" data-testid="text-school-name">{SCHOOL_NAME}</span>
            </div>
            <div className="yr-report-right">
              <span className="yr-year" data-testid="text-year">{yearTerm}</span>
              <span className="yr-terms-label" data-testid="text-terms">Terms 1–5</span>
            </div>
          </div>

          {/* Info Section */}
          <div className="yr-info" data-testid="yr-info">
            <div className="yr-info-panel">
              <div className="yr-info-row">
                <span className="yr-info-label">Student</span>
                <span className="yr-info-value" data-testid="text-student-name">{selectedStudent.callName} {selectedStudent.surname}</span>
              </div>
              <div className="yr-info-row-sm">
                <span className="yr-info-label">Group</span>
                <span className="yr-info-value" data-testid="text-group">—</span>
              </div>
            </div>
            <div className="yr-info-panel">
              <div className="yr-info-row">
                <span className="yr-info-label yr-info-label-wide">Report Date</span>
                <span className="yr-info-value" data-testid="text-report-date">{today}</span>
              </div>
              <div className="yr-info-row-sm">
                <span className="yr-info-label yr-info-label-wide">Supervisor</span>
                <span className="yr-info-value" data-testid="text-supervisor">—</span>
              </div>
            </div>
          </div>

          {/* Category Header Row */}
          <div className="yr-category-header-row" data-testid="yr-header-row">
            <div className="yr-course-name-col">&nbsp;</div>
            {TERMS.map(t => (
              <div key={t} className="yr-term-header-group">
                <span className="yr-term-label">Term {t}</span>
                <span className="yr-count-header">&nbsp;</span>
              </div>
            ))}
            <div className="yr-term-header-group">
              <span className="yr-term-label">Year to Date</span>
              <span className="yr-count-header">&nbsp;</span>
            </div>
          </div>

          {/* Category Blocks */}
          {categoryBlocks.length === 0 && (
            <div className="yr-empty" data-testid="yr-empty">
              No enrollments found for {selectedStudent.callName}. Add enrollments on the Enrollments page first.
            </div>
          )}

          {categoryBlocks.map((block, blockIdx) => (
            <div key={blockIdx}>
              <div className="yr-category-block" data-testid={`yr-block-${blockIdx}`}>
                <div className="yr-category-header">
                  <span className="yr-category-name" data-testid={`text-category-${blockIdx}`}>{block.name}</span>
                </div>

                {block.courses.map((ctd, courseIdx) => (
                  <div
                    key={ctd.course.id}
                    className={`yr-course-row ${courseIdx % 2 === 1 ? "yr-course-row-alt" : ""}`}
                    data-testid={`yr-course-${ctd.course.id}`}
                  >
                    <div className="yr-course-name-col" title={ctd.course.aceAlias || ctd.course.course || ""}>
                      {ctd.course.certificateName || ctd.course.icceAlias || ctd.course.aceAlias || ctd.course.course || `Course ${ctd.course.id}`}
                    </div>
                    {TERMS.map(t => (
                      <div key={t} className="yr-term-cell-group">
                        <span className="yr-grade-cell" data-testid={`grade-${ctd.course.id}-t${t}`}>
                          {formatGrade(ctd.terms[t]?.avgGrade)}
                        </span>
                        <span className="yr-count-cell" data-testid={`count-${ctd.course.id}-t${t}`}>
                          {ctd.terms[t]?.count > 0 ? ctd.terms[t].count : ""}
                        </span>
                      </div>
                    ))}
                    <div className="yr-term-cell-group">
                      <span className="yr-grade-cell yr-grade-ytd" data-testid={`grade-${ctd.course.id}-ytd`}>
                        {formatGrade(ctd.ytd.avgGrade)}
                      </span>
                      <span className="yr-count-cell" data-testid={`count-${ctd.course.id}-ytd`}>
                        {ctd.ytd.count > 0 ? ctd.ytd.count : ""}
                      </span>
                    </div>
                  </div>
                ))}

                {/* Average/Total Row */}
                <div className="yr-course-row yr-avg-row" data-testid={`yr-avg-${blockIdx}`}>
                  <div className="yr-course-name-col yr-avg-label">Average / Total</div>
                  {TERMS.map(t => (
                    <div key={t} className="yr-term-cell-group">
                      <span className="yr-grade-cell">{formatGrade(block.avgTerms[t]?.avgGrade)}</span>
                      <span className="yr-count-cell">{block.avgTerms[t]?.count > 0 ? block.avgTerms[t].count : ""}</span>
                    </div>
                  ))}
                  <div className="yr-term-cell-group">
                    <span className="yr-grade-cell yr-grade-ytd">{formatGrade(block.avgYtd.avgGrade)}</span>
                    <span className="yr-count-cell">{block.avgYtd.count > 0 ? block.avgYtd.count : ""}</span>
                  </div>
                </div>
              </div>
              <div className="yr-block-spacer" />
            </div>
          ))}

          {/* Behavioral Assessment - Side by Side */}
          <div className="yr-relation-row" data-testid="yr-relation">
            <div className="yr-relation-block">
              <div className="yr-category-header">
                <span className="yr-category-name">In Relation to Work</span>
                {TERMS.map(t => (
                  <span key={t} className="yr-progress-term-header">T{t}</span>
                ))}
              </div>
              {["Goal setting", "Effort / diligence", "Responsibility", "Initiative", "Character", "Time management", "Quality of work"].map((item, i) => (
                <div key={i} className="yr-progress-row">
                  <span className="yr-progress-label">{item}</span>
                  {TERMS.map(t => (
                    <span key={t} className="yr-progress-grade" data-testid={`work-${i}-t${t}`}>&nbsp;</span>
                  ))}
                </div>
              ))}
            </div>
            <div className="yr-relation-block">
              <div className="yr-category-header">
                <span className="yr-category-name">In Relation to Others</span>
                {TERMS.map(t => (
                  <span key={t} className="yr-progress-term-header">T{t}</span>
                ))}
              </div>
              {["Cooperation", "Respect for authority", "Respect for others", "Self-control", "Helpfulness", "Courtesy", "Honesty"].map((item, i) => (
                <div key={i} className="yr-progress-row">
                  <span className="yr-progress-label">{item}</span>
                  {TERMS.map(t => (
                    <span key={t} className="yr-progress-grade" data-testid={`others-${i}-t${t}`}>&nbsp;</span>
                  ))}
                </div>
              ))}
            </div>
          </div>

          <div className="yr-block-spacer" />

          {/* Signatures */}
          <div className="yr-signatures" data-testid="yr-signatures">
            <div className="yr-signature-box">
              <span className="yr-signature-label">Principal</span>
            </div>
            <div className="yr-signature-box">
              <span className="yr-signature-label">Supervisor</span>
            </div>
            <div className="yr-signature-box">
              <span className="yr-signature-label">Parent / Guardian</span>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
