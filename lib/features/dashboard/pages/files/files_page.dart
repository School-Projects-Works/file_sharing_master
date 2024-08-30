import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_sharing/core/views/custom_drop_down.dart';
import 'package:file_sharing/features/files/data/file_model.dart';
import 'package:file_sharing/features/files/provider/file_provider.dart';
import 'package:file_sharing/features/users/provider/user_provider.dart';
import 'package:file_sharing/router/router.dart';
import 'package:file_sharing/router/router_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/views/custom_button.dart';
import '../../../../core/views/custom_dialog.dart';
import '../../../../core/views/custom_input.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/styles.dart';
import '../../../auth/provider/user_provider.dart';
import 'new_file_provider.dart';

class FilesPage extends ConsumerStatefulWidget {
  const FilesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FilesPageState();
}

class _FilesPageState extends ConsumerState<FilesPage> {
  @override
  Widget build(BuildContext context) {
    var styles = Styles(context);
    var titleStyles = styles.title(color: Colors.white, fontSize: 15);
    var rowStyles = styles.body(fontSize: 13);
    var files = ref.watch(filesProvider).filteredItems.toList();
    var user = ref.watch(userProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Files'.toUpperCase(),
            style: styles.title(fontSize: 35, color: primaryColor),
          ),
          const SizedBox(
            height: 20,
          ),
          if (!ref.watch(isNewFile) &&
              ref.watch(editFileProvider).id.isEmpty &&
              !ref.watch(isNewUpload) &&
              ref.watch(iShareFile) != null)
            _buildShare(),
          if (!ref.watch(isNewFile) &&
              ref.watch(editFileProvider).id.isEmpty &&
              !ref.watch(isNewUpload) &&
              ref.watch(iShareFile) == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: styles.width * .5,
                  child: CustomTextFields(
                    hintText: 'Search office',
                    onChanged: (query) {
                      ref.read(filesProvider.notifier).filterItems(query);
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CustomButton(
                  text: 'New File',
                  onPressed: () {
                    ref.read(isNewFile.notifier).state = true;
                    ref.read(editFileProvider.notifier).reset();
                    ref.read(newUploadProvider.notifier).reset();
                    ref.read(isNewUpload.notifier).state = false;
                    ref.read(iShareFile.notifier).state = null;
                  },
                )
              ],
            ),
          if (ref.watch(isNewFile) && !ref.watch(isNewUpload))
            _buildCreateFile(),
          if (ref.watch(editFileProvider).id.isNotEmpty &&
              !ref.watch(isNewUpload))
            _buildEditFile(),
          if (ref.watch(isNewUpload) &&
              !ref.watch(isNewFile) &&
              ref.watch(editFileProvider).id.isEmpty)
            _buildFileUpload(),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: DataTable2(
              columnSpacing: 30,
              horizontalMargin: 12,
              empty: Center(
                  child: Text(
                'No File added',
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
                  label: Text('File Title'.toUpperCase()),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text('File Description'.toUpperCase()),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text('Total Files'.toUpperCase()),
                  size: ColumnSize.M,
                  numeric: true,
                  fixedWidth: styles.isMobile ? null : 200,
                ),
                DataColumn2(
                  label: Text('Share To'.toUpperCase()),
                  size: ColumnSize.M,
                  numeric: true,
                  fixedWidth: styles.isMobile ? null : 200,
                ),
                DataColumn2(
                  label: Text('Action'.toUpperCase()),
                  size: ColumnSize.L,
                  fixedWidth: styles.isMobile ? null : 250,
                ),
              ],
              rows: List<DataRow>.generate(files.length, (index) {
                var file = files[index];

                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}', style: rowStyles)),
                    DataCell(Text(file.title, style: rowStyles)),
                    DataCell(Text(file.description, style: rowStyles)),
                    DataCell(
                        Text(file.files.length.toString(), style: rowStyles)),
                    DataCell(
                        Text('${file.users.length} People', style: rowStyles)),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                MyRouter(context: context, ref: ref)
                                    .navigateToNamed(
                                        pathPrams: {'fileId': file.id},
                                        item: RouterItem.fileDetailsRouter);
                              },
                              icon: const Icon(Icons.remove_red_eye)),
                          //upload
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: IconButton(
                              icon: const Icon(Icons.upload),
                              onPressed: () {
                                ref
                                    .read(newUploadProvider.notifier)
                                    .setFolderId(file.id);
                                ref.read(isNewUpload.notifier).state = true;
                                ref.read(selectedFileProvider.notifier).state =
                                    SelectedFile(file: null, path: '');
                                ref.read(isNewFile.notifier).state = false;
                                ref.read(editFileProvider.notifier).reset();
                                ref.read(iShareFile.notifier).state = null;
                              },
                            ),
                          ),
                          //edit

                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: IconButton(
                                onPressed: () {
                                  ref.read(iShareFile.notifier).state = file;
                                },
                                icon: const Icon(Icons.share)),
                          ),
                          if (file.creatorId == user.id)
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  ref
                                      .read(editFileProvider.notifier)
                                      .setOffice(file);
                                  ref.read(isNewFile.notifier).state = false;
                                  ref.read(isNewUpload.notifier).state = false;
                                  ref.read(iShareFile.notifier).state = null;
                                },
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              CustomDialogs.showDialog(
                                message:
                                    'Are you sure you want to delete this file?',
                                secondBtnText: 'Delete',
                                type: DialogType.warning,
                                onConfirm: () {
                                  ref
                                      .read(filesProvider.notifier)
                                      .delete(file, ref);
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

  Widget _buildCreateFile() {
    var notifier = ref.read(newFileProvider.notifier);
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
                        hintText: 'File Title',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'File title is required';
                          }
                          return null;
                        },
                        onSaved: (name) {
                          notifier.setTitle(name!);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 450,
                      child: CustomTextFields(
                        hintText: 'File Description',
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'File description is required';
                          }
                          return null;
                        },
                        onSaved: (name) {
                          notifier.setDescription(name!);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: CustomButton(
                        text: 'Create',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            notifier.createFile(ref);
                            _formKey.currentState!.reset();
                          }
                        },
                      ),
                    )
                  ]))),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(isNewFile.notifier).state = false;
              ref.read(editFileProvider.notifier).reset();
              ref.read(newUploadProvider.notifier).reset();
              ref.read(isNewUpload.notifier).state = false;
              ref.read(iShareFile.notifier).state = null;
            },
          )
        ],
      ),
    );
  }

  final _edtFormKey = GlobalKey<FormState>();
  Widget _buildEditFile() {
    var notifier = ref.read(editFileProvider.notifier);
    var provider = ref.watch(editFileProvider);

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
                        hintText: 'File Title',
                        initialValue: provider.title,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'File title is required';
                          }
                          return null;
                        },
                        onSaved: (name) {
                          notifier.setTitle(name!);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 450,
                      child: CustomTextFields(
                        hintText: 'File Description',
                        maxLines: 2,
                        initialValue: provider.description,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'File description is required';
                          }
                          return null;
                        },
                        onSaved: (name) {
                          notifier.setDescription(name!);
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
              ref.read(isNewFile.notifier).state = false;
              ref.read(editFileProvider.notifier).reset();
              ref.read(newUploadProvider.notifier).reset();
              ref.read(isNewUpload.notifier).state = false;
              ref.read(iShareFile.notifier).state = null;
            },
          )
        ],
      ),
    );
  }

  var uploadKey = GlobalKey<FormState>();
  Widget _buildFileUpload() {
    var notifier = ref.read(newUploadProvider.notifier);
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
                  key: uploadKey,
                  child: Wrap(runSpacing: 20, spacing: 10, children: [
                    SizedBox(
                      width: 350,
                      child: CustomTextFields(
                        hintText: 'File description',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'File description is required';
                          }
                          return null;
                        },
                        onSaved: (name) {
                          notifier.setDescription(name!);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 500,
                      child: CustomTextFields(
                        hintText: 'File Path',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            //upload file
                            IconButton(
                                onPressed: () {
                                  _pickFile();
                                },
                                icon: const Icon(Icons.upload)),

                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                ref.read(selectedFileProvider.notifier).state =
                                    SelectedFile(file: null, path: '');
                              },
                            ),
                          ],
                        ),
                        controller: TextEditingController(
                            text: ref.watch(selectedFileProvider).path),
                        isReadOnly: true,
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: CustomButton(
                        text: 'Upload',
                        onPressed: () {
                          if (uploadKey.currentState!.validate()) {
                            uploadKey.currentState!.save();
                            notifier.createUpload(ref);
                            uploadKey.currentState!.reset();
                          }
                        },
                      ),
                    )
                  ]))),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(isNewFile.notifier).state = false;
              ref.read(editFileProvider.notifier).reset();
              ref.read(newUploadProvider.notifier).reset();
              ref.read(isNewUpload.notifier).state = false;
              ref.read(iShareFile.notifier).state = null;
            },
          )
        ],
      ),
    );
  }

  Widget _buildShare() {
    var notifier = ref.read(shareFileUserProvider.notifier);
    var users = ref.watch(usersProvider).items.toList();
    var user = ref.watch(userProvider);
    var names = users.map((e) => e.name).toList();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: secondaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Wrap(runSpacing: 20, spacing: 10, children: [
            SizedBox(
              width: 300,
              child: CustomDropDown(
                hintText: 'Select User',
                items: names
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (selected) {
                  if (selected == null) return;
                  var selectedUser =
                      users.firstWhere((element) => element.name == selected!);
                  if (selectedUser.id != user.id) {
                    notifier.setUser(selectedUser);
                  } else {
                    CustomDialogs.toast(
                        message: 'You can not share file with yourself',
                        type: DialogType.error);
                  }
                },
              ),
            ),
            SizedBox(
                width: 500,
                child: Wrap(
                  children: ref
                      .watch(shareFileUserProvider)
                      .map((user) => Container(
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(user.name),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  notifier.removeUser(user);
                                },
                              )
                            ],
                          )))
                      .toList(),
                )),
            SizedBox(
              width: 200,
              child: CustomButton(
                text: 'Share',
                onPressed: () {
                  if (ref.watch(shareFileUserProvider).isEmpty) {
                    CustomDialogs.toast(message: 'No User was selected ');
                    return;
                  }
                  notifier.shareFile(ref);
                },
              ),
            )
          ])),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(isNewFile.notifier).state = false;
              ref.read(editFileProvider.notifier).reset();
              ref.read(newUploadProvider.notifier).reset();
              ref.read(isNewUpload.notifier).state = false;
              ref.read(iShareFile.notifier).state = null;
            },
          )
        ],
      ),
    );
  }

  _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        //check file size
        if (result.files.first.size > 5000000) {
          CustomDialogs.toast(
              message: 'File size must not exceed 1MB', type: DialogType.error);
          return;
        }
        var byte = result.files.first.bytes!;
        ref.read(selectedFileProvider.notifier).state = SelectedFile(
          file: byte,
          path: result.files.first.name,
        );
      }
    } catch (e) {
      print(e);
    }
  }
}

final isNewFile = StateProvider<bool>((ref) => false);
final isNewUpload = StateProvider<bool>((ref) => false);
final iShareFile = StateProvider<FileModel?>((ref) => null);
