import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../router/router.dart';
import '../../../../router/router_items.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/styles.dart';
import '../../../auth/provider/user_provider.dart';
import 'side_bar_item.dart';

class SideBar extends ConsumerWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var styles = Styles(context);
    var user = ref.watch(userProvider);
    return Container(
        width: 200,
        height: styles.height,
        color: primaryColor,
        child: Column(children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
                text: TextSpan(
                    text: 'Hello, \n',
                    style: styles.body(
                      color: Colors.white38,
                    ),
                    children: [
                  TextSpan(
                      text: ref.watch(userProvider).name,
                      style: styles.subtitle(
                        fontWeight: FontWeight.bold,
                        fontSize: styles.isDesktop ? 20 : 16,
                        color: Colors.white,
                      ))
                ])),
          ),
          const SizedBox(
            height: 25,
          ),
          Expanded(
            child: user.role == 'admin'
                ? buildAdminMenu(ref, context)
                : 
                    buildLecturerMenu(ref, context)
                    
          ),
          // footer
          Text('© 2024 All rights reserved',
              style: styles.body(color: Colors.white38, fontSize: 12)),
        ]));
  }

  Widget buildAdminMenu(WidgetRef ref, BuildContext context) {
    return Column(
      children: [
        SideBarItem(
          title: 'Dashboard',
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          icon: Icons.dashboard,
          isActive: ref.watch(routerProvider) == RouterItem.dashboardRoute.name,
          onTap: () {
            MyRouter(context: context, ref: ref)
                .navigateToRoute(RouterItem.dashboardRoute);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SideBarItem(
            title: 'Offices',
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            icon: Icons.hotel,
            isActive: ref.watch(routerProvider) == RouterItem.officesRoute.name,
            onTap: () {
              MyRouter(context: context, ref: ref)
                  .navigateToRoute(RouterItem.officesRoute);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SideBarItem(
            title: 'Lecturers',
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            icon: Icons.people,
            isActive:
                ref.watch(routerProvider) == RouterItem.lecturersRoute.name,
            onTap: () {
              MyRouter(context: context, ref: ref)
                  .navigateToRoute(RouterItem.lecturersRoute);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SideBarItem(
            title: 'Files',
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            icon: Icons.notifications,
            isActive: ref.watch(routerProvider) == RouterItem.filesRoute.name,
            onTap: () {
              MyRouter(context: context, ref: ref)
                  .navigateToRoute(RouterItem.filesRoute);
            },
          ),
        ),
        ],
    );
  }


  Widget buildLecturerMenu(WidgetRef ref, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SideBarItem(
            title: 'Files',
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            icon: Icons.file_copy_sharp,
            isActive: ref.watch(routerProvider) == RouterItem.filesRoute.name,
            onTap: () {
              MyRouter(context: context, ref: ref)
                  .navigateToRoute(RouterItem.filesRoute);
            },
          ),
        ),
        //profile
       
      ],
    );
  }
}
