import 'package:file_sharing/features/files/provider/file_provider.dart';
import 'package:file_sharing/features/offices/provider/office_provider.dart';
import 'package:file_sharing/features/users/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../router/router.dart';
import '../../../../../router/router_items.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/styles.dart';
import '../../../views/components/dasboard_item.dart';

class DashboardHomePage extends ConsumerStatefulWidget {
  const DashboardHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DashboardHomePageState();
}

class _DashboardHomePageState extends ConsumerState<DashboardHomePage> {
  @override
  Widget build(BuildContext context) {
    var style = Styles(context);
    var files = ref.watch(filesProvider);
    var users = ref.watch(usersProvider);
    var officesList = ref.watch(officesProvider);
   
    return Container(
        color: Colors.white,
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const SizedBox(height: 20),
              Text(
                'Dashboard'.toUpperCase(),
                style: style.title(color: primaryColor),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
               
                    DashBoardItem(
                      icon: Icons.people,
                      title: 'Files'.toUpperCase(),
                      itemCount: files.items.length,
                      color: Colors.blue,
                      onTap: () {
                        MyRouter(context: context,ref: ref).navigateToRoute(RouterItem.filesRoute);
                      },
                    ),
                    DashBoardItem(
                      icon: Icons.people_alt_outlined,
                      title: 'Offices'.toUpperCase(),
                      itemCount: officesList.items.length,
                      color: Colors.green,
                      onTap: () {
                        MyRouter(context: context,ref: ref).navigateToRoute(RouterItem.officesRoute);
                      },
                    ),
                  DashBoardItem(
                    icon: Icons.hotel,
                    title: 'Lecturers'.toUpperCase(),
                    itemCount: users.filteredItems.length,
                    color: Colors.orange,
                    onTap: () {
                      MyRouter(context: context,ref: ref).navigateToRoute(RouterItem.lecturersRoute);
                    },
                  ),
                 ],
              ),
            ])));
  }
}
