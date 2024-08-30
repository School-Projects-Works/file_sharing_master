import 'package:data_table_2/data_table_2.dart';
import 'package:file_sharing/features/dashboard/pages/offices/new_office_provider.dart';
import 'package:file_sharing/features/files/provider/file_provider.dart';
import 'package:file_sharing/features/offices/provider/office_provider.dart';
import 'package:file_sharing/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/views/custom_button.dart';
import '../../../../core/views/custom_dialog.dart';
import '../../../../core/views/custom_input.dart';
import '../../../../utils/colors.dart';

class OfficesPage extends ConsumerStatefulWidget {
  const OfficesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OfficesPageState();
}

class _OfficesPageState extends ConsumerState<OfficesPage> {
  @override
  Widget build(BuildContext context) {
    var styles = Styles(context);
    var titleStyles = styles.title(color: Colors.white, fontSize: 15);
    var rowStyles = styles.body(fontSize: 13);
    var offices = ref.watch(officesProvider).filteredItems.toList();
    var files = ref.watch(filesProvider).items.toList();
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Offices'.toUpperCase(),
            style: styles.title(fontSize: 35, color: primaryColor),
          ),
          const SizedBox(
            height: 20,
          ),
          if (!ref.watch(isNewOffice) &&
              ref.watch(editOfficeProvider).id.isEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: styles.width * .5,
                  child: CustomTextFields(
                    hintText: 'Search office',
                    onChanged: (query) {
                      ref.read(officesProvider.notifier).filterItems(query);
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CustomButton(
                  text: 'New Office',
                  onPressed: () {
                    ref.read(isNewOffice.notifier).state = true;
                    ref.read(editOfficeProvider.notifier).reset();
                  },
                )
              ],
            ),
          if (ref.watch(isNewOffice)) _buildAddOffice(),
          if (ref.watch(editOfficeProvider).id.isNotEmpty)
            _buildEditAffiliation(),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: DataTable2(
              columnSpacing: 30,
              horizontalMargin: 12,
              empty: Center(
                  child: Text(
                'No Office added',
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
                  label: Text('Office Name'.toUpperCase()),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text('Office Email'.toUpperCase()),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text('Office Phone'.toUpperCase()),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text('Total Files'.toUpperCase()),
                  size: ColumnSize.M,
                  numeric: true,
                  fixedWidth: styles.isMobile ? null : 200,
                ),
                DataColumn2(
                  label: Text('Action'.toUpperCase()),
                  size: ColumnSize.S,
                  fixedWidth: styles.isMobile ? null : 150,
                ),
              ],
              rows: List<DataRow>.generate(offices.length, (index) {
                var office = offices[index];
                var officeFiles = files
                    .where((element) => element.usersIds.contains(office.id))
                    .toList();
                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}', style: rowStyles)),
                    DataCell(Text(office.name, style: rowStyles)),
                    DataCell(Text(office.officeEmail, style: rowStyles)),
                    DataCell(Text(office.officePhone, style: rowStyles)),
                    DataCell(
                        Text(officeFiles.length.toString(), style: rowStyles)),
                    DataCell(
                      Row(
                        children: [
                          //edit
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              ref
                                  .read(editOfficeProvider.notifier)
                                  .setOffice(office);
                              ref.read(isNewOffice.notifier).state = false;
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              CustomDialogs.showDialog(
                                message:
                                    'Are you sure you want to delete this Office?',
                                secondBtnText: 'Delete',
                                type: DialogType.warning,
                                onConfirm: () {
                                  ref
                                      .read(officesProvider.notifier)
                                      .delete(office, ref);
                                },
                              );
                            },
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

  final _formKey = GlobalKey<FormState>();

  Widget _buildAddOffice() {
    var notifier = ref.read(newOfficeProvider.notifier);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: secondaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Form(
                  key: _formKey,
                  child: Wrap(runSpacing: 20, spacing: 10, children: [
                    SizedBox(
                      width: 350,
                      child: CustomTextFields(
                        hintText: 'Office Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Office name is required';
                          }
                          return null;
                        },
                        onSaved: (name) {
                          notifier.setName(name!);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 350,
                      child: CustomTextFields(
                        hintText: 'Office email',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Office email is required';
                          }
                          return null;
                        },
                        onSaved: (name) {
                          notifier.setEmail(name!);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: CustomTextFields(
                        hintText: 'Office Phone',
                        isPhoneInput: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Office Phone is required';
                          } else if (value.length < 10) {
                            return 'phone must be 10 digits';
                          }
                          return null;
                        },
                        onSaved: (contact) {
                          notifier.setPhone(contact!);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: CustomButton(
                        text: 'Save',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            notifier.saveOffice(ref);
                            _formKey.currentState!.reset();
                          }
                        },
                      ),
                    )
                  ]))),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(isNewOffice.notifier).state = false;
            },
          )
        ],
      ),
    );
  }

  final _edtFormKey = GlobalKey<FormState>();
  Widget _buildEditAffiliation() {
    var notifier = ref.read(editOfficeProvider.notifier);
    var provider = ref.watch(editOfficeProvider);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: secondaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Form(
                  key: _edtFormKey,
                  child: Wrap(runSpacing: 20, spacing: 10, children: [
                    SizedBox(
                      width: 350,
                      child: CustomTextFields(
                        hintText: 'Office Name',
                        initialValue: provider.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Office name is required';
                          }
                          return null;
                        },
                        onSaved: (name) {
                          notifier.setName(name!);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 350,
                      child: CustomTextFields(
                        hintText: 'Office email',
                        initialValue: provider.officeEmail,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Office email is required';
                          }
                          return null;
                        },
                        onSaved: (name) {
                          notifier.setEmail(name!);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: CustomTextFields(
                        hintText: 'Office Phone',
                        initialValue: provider.officePhone,
                        isPhoneInput: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Office Phone is required';
                          } else if (value.length < 10) {
                            return 'phone must be 10 digits';
                          }
                          return null;
                        },
                        onSaved: (contact) {
                          notifier.setPhone(contact!);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: CustomButton(
                        text: 'Update',
                        onPressed: () {
                          if (_edtFormKey.currentState!.validate()) {
                            _edtFormKey.currentState!.save();
                            notifier.updateOffice(ref);
                            _edtFormKey.currentState!.reset();
                          }
                        },
                      ),
                    )
                  ]))),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(isNewOffice.notifier).state = false;
              ref.read(editOfficeProvider.notifier).reset();
            },
          )
        ],
      ),
    );
  }
}

final isNewOffice = StateProvider<bool>((ref) => false);
