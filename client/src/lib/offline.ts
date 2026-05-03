import { openDB } from "idb";
import type { PersistedClient, Persister } from "@tanstack/react-query-persist-client";

const DB_NAME = "ceder-offline";
const DB_VERSION = 2;
const STORE_QUERY_CACHE = "queryCache";
const STORE_MUTATION_QUEUE = "mutationQueue";

function getDB() {
  return openDB(DB_NAME, DB_VERSION, {
    upgrade(db, oldVersion) {
      if (oldVersion < 1) {
        db.createObjectStore(STORE_QUERY_CACHE);
        const mq = db.createObjectStore(STORE_MUTATION_QUEUE, {
          keyPath: "id",
          autoIncrement: true,
        });
        mq.createIndex("timestamp", "timestamp");
      }
      if (oldVersion < 2) {
        if (!db.objectStoreNames.contains(STORE_MUTATION_QUEUE)) {
          const mq = db.createObjectStore(STORE_MUTATION_QUEUE, {
            keyPath: "id",
            autoIncrement: true,
          });
          mq.createIndex("timestamp", "timestamp");
        }
      }
    },
  });
}

// --- TanStack Query IDB persister ---

export const idbPersister: Persister = {
  persistClient: async (client: PersistedClient) => {
    try {
      const db = await getDB();
      await db.put(STORE_QUERY_CACHE, client, "cache");
    } catch {
      // Storage quota exceeded or private browsing — silently ignore
    }
  },
  restoreClient: async (): Promise<PersistedClient | undefined> => {
    try {
      const db = await getDB();
      return await db.get(STORE_QUERY_CACHE, "cache");
    } catch {
      return undefined;
    }
  },
  removeClient: async () => {
    try {
      const db = await getDB();
      await db.delete(STORE_QUERY_CACHE, "cache");
    } catch {
      // ignore
    }
  },
};

// --- Offline mutation queue ---

export type QueuedMutation = {
  id?: number;
  method: string;
  url: string;
  body: unknown;
  timestamp: number;
  description: string;
};

export async function queueMutation(
  m: Omit<QueuedMutation, "id" | "timestamp">,
): Promise<void> {
  const db = await getDB();
  await db.add(STORE_MUTATION_QUEUE, { ...m, timestamp: Date.now() });
}

export async function getQueuedMutations(): Promise<QueuedMutation[]> {
  const db = await getDB();
  return db.getAllFromIndex(STORE_MUTATION_QUEUE, "timestamp");
}

export async function removeQueuedMutation(id: number): Promise<void> {
  const db = await getDB();
  await db.delete(STORE_MUTATION_QUEUE, id);
}

export async function clearMutationQueue(): Promise<void> {
  const db = await getDB();
  await db.clear(STORE_MUTATION_QUEUE);
}
