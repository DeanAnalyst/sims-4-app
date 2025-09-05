import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/regional_info.dart';
import '../services/map_data_service.dart';
import 'state_providers.dart';

final mapDataServiceProvider = Provider<MapDataService>((ref) {
  return MapDataService();
});

final regionalInfoProvider = FutureProvider<List<RegionalInfo>>((ref) async {
  final mapDataService = ref.watch(mapDataServiceProvider);
  return await mapDataService.getAllRegionalInfo();
});

final selectedRegionalInfoProvider = Provider<RegionalInfo?>((ref) {
  final selectedRegion = ref.watch(selectedRegionProvider);
  final regionalInfoAsync = ref.watch(regionalInfoProvider);
  
  return regionalInfoAsync.when(
    data: (regionalInfoList) {
      try {
        return regionalInfoList.firstWhere(
          (info) => info.region == selectedRegion,
        );
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (error, stackTrace) => null,
  );
});