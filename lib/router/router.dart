import 'package:file_sharing/features/dashboard/pages/files/files_page.dart';
import 'package:file_sharing/features/dashboard/pages/lecturers/lecturers_page.dart';
import 'package:file_sharing/features/dashboard/pages/offices/offices_page.dart';
import 'package:file_sharing/router/router_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/views/forget_password_page.dart';
import '../features/auth/views/login_page.dart';
import '../features/auth/views/registration_page.dart';
import '../features/dashboard/pages/home/views/dashboard_home.dart';
import '../features/dashboard/views/dashboard_main.dart';
import '../features/details/file_details_page.dart';
import '../features/main/views/container_page.dart';

class MyRouter {
  MyRouter({
    required this.ref,
    required this.context,
  });

  final BuildContext context;
  final WidgetRef ref;

  router() => GoRouter(
          initialLocation: RouterItem.loginRoute.path,
          redirect: (context, state) {
            var route = state.fullPath;
            //check if widget is done building
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (route != null && route.isNotEmpty) {
                var item = RouterItem.getRouteByPath(route);
                ref.read(routerProvider.notifier).state = item.name;
              }
            });
            return null;
          },
          routes: [
            ShellRoute(
                builder: (context, state, child) {
                  return ContainerPage(
                    child: child,
                  );
                },
                routes: [
                  GoRoute(
                      path: RouterItem.loginRoute.path,
                      builder: (context, state) {
                        return const LoginPage();
                      }),
                  GoRoute(
                      path: RouterItem.registerRoute.path,
                      builder: (context, state) {
                        return const RegistrationPage();
                      }),
                  GoRoute(
                      path: RouterItem.forgotPasswordRoute.path,
                      builder: (context, state) {
                        return const ForgetPasswordPage();
                      }),
                ]),
            ShellRoute(
                builder: (context, state, child) {
                  return DashBoardMainPage(
                    child,
                  );
                },
                routes: [
                  GoRoute(
                      path: RouterItem.dashboardRoute.path,
                      builder: (context, state) {
                        return const DashboardHomePage();
                      }),
                  GoRoute(
                      path: RouterItem.filesRoute.path,
                      builder: (context, state) {
                        return const FilesPage();
                      }),
                  GoRoute(
                      path: RouterItem.officesRoute.path,
                      builder: (context, state) {
                        return const OfficesPage();
                      }),
                  GoRoute(
                      path: RouterItem.lecturersRoute.path,
                      builder: (context, state) {
                        return const LecturersPage();
                      }),
                  GoRoute(
                      path: RouterItem.fileDetailsRouter.path,
                      name: RouterItem.fileDetailsRouter.name,
                      builder: (context, state) {
                        var id = state.pathParameters['fileId'];
                        return  FileDetailsPage(fileId: id!,);
                      }),
                ])
          ]);

  void navigateToRoute(RouterItem item) {
    ref.read(routerProvider.notifier).state = item.name;
    context.go(item.path);
  }

  void navigateToNamed(
      {required Map<String, String> pathPrams,
      required RouterItem item,
      Map<String, dynamic>? extra}) {
    ref.read(routerProvider.notifier).state = item.name;
    context.goNamed(item.name, pathParameters: pathPrams, extra: extra);
  }
}

final routerProvider = StateProvider<String>((ref) {
  return RouterItem.loginRoute.name;
});
