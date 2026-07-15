import "./index.css";
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { RouterProvider } from "react-router-dom";
import { Toaster } from "@/components/ui/sonner";
import { router } from "./app/router.tsx";
import SystemProvider from "./powersync/SystemProvider.tsx";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <SystemProvider>
      <RouterProvider router={router} />
      <Toaster />
    </SystemProvider>
  </StrictMode>
);
