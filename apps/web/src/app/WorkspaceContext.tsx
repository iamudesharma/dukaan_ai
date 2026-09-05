import {
  createContext,
  useContext,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import type { Bootstrap } from "../types";

interface WorkspaceValue {
  bootstrap: Bootstrap;
  locationId: string;
  setLocationId: (locationId: string) => void;
  assistantOpen: boolean;
  openAssistant: () => void;
  closeAssistant: () => void;
}

const WorkspaceContext = createContext<WorkspaceValue | null>(null);

export function WorkspaceProvider({ bootstrap, children }: { bootstrap: Bootstrap; children: ReactNode }) {
  const [locationId, setLocationId] = useState(bootstrap.locations[0]?.id ?? "");
  const [assistantOpen, setAssistantOpen] = useState(false);
  const value = useMemo<WorkspaceValue>(
    () => ({
      bootstrap,
      locationId,
      setLocationId,
      assistantOpen,
      openAssistant: () => setAssistantOpen(true),
      closeAssistant: () => setAssistantOpen(false),
    }),
    [assistantOpen, bootstrap, locationId],
  );
  return <WorkspaceContext.Provider value={value}>{children}</WorkspaceContext.Provider>;
}

export function useWorkspace(): WorkspaceValue {
  const context = useContext(WorkspaceContext);
  if (!context) throw new Error("useWorkspace must be used within WorkspaceProvider");
  return context;
}
