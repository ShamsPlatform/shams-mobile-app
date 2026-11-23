import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/utils/formatters.dart';

const List<String> _technicalDbErrorMarkers = [
  'violates check constraint',
  'violates row-level security',
  'violates foreign key constraint',
  'violates unique constraint',
  'new row for relation',
  'null value in column',
  'permission denied for',
  'invalid input syntax',
  'notifications_type_check',
];

/// Translates known Arabic domain/validation/data error messages into the
/// active locale while passing unknown messages through.
extension AppLocalizationsMappers on AppLocalizations {
  /// Formats [dateTime] as a localized relative timestamp string.
  String formatRelativeTimeLocalized(DateTime dateTime, {DateTime? now}) {
    return formatRelativeTime(
      dateTime,
      now: now,
      nowLabel: nowRelative,
      minutesLabel: minutesAgo,
      hoursLabel: hoursAgo,
      daysLabel: daysAgo,
    );
  }

  /// Maps a canonical Yemeni governorate string from `ShamsConstants` to its
  /// localized display label while preserving the stored DB value.
  String localizeCity(String canonicalCity) {
    return switch (canonicalCity) {
      'أمانة العاصمة' => cityCapital,
      'صنعاء' => citySanaa,
      'عدن' => cityAden,
      'تعز' => cityTaiz,
      'الحديدة' => cityHudaydah,
      'إب' => cityIbb,
      'حضرموت' => cityHadramaut,
      'ذمار' => cityDhamar,
      'عمران' => cityAmran,
      'الضالع' => cityDhale,
      'لحج' => cityLahij,
      'أبين' => cityAbyan,
      'المهرة' => cityMahrah,
      'شبوة' => cityShabwah,
      'البيضاء' => cityBayda,
      'مأرب' => cityMarib,
      'الجوف' => cityJawf,
      'صعدة' => citySaada,
      'المحويت' => cityMahwit,
      'حجة' => cityHajjah,
      'ريمة' => cityRaymah,
      'سقطرى' => citySocotra,
      _ => canonicalCity,
    };
  }

  /// Maps a canonical solar service type from `ShamsConstants` to its
  /// localized display label.
  String localizeServiceType(String canonicalService) {
    return switch (canonicalService) {
      'تركيب منظومة جديدة' => serviceInstallNewSystem,
      'صيانة ألواح شمسية' => serviceSolarPanelMaintenance,
      'صيانة عاكس (Inverter)' => serviceInverterMaintenance,
      'صيانة بطاريات' => serviceBatteryMaintenance,
      'مضخات مياه شمسية' => serviceSolarWaterPumps,
      'فحص شامل للمنظومة' => serviceFullInspection,
      'توريد قطع غيار' => serviceSpareParts,
      _ => canonicalService,
    };
  }

  /// Maps a canonical inverter brand from `ShamsConstants` to its localized
  /// display label.
  String localizeInverterBrand(String canonicalBrand) {
    return canonicalBrand == 'أخرى' ? other : canonicalBrand;
  }

  /// Maps a canonical battery type from `ShamsConstants` to its localized
  /// display label.
  String localizeBatteryType(String canonicalBattery) {
    return switch (canonicalBattery) {
      'ليثيوم (LiFePO4)' => batteryLithium,
      'جل (Gel)' => batteryGel,
      'حمض رصاص (AGM)' => batteryAgm,
      'أخرى' => other,
      _ => canonicalBattery,
    };
  }

  /// Maps a 1-based month number (1..12) to its localized month name.
  String localizedMonthName(int month) {
    return switch (month) {
      1 => monthJan,
      2 => monthFeb,
      3 => monthMar,
      4 => monthApr,
      5 => monthMay,
      6 => monthJun,
      7 => monthJul,
      8 => monthAug,
      9 => monthSep,
      10 => monthOct,
      11 => monthNov,
      12 => monthDec,
      _ => '',
    };
  }

  /// Translates known Arabic domain/validation/data error messages into the
  /// active locale while sanitizing raw database/SQL errors into [fallback].
  String localizeErrorMessage(String? rawMessage, {String? fallback}) {
    if (rawMessage == null || rawMessage.isEmpty) {
      return fallback ?? errUnexpected;
    }

    final lower = rawMessage.toLowerCase();
    if (_technicalDbErrorMarkers.any(lower.contains)) {
      return fallback ?? errUnexpected;
    }

    const uploadPrefix1 = 'فشل رفع الصورة: ';
    if (rawMessage.startsWith(uploadPrefix1)) {
      final reason = rawMessage.substring(uploadPrefix1.length);
      return errImageUploadFailedWithReason(reason);
    }

    const uploadPrefix2 = 'حدث خطأ أثناء رفع الصورة: ';
    if (rawMessage.startsWith(uploadPrefix2)) {
      final reason = rawMessage.substring(uploadPrefix2.length);
      return errPhotoUploadErrorWithReason(reason);
    }

    const profileUpdatePrefix = 'حدث خطأ أثناء تحديث بيانات الملف: ';
    if (rawMessage.startsWith(profileUpdatePrefix)) {
      final reason = rawMessage.substring(profileUpdatePrefix.length);
      return errProfileUpdateErrorWithReason(reason);
    }

    return switch (rawMessage) {
      'لا يوجد اتصال بالإنترنت' => errNoInternet,
      'حدث خطأ غير متوقع' => errUnexpected,
      'فشل تسجيل الدخول' => errSignInFailed,
      'البريد الإلكتروني أو كلمة المرور غير صحيحة' => errInvalidCredentials,
      'يرجى تأكيد بريدك الإلكتروني أولاً' => errConfirmEmail,
      'فشل تسجيل الدخول عبر جوجل' => googleSignInFailed,
      'فشل إنشاء الحساب' => errCreateAccountFailed,
      'هذا البريد الإلكتروني مسجل مسبقاً، حاول تسجيل الدخول من الشاشة السابقة' =>
        errEmailAlreadyRegistered,
      'يرجى التحقق من البريد الإلكتروني' => pleaseVerifyEmail,
      'كلمة المرور غير صحيحة' => incorrectPassword,
      'لا يوجد مستخدم مسجل دخول' => errNoSignedInUser,
      'المستخدم غير مسجل الدخول' => errUserNotSignedIn,
      'معرّف الورشة غير صالح' => errInvalidWorkshopId,
      'معرّف التقييم غير صالح' => errInvalidReviewId,
      'يرجى اختيار تقييم من 1 إلى 5 نجوم' => errSelectRatingRange,
      'يرجى كتابة تعليق عن تجربتك مع الورشة' => pleaseWriteReviewComment,
      'لا توجد تعديلات لحفظها' => errNoChangesToSave,
      'تعذر تحميل بيانات الملف الشخصي' => profileLoadError,
      'اسم المستخدم مطلوب' => usernameRequiredError,
      'يجب أن يكون 3 أحرف على الأقل' => usernameMinLengthError,
      'يجب ألا يتجاوز 30 حرفاً' => usernameMaxLengthError,
      'يُسمح فقط بـ: أحرف إنجليزية، أرقام، نقطة، شرطة سفلية' =>
        usernameAllowedCharsError,
      'لا يمكن أن يبدأ بنقطة أو شرطة سفلية' => usernameStartCharError,
      'لا يمكن أن ينتهي بنقطة أو شرطة سفلية' => usernameEndCharError,
      'لا يمكن استخدام رمزين خاصين متتاليين' => usernameConsecutiveCharsError,
      _ => rawMessage,
    };
  }
}

