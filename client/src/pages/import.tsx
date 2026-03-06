import { useState, useCallback } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useToast } from "@/hooks/use-toast";
import { apiRequest, queryClient } from "@/lib/queryClient";
import type { Student, Subject, Term } from "@shared/schema";
import { Upload, FileSpreadsheet, CheckCircle2, AlertTriangle } from "lucide-react";

export default function ImportPage() {
  const { toast } = useToast();
  const [parsedData, setParsedData] = useState<any>(null);
  const [selectedSheet, setSelectedSheet] = useState<string>("");
  const [mapping, setMapping] = useState<Record<string, string>>({});
  const [fileName, setFileName] = useState<string>("");

  const { data: students } = useQuery<Student[]>({ queryKey: ["/api/students"] });
  const { data: subjects } = useQuery<Subject[]>({ queryKey: ["/api/subjects"] });
  const { data: terms } = useQuery<Term[]>({ queryKey: ["/api/terms"] });

  const uploadMutation = useMutation({
    mutationFn: async (file: File) => {
      const formData = new FormData();
      formData.append("file", file);
      const res = await fetch("/api/upload/excel", {
        method: "POST",
        body: formData,
        credentials: "include",
      });
      if (!res.ok) throw new Error(await res.text());
      return res.json();
    },
    onSuccess: (data) => {
      setParsedData(data);
      if (data.sheets.length > 0) setSelectedSheet(data.sheets[0]);
      toast({ title: "File parsed successfully" });
    },
    onError: () => toast({ title: "Failed to parse file", variant: "destructive" }),
  });

  const importMutation = useMutation({
    mutationFn: async (rows: any[]) => {
      const res = await apiRequest("POST", "/api/import/grades", { rows });
      return res.json();
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["/api/grades"] });
      queryClient.invalidateQueries({ queryKey: ["/api/dashboard/stats"] });
      toast({ title: `Imported ${data.imported} of ${data.total} grades` });
    },
    onError: () => toast({ title: "Import failed", variant: "destructive" }),
  });

  const handleFileChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setFileName(file.name);
      uploadMutation.mutate(file);
    }
  }, []);

  const sheetData = parsedData?.data?.[selectedSheet] || [];
  const columns = sheetData.length > 0 ? Object.keys(sheetData[0]) : [];

  const handleImport = () => {
    if (!mapping.score || !mapping.studentId || !mapping.subjectId || !mapping.termId) {
      toast({ title: "Please map all required columns", variant: "destructive" });
      return;
    }

    const rows = sheetData.map((row: any) => ({
      studentId: parseInt(row[mapping.studentId]),
      subjectId: parseInt(row[mapping.subjectId]),
      termId: parseInt(row[mapping.termId]),
      score: parseInt(row[mapping.score]),
      maxScore: mapping.maxScore ? parseInt(row[mapping.maxScore]) : 100,
      comment: mapping.comment ? row[mapping.comment] : null,
    })).filter((r: any) => !isNaN(r.score) && !isNaN(r.studentId));

    importMutation.mutate(rows);
  };

  return (
    <div className="p-6 max-w-4xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Import Data</h1>
        <p className="text-muted-foreground mt-1">Upload Excel files to import grades and student data.</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2">
            <FileSpreadsheet className="w-5 h-5" />
            Upload Excel File
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="border-2 border-dashed rounded-md p-8 text-center space-y-4">
            <Upload className="w-10 h-10 text-muted-foreground mx-auto" />
            <div>
              <label htmlFor="file-upload" className="cursor-pointer">
                <Button variant="secondary" asChild>
                  <span data-testid="button-upload">Choose File</span>
                </Button>
              </label>
              <input
                id="file-upload"
                type="file"
                accept=".xlsx,.xls,.csv"
                onChange={handleFileChange}
                className="hidden"
                data-testid="input-file"
              />
            </div>
            {fileName && (
              <p className="text-sm text-muted-foreground">
                Selected: <span className="font-medium">{fileName}</span>
              </p>
            )}
            {uploadMutation.isPending && <p className="text-sm text-muted-foreground">Parsing file...</p>}
          </div>
        </CardContent>
      </Card>

      {parsedData && (
        <>
          <Card>
            <CardHeader>
              <CardTitle className="text-base">File Summary</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex flex-wrap gap-2">
                {parsedData.sheets.map((sheet: string) => (
                  <Badge
                    key={sheet}
                    variant={selectedSheet === sheet ? "default" : "secondary"}
                    className="cursor-pointer"
                    onClick={() => setSelectedSheet(sheet)}
                    data-testid={`badge-sheet-${sheet}`}
                  >
                    {sheet} ({parsedData.rowCounts[sheet]} rows)
                  </Badge>
                ))}
              </div>

              {sheetData.length > 0 && (
                <div className="overflow-x-auto max-h-64 border rounded-md">
                  <table className="w-full text-xs" data-testid="table-preview">
                    <thead className="sticky top-0 bg-card">
                      <tr className="border-b">
                        {columns.map(col => (
                          <th key={col} className="text-left py-2 px-3 font-medium text-muted-foreground">{col}</th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {sheetData.slice(0, 10).map((row: any, i: number) => (
                        <tr key={i} className="border-b last:border-0">
                          {columns.map(col => (
                            <td key={col} className="py-2 px-3">{String(row[col] ?? "")}</td>
                          ))}
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="text-base">Column Mapping</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="text-sm text-muted-foreground">Map your Excel columns to the grade data fields.</p>
              <div className="grid sm:grid-cols-2 gap-4">
                {[
                  { key: "studentId", label: "Student ID", required: true },
                  { key: "subjectId", label: "Subject ID", required: true },
                  { key: "termId", label: "Term ID", required: true },
                  { key: "score", label: "Score", required: true },
                  { key: "maxScore", label: "Max Score", required: false },
                  { key: "comment", label: "Comment", required: false },
                ].map(field => (
                  <div key={field.key} className="space-y-1.5">
                    <label className="text-sm font-medium">
                      {field.label} {field.required && <span className="text-destructive">*</span>}
                    </label>
                    <Select
                      value={mapping[field.key] || ""}
                      onValueChange={v => setMapping(p => ({ ...p, [field.key]: v }))}
                    >
                      <SelectTrigger data-testid={`select-map-${field.key}`}>
                        <SelectValue placeholder="Select column" />
                      </SelectTrigger>
                      <SelectContent>
                        {columns.map(col => (
                          <SelectItem key={col} value={col}>{col}</SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                ))}
              </div>

              <Button
                onClick={handleImport}
                disabled={importMutation.isPending}
                data-testid="button-import"
              >
                {importMutation.isPending ? "Importing..." : "Import Grades"}
              </Button>
            </CardContent>
          </Card>
        </>
      )}

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Reference IDs</CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          <div>
            <h4 className="text-sm font-medium mb-2">Students</h4>
            <div className="overflow-x-auto max-h-40 border rounded-md">
              <table className="w-full text-xs">
                <thead className="sticky top-0 bg-card">
                  <tr className="border-b">
                    <th className="text-left py-2 px-3 font-medium text-muted-foreground">ID</th>
                    <th className="text-left py-2 px-3 font-medium text-muted-foreground">Name</th>
                  </tr>
                </thead>
                <tbody>
                  {students?.map(s => (
                    <tr key={s.id} className="border-b last:border-0">
                      <td className="py-1.5 px-3 font-mono">{s.id}</td>
                      <td className="py-1.5 px-3">{s.firstName} {s.lastName}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
          <div>
            <h4 className="text-sm font-medium mb-2">Subjects</h4>
            <div className="overflow-x-auto max-h-40 border rounded-md">
              <table className="w-full text-xs">
                <thead className="sticky top-0 bg-card">
                  <tr className="border-b">
                    <th className="text-left py-2 px-3 font-medium text-muted-foreground">ID</th>
                    <th className="text-left py-2 px-3 font-medium text-muted-foreground">Subject</th>
                    <th className="text-left py-2 px-3 font-medium text-muted-foreground">Code</th>
                  </tr>
                </thead>
                <tbody>
                  {subjects?.map(s => (
                    <tr key={s.id} className="border-b last:border-0">
                      <td className="py-1.5 px-3 font-mono">{s.id}</td>
                      <td className="py-1.5 px-3">{s.name}</td>
                      <td className="py-1.5 px-3 text-muted-foreground">{s.code}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
          <div>
            <h4 className="text-sm font-medium mb-2">Terms</h4>
            <div className="overflow-x-auto max-h-40 border rounded-md">
              <table className="w-full text-xs">
                <thead className="sticky top-0 bg-card">
                  <tr className="border-b">
                    <th className="text-left py-2 px-3 font-medium text-muted-foreground">ID</th>
                    <th className="text-left py-2 px-3 font-medium text-muted-foreground">Term</th>
                    <th className="text-left py-2 px-3 font-medium text-muted-foreground">Year</th>
                  </tr>
                </thead>
                <tbody>
                  {terms?.map(t => (
                    <tr key={t.id} className="border-b last:border-0">
                      <td className="py-1.5 px-3 font-mono">{t.id}</td>
                      <td className="py-1.5 px-3">{t.name}</td>
                      <td className="py-1.5 px-3 text-muted-foreground">{t.year}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
