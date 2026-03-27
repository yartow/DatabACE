import { useState, useCallback } from "react";
import { useMutation, useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { useToast } from "@/hooks/use-toast";
import { Upload, FileSpreadsheet, ShieldAlert } from "lucide-react";
import type { UserProfile } from "@shared/schema";

export default function ImportPage() {
  const { data: profile } = useQuery<UserProfile>({ queryKey: ["/api/profile"] });

  if (profile && (!profile.isAdmin || profile.role !== "teacher")) {
    return (
      <div className="p-6 max-w-4xl mx-auto space-y-6">
        <div className="flex flex-col items-center justify-center py-12 text-center">
          <ShieldAlert className="w-12 h-12 text-muted-foreground mb-4" />
          <h2 className="text-xl font-semibold">Access Denied</h2>
          <p className="text-muted-foreground mt-2">Only admins can import data.</p>
        </div>
      </div>
    );
  }
  const { toast } = useToast();
  const [parsedData, setParsedData] = useState<any>(null);
  const [selectedSheet, setSelectedSheet] = useState<string>("");
  const [fileName, setFileName] = useState<string>("");

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

  const handleFileChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setFileName(file.name);
      uploadMutation.mutate(file);
    }
  }, []);

  const sheetData = parsedData?.data?.[selectedSheet] || [];
  const columns = sheetData.length > 0 ? Object.keys(sheetData[0]) : [];

  return (
    <div className="p-6 max-w-4xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-serif font-bold tracking-tight" data-testid="text-page-title">Import Data</h1>
        <p className="text-muted-foreground mt-1">Upload Excel files to preview and inspect data.</p>
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
              <>
                <p className="text-sm text-muted-foreground">
                  Showing first 20 rows of <strong>{selectedSheet}</strong> ({sheetData.length} total rows, {columns.length} columns)
                </p>
                <div className="overflow-x-auto max-h-96 border rounded-md">
                  <table className="w-full text-xs" data-testid="table-preview">
                    <thead className="sticky top-0 bg-card">
                      <tr className="border-b">
                        {columns.map(col => (
                          <th key={col} className="text-left py-2 px-3 font-medium text-muted-foreground whitespace-nowrap">{col}</th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {sheetData.slice(0, 20).map((row: any, i: number) => (
                        <tr key={i} className="border-b last:border-0">
                          {columns.map(col => (
                            <td key={col} className="py-2 px-3 whitespace-nowrap">{String(row[col] ?? "")}</td>
                          ))}
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </>
            )}
          </CardContent>
        </Card>
      )}
    </div>
  );
}
