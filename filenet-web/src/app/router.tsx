import { createBrowserRouter, Navigate } from "react-router-dom";
import { RequireAuth } from "@/guards/RequireAuth";
import { RequireActive } from "@/guards/RequireActive";
import { RequireRole } from "@/guards/RequireRole";
import { AppShell } from "@/components/layout/AppShell";
import { LoginPage } from "@/features/auth/LoginPage";
import { RegisterPage } from "@/features/auth/RegisterPage";
import { ForgotPasswordPage } from "@/features/auth/ForgotPasswordPage";
import { DashboardPage } from "@/routes/DashboardPage";
import { FilesPage } from "@/routes/FilesPage";
import { FileDetailPage } from "@/routes/FileDetailPage";
import { SharedPage } from "@/routes/SharedPage";
import { NotificationsPage } from "@/routes/NotificationsPage";
import { GroupsPage } from "@/routes/GroupsPage";
import { AdminDashboardPage } from "@/routes/AdminDashboardPage";
import { AdminUsersPage } from "@/routes/AdminUsersPage";
import { AccountPage } from "@/routes/AccountPage";
import { BlockedPage } from "@/routes/BlockedPage";
import { UnauthorizedPage } from "@/routes/UnauthorizedPage";

export const router = createBrowserRouter([
  { path: "/login", element: <LoginPage /> },
  { path: "/register", element: <RegisterPage /> },
  { path: "/forgot-password", element: <ForgotPasswordPage /> },
  { path: "/blocked", element: <BlockedPage /> },
  { path: "/unauthorized", element: <UnauthorizedPage /> },
  {
    element: <RequireAuth />,
    children: [
      {
        element: <RequireActive />,
        children: [
          {
            element: <AppShell />,
            children: [
              { index: true, element: <Navigate to="/dashboard" replace /> },
              { path: "dashboard", element: <DashboardPage /> },
              { path: "files", element: <FilesPage /> },
              { path: "files/:id", element: <FileDetailPage /> },
              { path: "shared", element: <SharedPage /> },
              { path: "notifications", element: <NotificationsPage /> },
              { path: "account", element: <AccountPage /> },
              {
                element: <RequireRole role="admin" />,
                children: [
                  { path: "groups", element: <GroupsPage /> },
                  { path: "admin/dashboard", element: <AdminDashboardPage /> },
                  { path: "admin/users", element: <AdminUsersPage /> },
                ],
              },
            ],
          },
        ],
      },
    ],
  },
]);
