import { createContext, useContext, useRef, useState } from "react";

type Store = Record<string, any>;

const PersistedStateContext = createContext<{
  get: (key: string) => any;
  set: (key: string, value: any) => void;
}>({
  get: () => undefined,
  set: () => {},
});

export function PersistedStateProvider({ children }: { children: React.ReactNode }) {
  const store = useRef<Store>({});
  const get = (key: string) => store.current[key];
  const set = (key: string, value: any) => { store.current[key] = value; };
  return (
    <PersistedStateContext.Provider value={{ get, set }}>
      {children}
    </PersistedStateContext.Provider>
  );
}

export function usePersistedState<T>(
  key: string,
  defaultValue: T,
): [T, (value: T | ((prev: T) => T)) => void] {
  const { get, set } = useContext(PersistedStateContext);
  const stored = get(key);
  const [state, setStateLocal] = useState<T>(stored !== undefined ? stored : defaultValue);

  const setState = (value: T | ((prev: T) => T)) => {
    setStateLocal(prev => {
      const next = typeof value === "function" ? (value as (prev: T) => T)(prev) : value;
      set(key, next);
      return next;
    });
  };

  return [state, setState];
}
