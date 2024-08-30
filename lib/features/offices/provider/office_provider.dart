import 'package:file_sharing/core/views/custom_dialog.dart';
import 'package:file_sharing/features/offices/data/office_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/office_services.dart';

final officesStreamProvider =
    StreamProvider.autoDispose<List<OfficeModel>>((ref) async* {
  var data = OfficeServices.getOffices();
  await for (var item in data) {
    ref.read(officesProvider.notifier).setItems(item);
    yield item;
  }
});

class OfficeFilter {
  List<OfficeModel> items;
  List<OfficeModel> filteredItems;
  OfficeFilter({required this.items, required this.filteredItems});

  OfficeFilter copyWith({
    List<OfficeModel>? items,
    List<OfficeModel>? filteredItems,
  }) {
    return OfficeFilter(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
    );
  }
}

final officesProvider =
    StateNotifierProvider<OfficeProvider, OfficeFilter>((ref) {
  return OfficeProvider();
});

class OfficeProvider extends StateNotifier<OfficeFilter> {
  OfficeProvider() : super(OfficeFilter(items: [], filteredItems: []));

  void setItems(List<OfficeModel> items) {
    state = state.copyWith(items: items, filteredItems: items);
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredItems: state.items);
    } else {
      var filteredItems = state.items
          .where((element) =>
              element.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      state = state.copyWith(filteredItems: filteredItems);
    }
  }

  void delete(affiliation, WidgetRef ref) async {
    CustomDialogs.dismiss();
    try {
      CustomDialogs.loading(message: 'Deleting Office...');
      await OfficeServices.deleteOffice(affiliation);
      CustomDialogs.dismiss();
      CustomDialogs.toast(
          message: 'Office deleted successfully', type: DialogType.success);
    } catch (e) {
      CustomDialogs.showDialog(message: e.toString(), type: DialogType.error);
    }
  }
}
