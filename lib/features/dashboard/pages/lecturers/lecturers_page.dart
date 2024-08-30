import 'package:data_table_2/data_table_2.dart';
import 'package:file_sharing/features/users/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/views/custom_dialog.dart';
import '../../../../core/views/custom_input.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/styles.dart';

class LecturersPage extends ConsumerStatefulWidget {
  const LecturersPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LecturersPageState();
}

class _LecturersPageState extends ConsumerState<LecturersPage> {
  @override
  Widget build(BuildContext context) {
    var styles = Styles(context);
    var titleStyles = styles.title(color: Colors.white, fontSize: 15);
    var rowStyles = styles.body(fontSize: 13);
    var lecturers = ref.watch(usersProvider).filteredItems.toList();
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lecturers & Other Users'.toUpperCase(),
            style: styles.title(fontSize: 35, color: primaryColor),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: styles.width * .5,
                child: CustomTextFields(
                  hintText: 'Search a Secretary',
                  onChanged: (query) {
                    ref.read(usersProvider.notifier).filterItems(query);
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: DataTable2(
              columnSpacing: 30,
              horizontalMargin: 12,
              empty: Center(
                  child: Text(
                'No Lecturer found',
                style: rowStyles,
              )),
              minWidth: 600,
              headingRowColor: WidgetStateColor.resolveWith(
                  (states) => primaryColor.withOpacity(0.6)),
              headingTextStyle: titleStyles,
              columns: [
                DataColumn2(
                    label: Text(
                      'INDEX',
                      style: titleStyles,
                    ),
                    fixedWidth: styles.largerThanMobile ? 80 : null),
                
                DataColumn2(
                  label: Text('Name'.toUpperCase()),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text('email'.toUpperCase()),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                    label: Text('Phone'.toUpperCase()),
                    size: ColumnSize.M,
                    fixedWidth: styles.isMobile ? null : 100),
                
                DataColumn2(
                  label: Text('Status'.toUpperCase()),
                  size: ColumnSize.S,
                  fixedWidth: styles.isMobile ? null : 100,
                ),
                DataColumn2(
                  label: Text('Action'.toUpperCase()),
                  size: ColumnSize.S,
                  fixedWidth: styles.isMobile ? null : 150,
                ),
              ],
              rows: List<DataRow>.generate(lecturers.length, (index) {
                var lecturer = lecturers[index];
                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}', style: rowStyles)),
                    DataCell(Text(lecturer.name, style: rowStyles)),
                    DataCell(Text(lecturer.email, style: rowStyles)),
                    DataCell(Text(lecturer.phone, style: rowStyles)),
                   DataCell(Container(
                        width: 90,
                        // alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        decoration: BoxDecoration(
                            color: lecturer.status == 'active'
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(5)),
                        child: Text(lecturer.status,
                            style: rowStyles.copyWith(color: Colors.white)))),
                    DataCell(
                      Row(
                        children: [
                          //icon button to block and unblock user
                          if (lecturer.status == 'active')
                            IconButton(
                              onPressed: () {
                                CustomDialogs.showDialog(
                                    message:
                                        'Are you sure you want to block ${lecturer.name}?',
                                    secondBtnText: 'Block',
                                    onConfirm: () {
                                      ref
                                          .read(usersProvider.notifier)
                                          .block(lecturer);
                                    });
                              },
                              icon: const Icon(
                                Icons.block,
                                color: Colors.red,
                              ),
                            ),
                          if (lecturer.status == 'banned')
                            IconButton(
                              onPressed: () {
                                CustomDialogs.showDialog(
                                    message:
                                        'Are you sure you want to unblock ${lecturer.name}?',
                                    secondBtnText: 'Unblock',
                                    onConfirm: () {
                                      ref
                                          .read(usersProvider.notifier)
                                          .unblock(lecturer);
                                    });
                              },
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}
