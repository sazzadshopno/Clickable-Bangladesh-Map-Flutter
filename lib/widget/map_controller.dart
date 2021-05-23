import 'package:bd_map/widget/map.dart';
import 'package:flutter/widgets.dart';
import 'package:bd_map/widget/district_manager.dart';

/// Function signature for notifying whenever the selection changes.
typedef DistrictSelectionChangedCallback = void Function(
    DistrictSelection selection);

/// A controller for [BangladeshMap].
///
/// This provides information that can be used to update the UI to indicate
/// whether there are selected districts and how many are selected.
///
/// It also allows to directly update the selected items.
class BangladeshMapController extends ValueNotifier<DistrictSelection> {
  /// Creates a controller for [BangladeshMap].
  ///
  /// The initial selection is [DistrictSelection.empty], unless a different one is
  /// provided.
  BangladeshMapController([DistrictSelection selection])
      : super(selection ?? DistrictSelection.empty());

  /// Clears the district selection.
  void clear() => value = DistrictSelection.empty();

  void add(District district) {
    if (value.selectedDistricts.contains(district)) {
      value.selectedDistricts.remove(district);
    } else {
      value.selectedDistricts.add(district);
    }
    notifyListeners();
  }
}
