import { useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useState } from "react";
import { Download, Table2, ShieldAlert } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import type { UserProfile } from "@shared/schema";

const EXPORT_TABLES = [
  { key: "students", label: "Students", endpoint: "/api/students" },
  { key: "courses", label: "Courses", endpoint: "/api/courses" },
  { key: "paces", label: "PACEs", endpoint: "/api/paces" },
  { key: "pace-courses", label: "PACE-Courses", endpoint: "/api/pace-courses" },
  { key: "subjects", label: "Subjects", endpoint: "/api/subjects" },
  { key: "subject-groups", label: "Subject Groups", endpoint: "/api/subject-groups" },
  { key: "personnel", label: "Personnel", endpoint: "/api/personnel" },
  { key: "families", label: "Families", endpoint: "/api/families" },
  { key: "parents", label: "Parents", endpoint: "/api/parents" },
  { key: "dates", label: "Dates", endpoint: "/api/dates" },
];

function toCsv(data: Record<string, any>[]): string {
  if (data.length === 0) return "";
  const headers = Object.keys(data[0]);
  const escape = (val: any) => {
    if (val == null) return "";
    const str = String(val);
    if (str.includes(",") || str.includes('"') || str.includes("\n")) {
      return `"${str.replace(/"/g, '""')}"`;
    }
    return str;
  };
  const lines = [
    headers.join(","),
    ...data.map(row => headers.map(h => escape(row[h])).join(","))
  ];
  return lines.join("\n");
}

function downloadCsv(csv: string, filename: string) {
  const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}

export default function ExportPage() {
  const { toast } = useToast();
  const { data: profile } = useQuery<UserProfile>({ queryKey: ["/api/profile"] });
  const [selectedTable, setSelectedTable] = useState("");
  const [exporting, setExporting] = useState(false);
  const [preview, setPreview] = useState<Record<string, any>[] | null>(null);

  if (profile && profile.role !== "teacher") {
    return (
      <div className="p-6 max-w-4xl mx-auto space-y-6">
        <div className="flex flex-col items-center justify-center py-12 text-center">
          <ShieldAlert className="w-12 h-12 text-muted-foreground mb-4" />
          <h2 className="text-xl font-semibold" data-testid="text-access-denied">Access Denied</h2>
          <p className="text-muted-foreground mt-2">Only teachers can export data.</p>
        </div>
      </div>
    );
  }

  const handleExport = async () => {
    const table = EXPORT_TABLES.find(t => t.key === selectedTable);
    if (!table) return;

    setExporting(true);
    try {
      const res = await fetch(table.endpoint, { credentials: "include" });
      if (!res.ok) throw new Error("Failed to fetch data");
      const data = await res.json();
      if (!Array.isArray(data) || data.length === 0) {
        toast({ title: "No data", description: `The ${table.label} table is empty.`, variant: "destructive" });
        setPreview(null);
        return;
      }
      setPreview(data.slice(0, 5));
      const csv = toCsv(data);
      downloadCsv(csv, `${table.key}_export.csv`);
      toast({ title: "Export complete", description: `${data.length} rows exported to ${table.key}_export.csv` });
    } catch (err: any) {
      toast({ title: "Export failed", description: err.message, variant: "destructive" });
    } finally {
      setExporting(false);
    }
  };

  return (
    <div className="p-6 max-w-4xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Export Data</h1>
        <p className="text-muted-foreground mt-1">Export any table to CSV format.</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2">
            <Table2 className="w-4 h-4" />
            Select Table
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-end gap-4">
            <div className="space-y-1.5 flex-1">
              <label className="text-sm font-medium">Table</label>
              <Select value={selectedTable} onValueChange={v => { setSelectedTable(v); setPreview(null); }}>
                <SelectTrigger data-testid="select-export-table">
                  <SelectValue placeholder="Choose a table to export..." />
                </SelectTrigger>
                <SelectContent>
                  {EXPORT_TABLES.map(t => (
                    <SelectItem key={t.key} value={t.key}>{t.label}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <Button
              onClick={handleExport}
              disabled={!selectedTable || exporting}
              data-testid="button-export-csv"
            >
              <Download className="w-4 h-4 mr-2" />
              {exporting ? "Exporting..." : "Export CSV"}
            </Button>
          </div>

          {preview && preview.length > 0 && (
            <div className="mt-4">
              <p className="text-sm font-medium text-muted-foreground mb-2">Preview (first 5 rows)</p>
              <div className="overflow-x-auto border rounded-lg">
                <table className="w-full text-xs" data-testid="table-export-preview">
                  <thead>
                    <tr className="border-b bg-muted/30">
                      {Object.keys(preview[0]).map(h => (
                        <th key={h} className="text-left py-2 px-3 font-medium text-muted-foreground whitespace-nowrap">{h}</th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {preview.map((row, i) => (
                      <tr key={i} className="border-b last:border-0">
                        {Object.values(row).map((val, j) => (
                          <td key={j} className="py-2 px-3 whitespace-nowrap max-w-[200px] truncate">
                            {val != null ? String(val) : "—"}
                          </td>
                        ))}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
