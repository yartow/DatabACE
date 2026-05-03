import { useEffect, useState, useCallback } from "react";
import { WifiOff, RefreshCw, CheckCircle } from "lucide-react";
import { useQueryClient } from "@tanstack/react-query";
import {
  getQueuedMutations,
  removeQueuedMutation,
  type QueuedMutation,
} from "@/lib/offline";

type SyncState = "idle" | "syncing" | "done" | "error";

export function OfflineBanner() {
  const [isOnline, setIsOnline] = useState(() =>
    typeof navigator !== "undefined" ? navigator.onLine : true,
  );
  const [queue, setQueue] = useState<QueuedMutation[]>([]);
  const [syncState, setSyncState] = useState<SyncState>("idle");
  const queryClient = useQueryClient();

  useEffect(() => {
    const on = () => setIsOnline(true);
    const off = () => setIsOnline(false);
    window.addEventListener("online", on);
    window.addEventListener("offline", off);
    return () => {
      window.removeEventListener("online", on);
      window.removeEventListener("offline", off);
    };
  }, []);

  // Refresh queue count whenever we go online or offline
  useEffect(() => {
    getQueuedMutations().then(setQueue).catch(() => {});
  }, [isOnline]);

  const sync = useCallback(async () => {
    if (!isOnline || queue.length === 0) return;
    setSyncState("syncing");
    let failed = false;
    const remaining: QueuedMutation[] = [];
    for (const m of queue) {
      try {
        const res = await fetch(m.url, {
          method: m.method,
          headers: { "Content-Type": "application/json" },
          credentials: "include",
          body: JSON.stringify(m.body),
        });
        if (res.ok) {
          await removeQueuedMutation(m.id!);
        } else {
          remaining.push(m);
          failed = true;
        }
      } catch {
        remaining.push(m);
        failed = true;
      }
    }
    setQueue(remaining);
    setSyncState(failed ? "error" : "done");
    // Invalidate caches so pages show fresh data
    queryClient.invalidateQueries();
    if (!failed) setTimeout(() => setSyncState("idle"), 3000);
  }, [isOnline, queue, queryClient]);

  // Auto-sync when coming back online
  useEffect(() => {
    if (isOnline && queue.length > 0) sync();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isOnline]);

  if (isOnline && syncState === "idle") return null;

  if (isOnline && syncState === "done") {
    return (
      <div className="fixed top-0 left-0 right-0 z-[100] bg-green-600 text-white text-sm font-medium px-4 py-2.5 flex items-center gap-2 justify-center shadow-md">
        <CheckCircle className="w-4 h-4 flex-shrink-0" />
        <span>Back online — all changes saved.</span>
      </div>
    );
  }

  if (isOnline && syncState === "syncing") {
    return (
      <div className="fixed top-0 left-0 right-0 z-[100] bg-blue-600 text-white text-sm font-medium px-4 py-2.5 flex items-center gap-2 justify-center shadow-md">
        <RefreshCw className="w-4 h-4 flex-shrink-0 animate-spin" />
        <span>Syncing changes…</span>
      </div>
    );
  }

  if (isOnline && syncState === "error") {
    return (
      <div className="fixed top-0 left-0 right-0 z-[100] bg-red-600 text-white text-sm font-medium px-4 py-2.5 flex items-center gap-2 justify-center shadow-md">
        <WifiOff className="w-4 h-4 flex-shrink-0" />
        <span>Some changes could not be saved. Tap to retry.</span>
        <button
          onClick={sync}
          className="underline font-semibold ml-1 focus:outline-none"
        >
          Retry
        </button>
      </div>
    );
  }

  // Offline state
  return (
    <div className="fixed top-0 left-0 right-0 z-[100] bg-amber-500 text-white text-sm font-medium px-4 py-2.5 flex items-center gap-2 justify-center shadow-md">
      <WifiOff className="w-4 h-4 flex-shrink-0" />
      <span>
        You&apos;re offline — showing cached data.
        {queue.length > 0 &&
          ` ${queue.length} unsaved change${queue.length > 1 ? "s" : ""} will sync when reconnected.`}
      </span>
    </div>
  );
}
