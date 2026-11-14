/// Shams Platform — Domain Constants
///
/// Single source of truth for all domain-specific lists and values.
/// Always reference these instead of duplicating lists in widgets/screens.
class ShamsConstants {
  const ShamsConstants._();

  /// Complete list of Yemeni governorates used in city pickers.
  /// Referenced by `AddWorkshopScreen`, `WorkshopDashboardScreen`, and `CityMultiSelectFilter`.
  static const List<String> yemeniCities = [
    'أمانة العاصمة',
    'صنعاء',
    'عدن',
    'تعز',
    'الحديدة',
    'إب',
    'حضرموت',
    'ذمار',
    'عمران',
    'الضالع',
    'لحج',
    'أبين',
    'المهرة',
    'شبوة',
    'البيضاء',
    'مأرب',
    'الجوف',
    'صعدة',
    'المحويت',
    'حجة',
    'ريمة',
    'سقطرى',
  ];

  /// Solar service types used for filtering workshops and structuring maintenance requests.
  static const List<String> solarServiceTypes = [
    'تركيب منظومة جديدة',
    'صيانة ألواح شمسية',
    'صيانة عاكس (Inverter)',
    'صيانة بطاريات',
    'مضخات مياه شمسية',
    'فحص شامل للمنظومة',
    'توريد قطع غيار',
  ];

  /// Solar inverter brands commonly used in Yemen.
  static const List<String> inverterBrands = [
    'Growatt',
    'Huawei SUN2000',
    'SMA',
    'Solis',
    'Deye',
    'Goodwe',
    'Voltronic',
    'Sofar',
    'أخرى',
  ];

  /// Battery types for maintenance requests.
  static const List<String> batteryTypes = [
    'ليثيوم (LiFePO4)',
    'جل (Gel)',
    'حمض رصاص (AGM)',
    'أخرى',
  ];
}
