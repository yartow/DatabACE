import { useQuery } from "@tanstack/react-query";
import { Skeleton } from "@/components/ui/skeleton";
import { useState, useMemo, useEffect, useRef, useCallback } from "react";
import type { Student, Course, Enrollment, DateEntry, Personnel, SupplementaryActivity, UserProfile } from "@shared/schema";
import cederLogoPath from "@assets/cederlogo_basic_v2017_1_1773068129584.png";
import { Download } from "lucide-react";
import { Button } from "@/components/ui/button";
import { StudentSearch } from "@/components/student-search";

const TERMS = [1, 2, 3, 4, 5];
const SCHOOL_NAME = "ICS De Ceder \u2013 Boskoop";

const NEDERLANDS_COURSES = ["Taal", "Spelling", "Lezen", "Taal (PACE)", "Spelling (PACE)"];

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
  showAverages: boolean;
}

export default function ReportsPage() {
  const [selectedStudentId, setSelectedStudentId] = useState<string>("");

  const { data: profile } = useQuery<UserProfile>({ queryKey: ["/api/profile"] });
  const { data: students, isLoading: studentsLoading } = useQuery<Student[]>({ queryKey: ["/api/students"] });
  const { data: courses, isLoading: coursesLoading } = useQuery<Course[]>({ queryKey: ["/api/courses"] });
  const { data: allDates } = useQuery<DateEntry[]>({ queryKey: ["/api/dates"] });
  const { data: personnelList } = useQuery<Personnel[]>({ queryKey: ["/api/personnel"] });

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

  const { data: suppActivities } = useQuery<SupplementaryActivity[]>({
    queryKey: ["/api/supplementary-activities", selectedStudentId],
    queryFn: async () => {
      const res = await fetch(`/api/supplementary-activities?studentId=${selectedStudentId}`, { credentials: "include" });
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
    if (!allDates) return "25\u201326";
    const withYt = allDates.find(d => d.yearTerm);
    return withYt?.yearTerm || "25\u201326";
  }, [allDates]);

  const supervisor = useMemo(() => {
    if (!selectedStudent?.group || !personnelList) return null;
    return personnelList.find(p => p.group === selectedStudent.group && p.rank === 1) || null;
  }, [selectedStudent, personnelList]);

  const categoryBlocks = useMemo((): CategoryBlock[] => {
    if (!enrollments || !courses) return [];

    const getTermForEnrollment = (e: Enrollment): number | null => {
      if (!e.dateStarted) return null;
      const dateEntry = datesMap.get(e.dateStarted);
      return dateEntry?.term ?? null;
    };

    const courseEnrollments = new Map<number, Enrollment[]>();
    const seenKeys = new Set<string>();
    enrollments.forEach(e => {
      const key = `${e.courseId}|${e.number}|${e.dateStarted ?? ""}|${e.grade ?? ""}`;
      if (seenKeys.has(key)) return;
      seenKeys.add(key);
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

    const academicCourses: CourseTermData[] = [];
    const nederlandsCourses: CourseTermData[] = [];

    courseTermDataMap.forEach((ctd) => {
      const courseName = ctd.course.icceAlias || "";
      if (NEDERLANDS_COURSES.includes(courseName)) {
        nederlandsCourses.push(ctd);
      } else {
        academicCourses.push(ctd);
      }
    });

    function buildBlock(groupName: string, coursesInGroup: CourseTermData[], showAverages: boolean): CategoryBlock {
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
        showAverages,
      };
    }

    const blocks: CategoryBlock[] = [];

    if (academicCourses.length > 0) {
      blocks.push(buildBlock("Academic Studies", academicCourses, true));
    }

    if (nederlandsCourses.length > 0) {
      blocks.push(buildBlock("Nederlands", nederlandsCourses, true));
    }

    return blocks;
  }, [enrollments, courses, courseMap, datesMap]);

  const suppBlock = useMemo(() => {
    if (!suppActivities || suppActivities.length === 0) return null;
    const uniqueActivities = [...new Set(suppActivities.map(sa => sa.activity))];
    return uniqueActivities;
  }, [suppActivities]);

  const suppTermData = useMemo(() => {
    if (!suppActivities) return new Map<string, Record<number, string>>();
    const map = new Map<string, Record<number, string>>();
    suppActivities.forEach(sa => {
      if (!map.has(sa.activity)) map.set(sa.activity, {});
      const termMap = map.get(sa.activity)!;
      if (sa.term && sa.grade) {
        termMap[sa.term] = sa.grade;
      }
    });
    return map;
  }, [suppActivities]);

  const sortedStudents = useMemo(() => {
    if (!students) return [];
    return [...students].sort((a, b) => {
      if (profile?.role === "parent") {
        if (a.dateOfBirth && b.dateOfBirth) return a.dateOfBirth.localeCompare(b.dateOfBirth);
        if (a.dateOfBirth) return -1;
        if (b.dateOfBirth) return 1;
        return a.callName.localeCompare(b.callName);
      }
      if (a.active !== b.active) return a.active ? -1 : 1;
      return a.callName.localeCompare(b.callName);
    });
  }, [students, profile]);

  useEffect(() => {
    if (!selectedStudentId && sortedStudents.length > 0 && profile?.role === "parent") {
      setSelectedStudentId(String(sortedStudents[0].id));
    }
  }, [sortedStudents, selectedStudentId, profile]);

  const today = new Date().toLocaleDateString("en-GB", { day: "2-digit", month: "long", year: "numeric" });

  const reportRef = useRef<HTMLDivElement>(null);
  const [downloading, setDownloading] = useState(false);

  const handleDownloadPdf = useCallback(async () => {
    const el = reportRef.current;
    if (!el || !selectedStudent) return;
    setDownloading(true);
    try {
      const html2canvas = (await import("html2canvas")).default;
      const { jsPDF } = await import("jspdf");

      const clone = el.cloneNode(true) as HTMLElement;
      clone.style.position = "absolute";
      clone.style.left = "-9999px";
      clone.style.top = "0";
      clone.style.width = "1256px";
      clone.style.maxWidth = "1256px";
      clone.style.overflow = "visible";

      clone.querySelectorAll<HTMLElement>(".yr-course-name-col, .yr-category-name, .yr-progress-label").forEach(n => {
        n.style.overflow = "visible";
        n.style.whiteSpace = "nowrap";
        n.style.textOverflow = "clip";
      });

      document.body.appendChild(clone);

      const canvas = await html2canvas(clone, {
        scale: 2,
        useCORS: true,
        backgroundColor: "#ffffff",
        width: 1256,
        windowWidth: 1280,
        logging: false,
      });

      document.body.removeChild(clone);

      const margin = 8;
      const a4W = 210;
      const a4H = 297;
      const contentW = a4W - margin * 2;
      const contentH = a4H - margin * 2;

      const pxToMm = 25.4 / 96 / 2;
      const imgW_mm = canvas.width * pxToMm;
      const imgH_mm = canvas.height * pxToMm;

      const scale = Math.min(contentW / imgW_mm, contentH / imgH_mm);

      const finalW = imgW_mm * scale;
      const finalH = imgH_mm * scale;

      const xOff = margin + (contentW - finalW) / 2;
      const yOff = margin + (contentH - finalH) / 2;

      const pdf = new jsPDF({ orientation: "portrait", unit: "mm", format: "a4" });
      pdf.addImage(canvas.toDataURL("image/png"), "PNG", xOff, yOff, finalW, finalH);

      const studentName = `${selectedStudent.callName}_${selectedStudent.surname}`.replace(/\s+/g, "_");
      pdf.save(`Year_Report_${studentName}_${yearTerm}.pdf`);
    } catch (err) {
      console.error("PDF generation failed:", err);
    } finally {
      setDownloading(false);
    }
  }, [selectedStudent, yearTerm]);

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
    <div className="p-4 md:p-6 space-y-4" data-testid="reports-page">
      <div className="flex items-center gap-4 flex-wrap print:hidden">
        <StudentSearch
          onSelect={(s) => setSelectedStudentId(String(s.id))}
          selectedStudent={selectedStudent}
          className="w-[320px]"
        />
        {selectedStudent && (
          <>
            <button
              className="text-sm text-muted-foreground underline hover:text-foreground print:hidden"
              onClick={() => window.print()}
              data-testid="button-print"
            >
              Print Report
            </button>
            <Button
              variant="outline"
              size="sm"
              className="print:hidden"
              onClick={handleDownloadPdf}
              disabled={downloading}
              data-testid="button-download-pdf"
            >
              <Download className="w-4 h-4 mr-1.5" />
              {downloading ? "Generating..." : "Download PDF"}
            </Button>
          </>
        )}
      </div>

      {!selectedStudent && (
        <div className="yr-page">
          <p className="text-center text-muted-foreground py-20 text-lg">Select a student above to view their Year Report.</p>
        </div>
      )}

      {selectedStudent && (enrollmentsLoading || coursesLoading) && (
        <div className="yr-page">
          <Skeleton className="h-[100px] w-full" />
          <Skeleton className="h-[100px] w-full mt-4" />
          <Skeleton className="h-[300px] w-full mt-4" />
          <Skeleton className="h-[200px] w-full mt-4" />
        </div>
      )}

      {selectedStudent && enrollments && courses && !enrollmentsLoading && !coursesLoading && (
        <div className="yr-page" data-testid="year-report" ref={reportRef}>
          <div className="yr-title" data-testid="yr-title">
            <div className="yr-logo">
              <img src={cederLogoPath} alt="de Ceder" className="yr-logo-img" data-testid="text-logo" />
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

          <div className="yr-info" data-testid="yr-info">
            <div className="yr-info-panel">
              <div className="yr-info-row">
                <span className="yr-info-label">Student</span>
                <span className="yr-info-value" data-testid="text-student-name">{selectedStudent.callName} {selectedStudent.surname}</span>
              </div>
              <div className="yr-info-row-sm">
                <span className="yr-info-label">Group</span>
                <span className="yr-info-value" data-testid="text-group">{selectedStudent.group || "—"}</span>
              </div>
            </div>
            <div className="yr-info-panel">
              <div className="yr-info-row">
                <span className="yr-info-label yr-info-label-wide">Report Date</span>
                <span className="yr-info-value" data-testid="text-report-date">{today}</span>
              </div>
              <div className="yr-info-row-sm">
                <span className="yr-info-label yr-info-label-wide">Supervisor</span>
                <span className="yr-info-value" data-testid="text-supervisor">
                  {supervisor ? `${supervisor.firstName} ${supervisor.lastName}` : "—"}
                </span>
              </div>
            </div>
          </div>

          <div className="yr-category-header-row" data-testid="yr-header-row">
            <div className="yr-course-name-col">&nbsp;</div>
            {TERMS.map(t => (
              <div key={t} className="yr-term-header-group">
                <span className="yr-term-label">Term {t}</span>
                <span className="yr-count-header">&nbsp;</span>
              </div>
            ))}
            <div className="yr-term-header-group">
              <span className="yr-term-label" style={{ whiteSpace: "nowrap" }}>Year to Date</span>
              <span className="yr-count-header">&nbsp;</span>
            </div>
          </div>

          {categoryBlocks.length === 0 && !suppBlock && (
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
                    <div className="yr-course-name-col" title={ctd.course.icceAlias || ctd.course.aceAlias || ""}>
                      {ctd.course.certificateName || ctd.course.icceAlias || ctd.course.aceAlias || `Course ${ctd.course.id}`}
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

                {block.showAverages && (
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
                )}
              </div>
              <div className="yr-block-spacer" />
            </div>
          ))}

          {suppBlock && suppBlock.length > 0 && (
            <div>
              <div className="yr-category-block" data-testid="yr-block-supplementary">
                <div className="yr-category-header">
                  <span className="yr-category-name" data-testid="text-category-supplementary">Supplementary Activities</span>
                </div>
                {suppBlock.map((activity, actIdx) => (
                  <div
                    key={activity}
                    className={`yr-course-row ${actIdx % 2 === 1 ? "yr-course-row-alt" : ""}`}
                    data-testid={`yr-supp-${actIdx}`}
                  >
                    <div className="yr-course-name-col">{activity}</div>
                    {TERMS.map(t => (
                      <div key={t} className="yr-term-cell-group">
                        <span className="yr-grade-cell" data-testid={`supp-grade-${actIdx}-t${t}`}>
                          {suppTermData.get(activity)?.[t] || ""}
                        </span>
                        <span className="yr-count-cell"></span>
                      </div>
                    ))}
                    <div className="yr-term-cell-group">
                      <span className="yr-grade-cell"></span>
                      <span className="yr-count-cell"></span>
                    </div>
                  </div>
                ))}
              </div>
              <div className="yr-block-spacer" />
            </div>
          )}

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
