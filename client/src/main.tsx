import { createRoot } from "react-dom/client";
import { PersistQueryClientProvider } from "@tanstack/react-query-persist-client";
import App from "./App";
import { queryClient } from "@/lib/queryClient";
import { idbPersister } from "@/lib/offline";
import "./index.css";

createRoot(document.getElementById("root")!).render(
  <PersistQueryClientProvider
    client={queryClient}
    persistOptions={{
      persister: idbPersister,
      maxAge: 7 * 24 * 60 * 60 * 1000,
      dehydrateOptions: {
        shouldDehydrateQuery: (query) =>
          query.state.status === "success" && !query.queryKey.includes("admin"),
      },
    }}
  >
    <App />
  </PersistQueryClientProvider>,
);

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/sw.js").catch(() => {});
  });
}
