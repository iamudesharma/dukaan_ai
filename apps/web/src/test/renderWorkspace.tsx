import { render } from "@testing-library/react";
import type { ReactNode } from "react";
import { WorkspaceProvider } from "../app/WorkspaceContext";
import type { Bootstrap } from "../types";
import { bootstrap as defaultBootstrap } from "./apiMocks";
import { TestProviders } from "./TestProviders";

export function renderWithWorkspace(ui: ReactNode, workspace: Bootstrap = defaultBootstrap) {
  return render(
    <TestProviders>
      <WorkspaceProvider bootstrap={workspace}>{ui}</WorkspaceProvider>
    </TestProviders>,
  );
}
