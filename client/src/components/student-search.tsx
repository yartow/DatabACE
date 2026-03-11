import { Input } from "@/components/ui/input";
import { useState, useMemo, useRef, useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import type { Student } from "@shared/schema";

interface StudentSearchProps {
  onSelect: (student: Student) => void;
  selectedStudent?: Student | null;
  placeholder?: string;
  className?: string;
}

export function StudentSearch({ onSelect, selectedStudent, placeholder = "Type student name to search...", className = "" }: StudentSearchProps) {
  const [query, setQuery] = useState(selectedStudent ? `${selectedStudent.callName} ${selectedStudent.surname}` : "");
  const [open, setOpen] = useState(false);
  const [highlightIndex, setHighlightIndex] = useState(-1);
  const inputRef = useRef<HTMLInputElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const listRef = useRef<HTMLDivElement>(null);

  const { data: students } = useQuery<Student[]>({ queryKey: ["/api/students"] });

  useEffect(() => {
    if (selectedStudent) {
      setQuery(`${selectedStudent.callName} ${selectedStudent.surname}`);
    }
  }, [selectedStudent]);

  const suggestions = useMemo(() => {
    if (!students || query.length < 1) return [];
    const selectedName = selectedStudent ? `${selectedStudent.callName} ${selectedStudent.surname}` : "";
    if (query === selectedName) return [];
    const q = query.toLowerCase();
    return students.filter(s =>
      s.callName.toLowerCase().includes(q) ||
      s.surname.toLowerCase().includes(q) ||
      s.alias.toLowerCase().includes(q) ||
      (s.firstNames?.toLowerCase().includes(q))
    ).slice(0, 10);
  }, [students, query, selectedStudent]);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (containerRef.current && !containerRef.current.contains(e.target as Node)) {
        setOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  useEffect(() => {
    if (highlightIndex >= 0 && listRef.current) {
      const items = listRef.current.querySelectorAll("[data-suggestion]");
      if (items[highlightIndex]) {
        items[highlightIndex].scrollIntoView({ block: "nearest" });
      }
    }
  }, [highlightIndex]);

  function handleKeyDown(e: React.KeyboardEvent) {
    if (!open) return;
    if (e.key === "Escape") {
      e.preventDefault();
      setOpen(false);
      setHighlightIndex(-1);
      return;
    }
    if (suggestions.length === 0) return;
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setHighlightIndex(prev => (prev + 1) % suggestions.length);
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setHighlightIndex(prev => (prev - 1 + suggestions.length) % suggestions.length);
    } else if (e.key === "Enter" && highlightIndex >= 0 && highlightIndex < suggestions.length) {
      e.preventDefault();
      const s = suggestions[highlightIndex];
      onSelect(s);
      setQuery(`${s.callName} ${s.surname}`);
      setOpen(false);
      setHighlightIndex(-1);
    }
  }

  function handleSelect(s: Student) {
    onSelect(s);
    setQuery(`${s.callName} ${s.surname}`);
    setOpen(false);
    setHighlightIndex(-1);
  }

  return (
    <div className={`relative ${className}`} ref={containerRef}>
      <Input
        ref={inputRef}
        placeholder={placeholder}
        value={query}
        onChange={e => {
          setQuery(e.target.value);
          setOpen(e.target.value.length >= 1);
          setHighlightIndex(-1);
        }}
        onFocus={() => { if (query.length >= 1 && query !== (selectedStudent ? `${selectedStudent.callName} ${selectedStudent.surname}` : "")) setOpen(true); }}
        onKeyDown={handleKeyDown}
        className="w-full"
        data-testid="input-student-search"
      />
      {open && suggestions.length > 0 && (
        <div
          ref={listRef}
          className="absolute z-50 top-full left-0 mt-1 w-full bg-popover border rounded-md shadow-lg max-h-[300px] overflow-y-auto"
          data-testid="dropdown-student-suggestions"
          onMouseDown={e => e.preventDefault()}
        >
          {suggestions.map((s, i) => (
            <button
              key={s.id}
              type="button"
              data-suggestion
              className={`w-full text-left px-4 py-2.5 text-sm flex items-center justify-between gap-2 first:rounded-t-md last:rounded-b-md transition-colors ${
                highlightIndex === i
                  ? "bg-primary text-primary-foreground"
                  : "hover:bg-muted"
              }`}
              onClick={() => handleSelect(s)}
              data-testid={`suggestion-student-${s.id}`}
            >
              <span className="font-medium">{s.callName} {s.surname}</span>
              <span className={`text-xs ${highlightIndex === i ? "text-primary-foreground/70" : "text-muted-foreground"}`}>
                {s.group || ""}{s.alias ? ` · ${s.alias}` : ""}
              </span>
            </button>
          ))}
        </div>
      )}
      {open && query.length >= 1 && suggestions.length === 0 && (
        <div className="absolute z-50 top-full left-0 mt-1 w-full bg-popover border rounded-md shadow-lg p-3 text-sm text-muted-foreground">
          No students found matching "{query}"
        </div>
      )}
    </div>
  );
}
