import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The title of the application
  ///
  /// In ar, this message translates to:
  /// **'شمس'**
  String get appTitle;

  /// Edit profile button label
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف'**
  String get editProfile;

  /// My business section header
  ///
  /// In ar, this message translates to:
  /// **'إدارة أعمالي'**
  String get myBusiness;

  /// Settings section header
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات والتفضيلات'**
  String get settingsPreferences;

  /// Notifications setting label
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// Privacy and security setting label
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية والأمان'**
  String get privacySecurity;

  /// Change language setting label
  ///
  /// In ar, this message translates to:
  /// **'تغيير اللغة'**
  String get changeLanguage;

  /// Contact support setting label
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الدعم'**
  String get contactSupport;

  /// Technical support sheet title
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الدعم الفني'**
  String get technicalSupport;

  /// About Shams setting label
  ///
  /// In ar, this message translates to:
  /// **'عن شمس'**
  String get aboutShams;

  /// Share app button label
  ///
  /// In ar, this message translates to:
  /// **'مشاركة التطبيق'**
  String get shareApp;

  /// Share app message text
  ///
  /// In ar, this message translates to:
  /// **'حمّل تطبيق شمس وانضم إلينا الآن!\nhttps://shams.app/download'**
  String get shareAppText;

  /// Logout button label
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// Logout sheet title
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logoutTitle;

  /// Logout confirmation message
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد تسجيل الخروج؟'**
  String get logoutConfirm;

  /// Logout error message
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تسجيل الخروج'**
  String get logoutError;

  /// Cancel button label
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// Save button label
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// Workshop dashboard tile title
  ///
  /// In ar, this message translates to:
  /// **'لوحة تحكم الورشة'**
  String get workshopDashboard;

  /// Workshop dashboard tile subtitle
  ///
  /// In ar, this message translates to:
  /// **'إدارة منشوراتك وإحصاءات ورشتك'**
  String get workshopDashboardSubtitle;

  /// Add new workshop tile title
  ///
  /// In ar, this message translates to:
  /// **'إضافة ورشة جديدة'**
  String get addNewWorkshop;

  /// Add new workshop tile subtitle
  ///
  /// In ar, this message translates to:
  /// **'انقر هنا لإضافة تفاصيل الورشة'**
  String get addNewWorkshopSubtitle;

  /// Workshop created success message
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء الورشة بنجاح! 🎉'**
  String get workshopCreatedSuccess;

  /// Arabic language label
  ///
  /// In ar, this message translates to:
  /// **'عربي'**
  String get arabic;

  /// English language label
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// Arabic option in language picker
  ///
  /// In ar, this message translates to:
  /// **'عربي (AR)'**
  String get arabicOption;

  /// English option in language picker
  ///
  /// In ar, this message translates to:
  /// **'English (EN)'**
  String get englishOption;

  /// Home navigation label
  ///
  /// In ar, this message translates to:
  /// **'الصفحة الرئيسية'**
  String get home;

  /// Workshops navigation label
  ///
  /// In ar, this message translates to:
  /// **'قائمة الورش'**
  String get workshops;

  /// My chats navigation label
  ///
  /// In ar, this message translates to:
  /// **'محادثاتي'**
  String get myChats;

  /// Governorates filter button label
  ///
  /// In ar, this message translates to:
  /// **'المحافظات'**
  String get governorates;

  /// Select governorates dialog title
  ///
  /// In ar, this message translates to:
  /// **'اختر المحافظات'**
  String get selectGovernorates;

  /// Done button label
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;

  /// Read more button label
  ///
  /// In ar, this message translates to:
  /// **'قراءة المزيد...'**
  String get readMore;

  /// Show less button label
  ///
  /// In ar, this message translates to:
  /// **'عرض أقل'**
  String get showLess;

  /// Choose from gallery option
  ///
  /// In ar, this message translates to:
  /// **'اختر من المعرض'**
  String get chooseFromGallery;

  /// Take photo option
  ///
  /// In ar, this message translates to:
  /// **'التقط صورة'**
  String get takePhoto;

  /// WhatsApp contact option
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get whatsapp;

  /// Phone call contact option
  ///
  /// In ar, this message translates to:
  /// **'اتصال هاتفي'**
  String get phoneCall;

  /// Email contact option
  ///
  /// In ar, this message translates to:
  /// **'إيميل'**
  String get email;

  /// Email full label
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get emailFull;

  /// WhatsApp launch error
  ///
  /// In ar, this message translates to:
  /// **'لم نتمكن من فتح تطبيق واتساب. يرجى التأكد من تثبيت التطبيق.'**
  String get whatsappError;

  /// Phone call launch error
  ///
  /// In ar, this message translates to:
  /// **'تعذر إجراء الاتصال الهاتفي حالياً.'**
  String get phoneError;

  /// Email launch error
  ///
  /// In ar, this message translates to:
  /// **'لم نتمكن من فتح تطبيق البريد الإلكتروني.'**
  String get emailError;

  /// Sign in label
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get signin;

  /// Sign up label
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get signup;

  /// Password label
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// Workshop owner badge
  ///
  /// In ar, this message translates to:
  /// **'صاحب ورشة 🛠️'**
  String get workshopOwner;

  /// Shams client badge
  ///
  /// In ar, this message translates to:
  /// **'عميل شمس ☀️'**
  String get shamsClient;

  /// Edit profile drawer item
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get editMyProfile;

  /// My maintenance requests drawer item
  ///
  /// In ar, this message translates to:
  /// **'طلبات الصيانة الخاصة بي'**
  String get myMaintenanceRequests;

  /// About shams platform drawer item
  ///
  /// In ar, this message translates to:
  /// **'عن منصة شمس'**
  String get aboutShamsPlatform;

  /// Technical support drawer item
  ///
  /// In ar, this message translates to:
  /// **'الدعم الفني والاتصال'**
  String get technicalSupportContact;

  /// Relative time: now
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get nowRelative;

  /// Relative time: minutes ago
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} دقيقة'**
  String minutesAgo(int count);

  /// Relative time: hours ago
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} ساعة'**
  String hoursAgo(int count);

  /// Relative time: days ago
  ///
  /// In ar, this message translates to:
  /// **'منذ {count} يوم'**
  String daysAgo(int count);

  /// Inline search bar hint text
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن ورشة...'**
  String get inlineSearchHint;

  /// Generic search hint text
  ///
  /// In ar, this message translates to:
  /// **'ابحث هنا...'**
  String get searchHint;

  /// Home bottom nav label
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get homeNav;

  /// Workshops bottom nav label
  ///
  /// In ar, this message translates to:
  /// **'الورش'**
  String get workshopsNav;

  /// Follow bottom nav label
  ///
  /// In ar, this message translates to:
  /// **'المتابعة'**
  String get followNav;

  /// Profile bottom nav label
  ///
  /// In ar, this message translates to:
  /// **'الملف'**
  String get profileNav;

  /// Technical support sheet title
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الدعم الفني'**
  String get technicalSupportTitle;

  /// Welcome back title on signin
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك مجدداً'**
  String get welcomeBack;

  /// Don't have account label
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get dontHaveAccount;

  /// Already have account label
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get alreadyHaveAccount;

  /// Profile load error message
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل الملف الشخصي'**
  String get profileLoadError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
