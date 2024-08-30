import 'package:file_sharing/features/files/provider/file_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/views/custom_dialog.dart';
import '../../../generated/assets.dart';
import '../../../router/router.dart';
import '../../../router/router_items.dart';
import '../../../utils/colors.dart';
import '../../../utils/styles.dart';
import '../../auth/provider/user_provider.dart';
import '../../main/components/app_bar_item.dart';
import '../../offices/provider/office_provider.dart';
import '../../users/provider/user_provider.dart';
import 'components/side_bar.dart';

class DashBoardMainPage extends ConsumerWidget {
  const DashBoardMainPage(this.child, {super.key});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var styles = Styles(context);
    var user = ref.watch(userProvider);
    var userStream = ref.watch(userStreamProvider);
    var filesStream = ref.watch(fileStreamProvider);
    var offices = ref.watch(officesStreamProvider);
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            actions: [
              const SizedBox(width: 10),
              PopupMenuButton(
                  color: primaryColor,
                  offset: const Offset(0, 70),
                  child: CircleAvatar(
                    backgroundColor: secondaryColor,
                    backgroundImage: () {
                      return const AssetImage(Assets.imagesProfile);
                    }(),
                  ),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: BarItem(
                            padding: const EdgeInsets.only(
                                right: 40, top: 10, bottom: 10, left: 10),
                            icon: Icons.logout,
                            title: 'Logout',
                            onTap: () {
                              CustomDialogs.showDialog(
                                message: 'Are you sure you want to logout?',
                                type: DialogType.info,
                                secondBtnText: 'Logout',
                                onConfirm: () {
                                  ref
                                      .read(userProvider.notifier)
                                      .logout(context: context, ref: ref);
                                  Navigator.of(context).pop();
                                },
                              );
                            }),
                      ),
                    ];
                  }),
              const SizedBox(width: 10),
            ],
            title: Row(
              children: [
                Image.asset(
                  Assets.imageLogoWhite,
                  height: 60,
                ),
                const SizedBox(width: 10),
                if (styles.smallerThanTablet)
                  if (user.role.toLowerCase() == 'admin')
                    buildAdminMenu(ref, context)
                  else if (user.role.toLowerCase() == 'office')
                    buildOfficeMenu(ref, context)
                  else if (user.role.toLowerCase() == 'lecturer')
                    buildLecturerMenu(ref, context)
              ],
            ),
          ),
          body: Container(
            color: Colors.white60,
            padding: const EdgeInsets.all(4),
            child: styles.smallerThanTablet
                ? child
                : Row(
                    children: [
                      const SideBar(),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: Container(
                              color: Colors.grey[100],
                              padding: const EdgeInsets.all(10),
                              child: filesStream.when(
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (error, stack) {
                                  return Center(child: Text(error.toString()));
                                },
                                data: (data) {
                                  return userStream.when(
                                      data: (user) {
                                        return offices.when(
                                            data: (offices) {
                                              return child;
                                            },
                                            error: (error, stack) {
                                              return Center(
                                                  child: Text(error.toString()));
                                            },
                                            loading: () =>
                                                const Center(child: CircularProgressIndicator()));
                                      
                                      },
                                      error: (error, stack) {
                                        return Center(
                                            child: Text(error.toString()));
                                      },
                                      loading: () => const Center(
                                          child: CircularProgressIndicator()));
                                },
                              )))
                    ],
                  ),
          )),
    );
  }

  Widget buildAdminMenu(WidgetRef ref, BuildContext context) {
    return PopupMenuButton(
      color: primaryColor,
      offset: const Offset(0, 70),
      child: const Icon(
        Icons.menu,
        color: Colors.white,
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            child: BarItem(
                padding: const EdgeInsets.only(
                    right: 40, top: 10, bottom: 10, left: 10),
                icon: Icons.dashboard,
                title: 'Dashboard',
                onTap: () {
                  MyRouter(context: context, ref: ref)
                      .navigateToRoute(RouterItem.dashboardRoute);
                  Navigator.of(context).pop();
                }),
          ),
          PopupMenuItem(
            child: BarItem(
                padding: const EdgeInsets.only(
                    right: 40, top: 10, bottom: 10, left: 10),
                icon: Icons.hotel,
                title: 'Offices',
                onTap: () {
                  MyRouter(context: context, ref: ref)
                      .navigateToRoute(RouterItem.officesRoute);
                  Navigator.of(context).pop();
                }),
          ),
          PopupMenuItem(
            child: BarItem(
                padding: const EdgeInsets.only(
                    right: 40, top: 10, bottom: 10, left: 10),
                icon: Icons.people,
                title: 'Lecturers',
                onTap: () {
                  MyRouter(context: context, ref: ref)
                      .navigateToRoute(RouterItem.lecturersRoute);
                  Navigator.of(context).pop();
                }),
          ),
          PopupMenuItem(
            child: BarItem(
                padding: const EdgeInsets.only(
                    right: 40, top: 10, bottom: 10, left: 10),
                icon: Icons.file_copy,
                title: 'Files',
                onTap: () {
                  MyRouter(context: context, ref: ref)
                      .navigateToRoute(RouterItem.filesRoute);
                  Navigator.of(context).pop();
                }),
          ),
        ];
      },
    );
  }

  Widget buildOfficeMenu(WidgetRef ref, BuildContext context) {
    return PopupMenuButton(
        color: primaryColor,
        offset: const Offset(0, 70),
        child: const Icon(
          Icons.menu,
          color: Colors.white,
        ),
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              child: BarItem(
                  padding: const EdgeInsets.only(
                      right: 40, top: 10, bottom: 10, left: 10),
                  icon: Icons.notifications,
                  title: 'Files',
                  onTap: () {
                    MyRouter(context: context, ref: ref)
                        .navigateToRoute(RouterItem.filesRoute);
                    Navigator.of(context).pop();
                  }),
            ),
          ];
        });
  }

  Widget buildLecturerMenu(WidgetRef ref, BuildContext context) {
    return PopupMenuButton(
        color: primaryColor,
        offset: const Offset(0, 70),
        child: const Icon(
          Icons.menu,
          color: Colors.white,
        ),
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              child: BarItem(
                  padding: const EdgeInsets.only(
                      right: 40, top: 10, bottom: 10, left: 10),
                  icon: Icons.file_copy,
                  title: 'Files',
                  onTap: () {
                    MyRouter(context: context, ref: ref)
                        .navigateToRoute(RouterItem.filesRoute);
                    Navigator.of(context).pop();
                  }),
            ),
          ];
        });
  }
}
