import 'package:file_sharing/core/views/custom_button.dart';
import 'package:file_sharing/features/dashboard/pages/files/data/upload_model.dart';
import 'package:file_sharing/features/files/provider/file_provider.dart';
import 'package:file_sharing/features/users/data/user_model.dart';
import 'package:file_sharing/router/router.dart';
import 'package:file_sharing/router/router_items.dart';
import 'package:file_sharing/utils/colors.dart';
import 'package:file_sharing/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/functions/int_to_date.dart';

class FileDetailsPage extends ConsumerStatefulWidget {
  const FileDetailsPage({super.key, required this.fileId});
  final String fileId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FileDetailsPageState();
}

class _FileDetailsPageState extends ConsumerState<FileDetailsPage> {
  @override
  Widget build(BuildContext context) {
    var style = Styles(context);
    var files = ref.watch(filesProvider).items.toList();
    var file = files
        .where(
          (element) => element.id == widget.fileId,
        )
        .firstOrNull;
    if (file == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                //back button
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    MyRouter(context: context, ref: ref)
                        .navigateToRoute(RouterItem.filesRoute);
                  },
                ),
                const SizedBox(width: 10),
                Text(
                  'File Details'.toUpperCase(),
                  style: style.title(fontSize: 28, color: primaryColor),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'The file is not found',
              style: style.body(),
            ),
          ],
        ),
      );
    }
    var creator = UserModel.fromMap(file.creator);
    List<Upload> uploads = file.files.map((e) => Upload.fromMap(e)).toList();
    List<UserModel> users =
        file.users.map((e) => UserModel.fromMap(e)).toList();
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              //back button
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  MyRouter(context: context, ref: ref)
                      .navigateToRoute(RouterItem.filesRoute);
                },
              ),
              const SizedBox(width: 10),
              Text(
                'File Details'.toUpperCase(),
                style: style.title(fontSize: 28, color: primaryColor),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    alignment: WrapAlignment.start,
                    children: [
                      Container(
                        width: style.width / 5,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: secondaryColor.withOpacity(.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text('File Name', style: style.body()),
                          subtitle: Text(file.title, style: style.subtitle()),
                        ),
                      ),
                      Container(
                        width: style.width / 5,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: secondaryColor.withOpacity(.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text('File Description', style: style.body()),
                          subtitle:
                              Text(file.description, style: style.subtitle()),
                        ),
                      ),
                      Container(
                        width: style.width / 5,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: secondaryColor.withOpacity(.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text('Created By', style: style.body()),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(creator.name, style: style.subtitle()),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.email,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(creator.email,
                                        maxLines: 1, style: style.subtitle()),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(creator.phone,
                                        maxLines: 1, style: style.subtitle()),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: style.width / 5,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: secondaryColor.withOpacity(.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text('Created At', style: style.body()),
                          subtitle: Text(
                              intToDate(file.createdAt, withTime: true),
                              style: style.subtitle()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  //step progress indicator
                  Container(
                    height: 5,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < uploads.length; i++)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SizedBox(
                            width: 300,
                            height: 220,
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    ref.read(selectedIndex.notifier).state = i;
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: ref.watch(selectedIndex) == i
                                          ? primaryColor
                                          : Colors.grey,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${i + 1}',
                                        style: style.body(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: ref.watch(selectedIndex) == i
                                        ? primaryColor.withOpacity(.3)
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(uploads[i].description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              style.body(color: Colors.black)),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text('Uploaded By:',
                                              style: style.body(
                                                  color: Colors.white)),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                                getUser(users,
                                                        uploads[i].uploadBy)!
                                                    .name,
                                                    maxLines: 1,
                                                style: style.body(
                                                    color: Colors.black)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text('Uploaded At:',
                                              style: style.body(
                                                  color: Colors.white)),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                                intToDate(uploads[i].createdAt,
                                                    withTime: true),
                                                    maxLines: 1,
                                                style: style.body(
                                                    color: Colors.black)),
                                          ),
                                        ],
                                      ),
                                      //add download button
                                      const SizedBox(height: 5),
                                      if (ref.watch(selectedIndex) == i)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CustomButton(
                                              color: secondaryColor,
                                              radius: 10,
                                              text: 'Download',
                                              onPressed: () async {
                                                await _launchUrl(uploads[ref
                                                        .watch(selectedIndex)]
                                                    .fileUrl);
                                                // await FileSaver.instance.saveFile(
                                                //   link: LinkDetails(
                                                //       link:
                                                //           uploads[ref.watch(selectedIndex)].fileUrl,
                                                //       ),
                                                //   name: uploads[ref.watch(selectedIndex)].description.trim().replaceAll(' ', '_').toLowerCase(),
                                                // );
                                              }),
                                        ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  UserModel? getUser(List<UserModel> users, String uploadBy) {
    return users.where((element) => element.id == uploadBy).firstOrNull;
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    } else {
      print('Not  working ');
    }
  }
}

final selectedIndex = StateProvider<int>((ref) => 0);
