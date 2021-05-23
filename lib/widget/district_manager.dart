import 'package:bd_map/widget/map.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/// Information about the district selection.
class DistrictSelection {
  /// Creates a new [DistrictSelection].
  DistrictSelection(List<District> selectedDistricts)
      : selectedDistricts = UnmodifiableListView(selectedDistricts);

  /// Creates a new [DistrictSelection] with no selected district.
  DistrictSelection.empty() : selectedDistricts = [];

  /// Districts that are selected.
  final List<District> selectedDistricts;

  /// Amount of selected district.
  int get amount => selectedDistricts.length;

  @override
  String toString() => 'Selection{_selectedDistricts: $selectedDistricts}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistrictSelection &&
          runtimeType == other.runtimeType &&
          listEquals(selectedDistricts, other.selectedDistricts);

  @override
  int get hashCode => const ListEquality<District>().hash(selectedDistricts);
}
