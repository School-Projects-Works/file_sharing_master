class RouterItem {
  final String path;
  final String name;
  RouterItem({
    required this.path,
    required this.name,
  });

  static final RouterItem loginRoute =
      RouterItem(path: '/login', name: 'login');
  static final RouterItem registerRoute =
      RouterItem(path: '/register', name: 'register');
  static final RouterItem forgotPasswordRoute =
      RouterItem(path: '/forgot-password', name: 'forgotPassword');

//dashboard routes

  static final RouterItem dashboardRoute =
      RouterItem(path: '/dashboard', name: 'dashboard');
  static final RouterItem officesRoute =
      RouterItem(path: '/admin/offices', name: 'officesRoute');
  static final RouterItem filesRoute =
      RouterItem(path: '/files', name: 'files');
  static final RouterItem lecturersRoute =
      RouterItem(path: '/lecturers', name: 'lecturers');

  static final RouterItem fileDetailsRouter =
      RouterItem(name: 'details', path: '/file/:fileId');

  static List<RouterItem> allRoutes = [
    loginRoute,
    dashboardRoute,
    officesRoute,
    registerRoute,
    forgotPasswordRoute,
    fileDetailsRouter,
    filesRoute,
    lecturersRoute
  ];

  static RouterItem getRouteByPath(String fullPath) {
    return allRoutes.firstWhere((element) => element.path == fullPath);
  }
}
