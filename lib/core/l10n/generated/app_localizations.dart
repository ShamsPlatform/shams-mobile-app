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

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @clearSearch.
  ///
  /// In ar, this message translates to:
  /// **'مسح البحث'**
  String get clearSearch;

  /// No description provided for @noResultsFor.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج لـ \"{query}\"'**
  String noResultsFor(String query);

  /// No description provided for @tryDifferentKeyword.
  ///
  /// In ar, this message translates to:
  /// **'جرّب كلمة مختلفة'**
  String get tryDifferentKeyword;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get saveChanges;

  /// No description provided for @saveEdits.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get saveEdits;

  /// No description provided for @viewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// No description provided for @like.
  ///
  /// In ar, this message translates to:
  /// **'إعجاب'**
  String get like;

  /// No description provided for @unknownUser.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم غير معروف'**
  String get unknownUser;

  /// No description provided for @userFallback.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم'**
  String get userFallback;

  /// No description provided for @shamsUser.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم شمس'**
  String get shamsUser;

  /// No description provided for @shamsClientPlain.
  ///
  /// In ar, this message translates to:
  /// **'عميل شمس'**
  String get shamsClientPlain;

  /// No description provided for @loadingLabel.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loadingLabel;

  /// No description provided for @yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get yesterday;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @other.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get other;

  /// No description provided for @comingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get comingSoon;

  /// No description provided for @video.
  ///
  /// In ar, this message translates to:
  /// **'فيديو'**
  String get video;

  /// No description provided for @photo.
  ///
  /// In ar, this message translates to:
  /// **'صورة'**
  String get photo;

  /// No description provided for @newLabel.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get newLabel;

  /// No description provided for @monthJan.
  ///
  /// In ar, this message translates to:
  /// **'يناير'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In ar, this message translates to:
  /// **'فبراير'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In ar, this message translates to:
  /// **'مارس'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In ar, this message translates to:
  /// **'أبريل'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In ar, this message translates to:
  /// **'مايو'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In ar, this message translates to:
  /// **'يونيو'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In ar, this message translates to:
  /// **'يوليو'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In ar, this message translates to:
  /// **'أغسطس'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In ar, this message translates to:
  /// **'سبتمبر'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In ar, this message translates to:
  /// **'أكتوبر'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In ar, this message translates to:
  /// **'نوفمبر'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In ar, this message translates to:
  /// **'ديسمبر'**
  String get monthDec;

  /// No description provided for @welcomeTagline.
  ///
  /// In ar, this message translates to:
  /// **'طاقة موثوقة.. لمجتمع متصل'**
  String get welcomeTagline;

  /// No description provided for @highEfficiency.
  ///
  /// In ar, this message translates to:
  /// **'كفاءة عالية'**
  String get highEfficiency;

  /// No description provided for @smartControl.
  ///
  /// In ar, this message translates to:
  /// **'تحكم ذكي'**
  String get smartControl;

  /// No description provided for @termsOfServiceNotice.
  ///
  /// In ar, this message translates to:
  /// **'من خلال الاستمرار، أنت توافق على شروط الخدمة'**
  String get termsOfServiceNotice;

  /// No description provided for @welcomeBackExclaim.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بعودتك!'**
  String get welcomeBackExclaim;

  /// No description provided for @signInSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل الدخول للمتابعة في رحلتك مع شمس'**
  String get signInSubtitle;

  /// No description provided for @emailOrPhone.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو الهاتف'**
  String get emailOrPhone;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// No description provided for @signInWithGoogle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول بواسطة Google'**
  String get signInWithGoogle;

  /// No description provided for @joinUsNow.
  ///
  /// In ar, this message translates to:
  /// **'انضم إلينا الآن'**
  String get joinUsNow;

  /// No description provided for @joinShamsCommunity.
  ///
  /// In ar, this message translates to:
  /// **'انضم إلى مجتمع شمس'**
  String get joinShamsCommunity;

  /// No description provided for @signUpSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'خطوتك الأولى لتجربة فريدة ومتميزة معنا'**
  String get signUpSubtitle;

  /// No description provided for @confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @orSignUpWith.
  ///
  /// In ar, this message translates to:
  /// **'أو إنشاء حساب عبر'**
  String get orSignUpWith;

  /// No description provided for @completeYourProfile.
  ///
  /// In ar, this message translates to:
  /// **'أكمل ملفك الشخصي'**
  String get completeYourProfile;

  /// No description provided for @completeProfileSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'دع مجتمع شمس يتعرف عليك أكثر'**
  String get completeProfileSubtitle;

  /// No description provided for @fullNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل *'**
  String get fullNameRequired;

  /// No description provided for @enterFullName.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك الكامل'**
  String get enterFullName;

  /// No description provided for @usernameRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم *'**
  String get usernameRequiredLabel;

  /// No description provided for @enterUsername.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم المستخدم'**
  String get enterUsername;

  /// No description provided for @locationRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'الموقع *'**
  String get locationRequiredLabel;

  /// No description provided for @phoneOptional.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف (اختياري)'**
  String get phoneOptional;

  /// No description provided for @bioOptional.
  ///
  /// In ar, this message translates to:
  /// **'نبذة شخصية (اختياري)'**
  String get bioOptional;

  /// No description provided for @bioHint.
  ///
  /// In ar, this message translates to:
  /// **'مهتم بالطاقة المتجددة...'**
  String get bioHint;

  /// No description provided for @createAccountBtn.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب'**
  String get createAccountBtn;

  /// No description provided for @pleaseVerifyEmail.
  ///
  /// In ar, this message translates to:
  /// **'يرجى التحقق من البريد الإلكتروني'**
  String get pleaseVerifyEmail;

  /// No description provided for @incorrectPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور غير صحيحة'**
  String get incorrectPassword;

  /// No description provided for @signInError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تسجيل الدخول'**
  String get signInError;

  /// No description provided for @googleSignInFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل تسجيل الدخول عبر جوجل'**
  String get googleSignInFailed;

  /// No description provided for @invalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صالح'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور قصيرة جداً (6 أحرف على الأقل)'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get passwordsDoNotMatch;

  /// No description provided for @signUpError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء التسجيل'**
  String get signUpError;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسمك الكامل'**
  String get pleaseEnterFullName;

  /// No description provided for @completeAccountError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء إكمال الحساب'**
  String get completeAccountError;

  /// No description provided for @usernameHintExample.
  ///
  /// In ar, this message translates to:
  /// **'مثال: ahmed_solar.99  |  3–30 حرفاً، إنجليزية فقط'**
  String get usernameHintExample;

  /// No description provided for @usernameAvailable.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم متاح ومقبول'**
  String get usernameAvailable;

  /// No description provided for @usernameRequiredError.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم مطلوب'**
  String get usernameRequiredError;

  /// No description provided for @usernameMinLengthError.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون 3 أحرف على الأقل'**
  String get usernameMinLengthError;

  /// No description provided for @usernameMaxLengthError.
  ///
  /// In ar, this message translates to:
  /// **'يجب ألا يتجاوز 30 حرفاً'**
  String get usernameMaxLengthError;

  /// No description provided for @usernameAllowedCharsError.
  ///
  /// In ar, this message translates to:
  /// **'يُسمح فقط بـ: أحرف إنجليزية، أرقام، نقطة، شرطة سفلية'**
  String get usernameAllowedCharsError;

  /// No description provided for @usernameStartCharError.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن أن يبدأ بنقطة أو شرطة سفلية'**
  String get usernameStartCharError;

  /// No description provided for @usernameEndCharError.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن أن ينتهي بنقطة أو شرطة سفلية'**
  String get usernameEndCharError;

  /// No description provided for @usernameConsecutiveCharsError.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن استخدام رمزين خاصين متتاليين'**
  String get usernameConsecutiveCharsError;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الملف الشخصي بنجاح'**
  String get profileUpdatedSuccess;

  /// No description provided for @saveEditsError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء حفظ التعديلات في السيرفر: {error}'**
  String saveEditsError(String error);

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @username.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get username;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الهاتف'**
  String get enterPhoneNumber;

  /// No description provided for @bio.
  ///
  /// In ar, this message translates to:
  /// **'نبذة شخصية'**
  String get bio;

  /// No description provided for @whoWeAre.
  ///
  /// In ar, this message translates to:
  /// **'من نحن؟'**
  String get whoWeAre;

  /// No description provided for @aboutDescription.
  ///
  /// In ar, this message translates to:
  /// **'نحن في \"شمس\" نؤمن بأن الطاقة المستقبلية يجب أن تكون نظيفة، مستدامة، وصالحة للجميع. نسعى جاهدين لتحويل كل منزل ومؤسسة إلى واحة من الطاقة المتجددة باستخدام أحدث الحلول التقنية.'**
  String get aboutDescription;

  /// No description provided for @ourVision.
  ///
  /// In ar, this message translates to:
  /// **'رؤيتنا'**
  String get ourVision;

  /// No description provided for @visionDescription.
  ///
  /// In ar, this message translates to:
  /// **'أن نكون الرواد في تمكين المجتمعات العربية من خلال الابتكار في تقنيات الطاقة الشمسية، لنبني مستقبل أنضر ومشرق للأجيال القادمة.'**
  String get visionDescription;

  /// No description provided for @whyChooseUs.
  ///
  /// In ar, this message translates to:
  /// **'لماذا تختارنا؟'**
  String get whyChooseUs;

  /// No description provided for @featureAccessibility.
  ///
  /// In ar, this message translates to:
  /// **'سهولة الوصول'**
  String get featureAccessibility;

  /// No description provided for @featureSustainability.
  ///
  /// In ar, this message translates to:
  /// **'الاستدامة'**
  String get featureSustainability;

  /// No description provided for @featureDirectWorkshop.
  ///
  /// In ar, this message translates to:
  /// **'ورشة مباشرة'**
  String get featureDirectWorkshop;

  /// No description provided for @featureHighReliability.
  ///
  /// In ar, this message translates to:
  /// **'موثوقية عالية'**
  String get featureHighReliability;

  /// No description provided for @featureContinuousSupport.
  ///
  /// In ar, this message translates to:
  /// **'دعم مستمر'**
  String get featureContinuousSupport;

  /// No description provided for @featureFastPerformance.
  ///
  /// In ar, this message translates to:
  /// **'أداء سريع'**
  String get featureFastPerformance;

  /// No description provided for @versionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار v1.0.0 Alpha'**
  String get versionLabel;

  /// No description provided for @copyrightLabel.
  ///
  /// In ar, this message translates to:
  /// **'جميع الحقوق محفوظة © 2026 شركة شمس'**
  String get copyrightLabel;

  /// No description provided for @privacyIntro.
  ///
  /// In ar, this message translates to:
  /// **'نحن نلتزم بحماية خصوصيتك وأمان بياناتك الشخصية. تتبع هذه الإعدادات التي تمنحك التحكم الكامل في كيفية معالجة ومشاركتك لمعلوماتك الشخصية لضمان تجربة آمنة ومتوازنة.'**
  String get privacyIntro;

  /// No description provided for @dataEncryption.
  ///
  /// In ar, this message translates to:
  /// **'تشفير البيانات'**
  String get dataEncryption;

  /// No description provided for @dataEncryptionBody.
  ///
  /// In ar, this message translates to:
  /// **'نحن نحمي بياناتك واستخدامها الشخصي بأعلى معايير الأمان. يتم تشفير جميع البيانات المرسلة بين الخادم والتطبيق باستخدام بروتوكول SSL/TLS.'**
  String get dataEncryptionBody;

  /// No description provided for @accountSecurity.
  ///
  /// In ar, this message translates to:
  /// **'أمان الحساب'**
  String get accountSecurity;

  /// No description provided for @accountSecurityBody.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تأمين حسابك عبر تفعيل التحقق بخطوتين، وإدارة الأجهزة المرتبطة بحسابك. نوصي بتغيير كلمة المرور بشكل دوري.'**
  String get accountSecurityBody;

  /// No description provided for @informationSharing.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة المعلومات'**
  String get informationSharing;

  /// No description provided for @informationSharingBody.
  ///
  /// In ar, this message translates to:
  /// **'تحكم في البيانات التي تشاركها مع الآخرين داخل المنصة. يمكنك في أي وقت مراجعة وإلغاء الأذونات الممنوحة للتطبيقات الأخرى.'**
  String get informationSharingBody;

  /// No description provided for @locationAccess.
  ///
  /// In ar, this message translates to:
  /// **'الوصول للموقع'**
  String get locationAccess;

  /// No description provided for @locationAccessBody.
  ///
  /// In ar, this message translates to:
  /// **'تستخدم المنصة الموقع الجغرافي فقط لتزويدك بخدمات ذات صلة بمنطقتك. يمكنك إلغاء هذا الإذن في أي وقت من إعدادات الجهاز.'**
  String get locationAccessBody;

  /// No description provided for @fullPrivacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية الكاملة'**
  String get fullPrivacyPolicy;

  /// No description provided for @markAllRead.
  ///
  /// In ar, this message translates to:
  /// **'قراءة الكل'**
  String get markAllRead;

  /// No description provided for @notificationDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الإشعار'**
  String get notificationDeleted;

  /// No description provided for @chatLoadError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تحميل المحادثة: {error}'**
  String chatLoadError(String error);

  /// No description provided for @maintenanceChatNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على محادثة لطلب الصيانة هذا'**
  String get maintenanceChatNotFound;

  /// No description provided for @noNotificationsNow.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات حالياً'**
  String get noNotificationsNow;

  /// No description provided for @notificationsWillAppearHere.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر إشعاراتك هنا عند وصولها'**
  String get notificationsWillAppearHere;

  /// No description provided for @chatsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحادثات'**
  String get chatsTitle;

  /// No description provided for @searchChatsHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في المحادثات...'**
  String get searchChatsHint;

  /// No description provided for @recentChats.
  ///
  /// In ar, this message translates to:
  /// **'المحادثات الأخيرة'**
  String get recentChats;

  /// No description provided for @selectedCount.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديد {count}'**
  String selectedCount(int count);

  /// No description provided for @deselectAll.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء تحديد الكل'**
  String get deselectAll;

  /// No description provided for @selectAll.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل'**
  String get selectAll;

  /// No description provided for @failedToLoadChats.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل المحادثات'**
  String get failedToLoadChats;

  /// No description provided for @noChatsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد محادثات بعد'**
  String get noChatsYet;

  /// No description provided for @startChatFromWorkshop.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ محادثة من صفحة ورشة لطلب الصيانة'**
  String get startChatFromWorkshop;

  /// No description provided for @exploreWorkshops.
  ///
  /// In ar, this message translates to:
  /// **'تصفح الورش'**
  String get exploreWorkshops;

  /// No description provided for @noChatsMatching.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد محادثات تطابق \"{query}\"'**
  String noChatsMatching(String query);

  /// No description provided for @chatFallbackTitle.
  ///
  /// In ar, this message translates to:
  /// **'محادثة'**
  String get chatFallbackTitle;

  /// No description provided for @noMessagesYetShort.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رسائل'**
  String get noMessagesYetShort;

  /// No description provided for @deleteChatTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المحادثة'**
  String get deleteChatTitle;

  /// No description provided for @deleteSelectedChatsTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المحادثات المحددة'**
  String get deleteSelectedChatsTitle;

  /// No description provided for @deleteChatConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد حذف هذه المحادثة نهائياً؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get deleteChatConfirm;

  /// No description provided for @deleteSelectedChatsConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد حذف المحادثات المحددة (عددها: {count}) نهائياً؟ لا يمكن التراجع عن هذا الإجراء.'**
  String deleteSelectedChatsConfirm(int count);

  /// No description provided for @chatDeletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المحادثة بنجاح'**
  String get chatDeletedSuccess;

  /// No description provided for @chatsDeletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المحادثات بنجاح'**
  String get chatsDeletedSuccess;

  /// No description provided for @deleteError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء الحذف'**
  String get deleteError;

  /// No description provided for @writeMessageHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالتك...'**
  String get writeMessageHint;

  /// No description provided for @failedToSendMessage.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إرسال الرسالة'**
  String get failedToSendMessage;

  /// No description provided for @chatMuted.
  ///
  /// In ar, this message translates to:
  /// **'تم كتم إشعارات هذه المحادثة'**
  String get chatMuted;

  /// No description provided for @chatUnmuted.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل إشعارات هذه المحادثة'**
  String get chatUnmuted;

  /// No description provided for @enableNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الإشعارات'**
  String get enableNotifications;

  /// No description provided for @muteNotifications.
  ///
  /// In ar, this message translates to:
  /// **'كتم الإشعارات'**
  String get muteNotifications;

  /// No description provided for @clearChat.
  ///
  /// In ar, this message translates to:
  /// **'مسح المحادثة'**
  String get clearChat;

  /// No description provided for @searchInChatHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في المحادثة...'**
  String get searchInChatHint;

  /// No description provided for @clearChatConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد مسح جميع الرسائل في هذه المحادثة؟'**
  String get clearChatConfirm;

  /// No description provided for @clearAction.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get clearAction;

  /// No description provided for @noMessagesYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رسائل بعد'**
  String get noMessagesYet;

  /// No description provided for @startConversationNow.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ المحادثة الآن!'**
  String get startConversationNow;

  /// No description provided for @homeSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن قبليات، مشاريع أو قطع غيار...'**
  String get homeSearchHint;

  /// No description provided for @noPostsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منشورات حتى الآن'**
  String get noPostsYet;

  /// No description provided for @postShared.
  ///
  /// In ar, this message translates to:
  /// **'تمت مشاركة المنشور'**
  String get postShared;

  /// No description provided for @savePost.
  ///
  /// In ar, this message translates to:
  /// **'حفظ المنشور'**
  String get savePost;

  /// No description provided for @followAccount.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الحساب'**
  String get followAccount;

  /// No description provided for @reportPost.
  ///
  /// In ar, this message translates to:
  /// **'الإبلاغ عن المنشور'**
  String get reportPost;

  /// No description provided for @postNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يُعثر على المنشور'**
  String get postNotFound;

  /// No description provided for @postDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المنشور'**
  String get postDetails;

  /// No description provided for @comments.
  ///
  /// In ar, this message translates to:
  /// **'التعليقات'**
  String get comments;

  /// No description provided for @writeCommentHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تعليقك هنا...'**
  String get writeCommentHint;

  /// No description provided for @noCommentsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تعليقات بعد.\nكن أول من يعلّق!'**
  String get noCommentsYet;

  /// No description provided for @copyText.
  ///
  /// In ar, this message translates to:
  /// **'نسخ النص'**
  String get copyText;

  /// No description provided for @commentCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ التعليق'**
  String get commentCopied;

  /// No description provided for @deleteComment.
  ///
  /// In ar, this message translates to:
  /// **'حذف التعليق'**
  String get deleteComment;

  /// No description provided for @addNewWork.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عمل جديد'**
  String get addNewWork;

  /// No description provided for @editPost.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المنشور'**
  String get editPost;

  /// No description provided for @addAttachment.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مرفق'**
  String get addAttachment;

  /// No description provided for @chooseFileType.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع الملف الذي تريد إرفاقه:'**
  String get chooseFileType;

  /// No description provided for @chooseAttachMethod.
  ///
  /// In ar, this message translates to:
  /// **'اختر طريقة الإرفاق:'**
  String get chooseAttachMethod;

  /// No description provided for @galleryPhotos.
  ///
  /// In ar, this message translates to:
  /// **'المعرض (صور)'**
  String get galleryPhotos;

  /// No description provided for @galleryVideo.
  ///
  /// In ar, this message translates to:
  /// **'المعرض (فيديو)'**
  String get galleryVideo;

  /// No description provided for @camera.
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا'**
  String get camera;

  /// No description provided for @cameraNotSupported.
  ///
  /// In ar, this message translates to:
  /// **'عذراً، الكاميرا أو هذه الميزة قد لا تكون مدعومة على هذا الجهاز حالياً.'**
  String get cameraNotSupported;

  /// No description provided for @addPostContentError.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إضافة محتوى أو صورة للمنشور'**
  String get addPostContentError;

  /// No description provided for @publishError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء النشر: {error}'**
  String publishError(String error);

  /// No description provided for @editPostError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تعديل المنشور: {error}'**
  String editPostError(String error);

  /// No description provided for @attachMedia.
  ///
  /// In ar, this message translates to:
  /// **'إرفاق صور أو فيديوهات'**
  String get attachMedia;

  /// No description provided for @documentSolarAchievements.
  ///
  /// In ar, this message translates to:
  /// **'وثّق إنجازاتك في الطاقة الشمسية'**
  String get documentSolarAchievements;

  /// No description provided for @postDetailsLabel.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المنشور'**
  String get postDetailsLabel;

  /// No description provided for @writePostDetailsHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تفاصيل المنشور هنا'**
  String get writePostDetailsHint;

  /// No description provided for @highlightPostInProfile.
  ///
  /// In ar, this message translates to:
  /// **'تمييز المنشور في البروفايل'**
  String get highlightPostInProfile;

  /// No description provided for @highlightPostSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سيظهر في أعلى صفحتك الشخصية'**
  String get highlightPostSubtitle;

  /// No description provided for @highlightPost.
  ///
  /// In ar, this message translates to:
  /// **'تمييز المنشور'**
  String get highlightPost;

  /// No description provided for @highlightHint.
  ///
  /// In ar, this message translates to:
  /// **'المنشورات المميزة تساعدك في الوصول لأفضل أعمالك بسرعة أكبر'**
  String get highlightHint;

  /// No description provided for @publishWorkNow.
  ///
  /// In ar, this message translates to:
  /// **'نشر العمل الآن'**
  String get publishWorkNow;

  /// No description provided for @searchWorkshopHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن الورشة المفضلة...'**
  String get searchWorkshopHint;

  /// No description provided for @noWorkshopsInCities.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ورش في المحافظات المحددة.'**
  String get noWorkshopsInCities;

  /// No description provided for @followToggleError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحديث المتابعة'**
  String get followToggleError;

  /// No description provided for @follow.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get follow;

  /// No description provided for @following.
  ///
  /// In ar, this message translates to:
  /// **'متابَع'**
  String get following;

  /// No description provided for @unfollow.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء المتابعة'**
  String get unfollow;

  /// No description provided for @enterWorkshop.
  ///
  /// In ar, this message translates to:
  /// **'عرض الورشة'**
  String get enterWorkshop;

  /// No description provided for @addWorkshop.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ورشة'**
  String get addWorkshop;

  /// No description provided for @fillRequiredFields.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تعبئة جميع الحقول المطلوبة'**
  String get fillRequiredFields;

  /// No description provided for @workshopAddedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة الورشة بنجاح!'**
  String get workshopAddedSuccess;

  /// No description provided for @workshopCreateFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل إنشاء الورشة'**
  String get workshopCreateFailed;

  /// No description provided for @workshopNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'اسم الورشة *'**
  String get workshopNameRequired;

  /// No description provided for @enterFullWorkshopName.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم الورشة الكامل'**
  String get enterFullWorkshopName;

  /// No description provided for @yearsOfExperience.
  ///
  /// In ar, this message translates to:
  /// **'سنوات الخبرة'**
  String get yearsOfExperience;

  /// No description provided for @governorateRequired.
  ///
  /// In ar, this message translates to:
  /// **'المحافظة *'**
  String get governorateRequired;

  /// No description provided for @selectGovernorate.
  ///
  /// In ar, this message translates to:
  /// **'اختر المحافظة'**
  String get selectGovernorate;

  /// No description provided for @servicesDescriptionRequired.
  ///
  /// In ar, this message translates to:
  /// **'وصف مختصر للخدمات *'**
  String get servicesDescriptionRequired;

  /// No description provided for @servicesDescriptionHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب وصفاً موجزاً للخدمات التي تقدمها الورشة...'**
  String get servicesDescriptionHint;

  /// No description provided for @workshopImages.
  ///
  /// In ar, this message translates to:
  /// **'صور الورشة'**
  String get workshopImages;

  /// No description provided for @createWorkshopBtn.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الورشة'**
  String get createWorkshopBtn;

  /// No description provided for @changeCover.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الغلاف'**
  String get changeCover;

  /// No description provided for @tapToAddCover.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لإضافة صورة الغلاف'**
  String get tapToAddCover;

  /// No description provided for @myWorkshopOnShams.
  ///
  /// In ar, this message translates to:
  /// **'ورشتي على شمس'**
  String get myWorkshopOnShams;

  /// No description provided for @editWorkshopProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل ملف الورشة'**
  String get editWorkshopProfile;

  /// No description provided for @followers.
  ///
  /// In ar, this message translates to:
  /// **'المتابعون'**
  String get followers;

  /// No description provided for @postsCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'المنشورات'**
  String get postsCountLabel;

  /// No description provided for @publishedWorkLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل الأعمال المنشور'**
  String get publishedWorkLog;

  /// No description provided for @noPublishedWorkYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أعمال منشورة حالياً.\nاضغط \"نشر عمل جديد\" للبدء!'**
  String get noPublishedWorkYet;

  /// No description provided for @publishNewWork.
  ///
  /// In ar, this message translates to:
  /// **'نشر عمل جديد'**
  String get publishNewWork;

  /// No description provided for @deletePostTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المنشور'**
  String get deletePostTitle;

  /// No description provided for @deletePostConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا المنشور؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get deletePostConfirm;

  /// No description provided for @postDeletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المنشور بنجاح'**
  String get postDeletedSuccess;

  /// No description provided for @deletePostFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حذف المنشور'**
  String get deletePostFailed;

  /// No description provided for @uploadCoverFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر رفع صورة الغلاف'**
  String get uploadCoverFailed;

  /// No description provided for @uploadLogoFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر رفع شعار الورشة'**
  String get uploadLogoFailed;

  /// No description provided for @uploadImageFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر رفع الصورة'**
  String get uploadImageFailed;

  /// No description provided for @deleteImageFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حذف الصورة'**
  String get deleteImageFailed;

  /// No description provided for @cameraUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا غير متاحة على هذا الجهاز.'**
  String get cameraUnavailable;

  /// No description provided for @workshopNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم الورشة'**
  String get workshopNameLabel;

  /// No description provided for @governorateLabel.
  ///
  /// In ar, this message translates to:
  /// **'المحافظة'**
  String get governorateLabel;

  /// No description provided for @workshopInfoSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ معلومات الورشة بنجاح'**
  String get workshopInfoSaved;

  /// No description provided for @saveEditsFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ التعديلات'**
  String get saveEditsFailed;

  /// No description provided for @workshopUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الورشة المطلوبة غير متوفرة حالياً.'**
  String get workshopUnavailable;

  /// No description provided for @requestMaintenanceNow.
  ///
  /// In ar, this message translates to:
  /// **'طلب خدمة صيانة الآن'**
  String get requestMaintenanceNow;

  /// No description provided for @searchInWorkshopHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في الورشة...'**
  String get searchInWorkshopHint;

  /// No description provided for @reviewsCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'({count} تقييم)'**
  String reviewsCountLabel(int count);

  /// No description provided for @contactSoon.
  ///
  /// In ar, this message translates to:
  /// **'ميزة التواصل متوفرة قريباً'**
  String get contactSoon;

  /// No description provided for @workLogTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل الأعمال'**
  String get workLogTitle;

  /// No description provided for @fullWorkLogSoon.
  ///
  /// In ar, this message translates to:
  /// **'فتح سجل الأعمال بالكامل (قريباً)...'**
  String get fullWorkLogSoon;

  /// No description provided for @noWorkLogYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أعمال في هذا السجل حالياً.'**
  String get noWorkLogYet;

  /// No description provided for @reviewsAndOpinions.
  ///
  /// In ar, this message translates to:
  /// **'التقييمات والآراء'**
  String get reviewsAndOpinions;

  /// No description provided for @addYourReview.
  ///
  /// In ar, this message translates to:
  /// **'أضف تقييمك'**
  String get addYourReview;

  /// No description provided for @editMyReview.
  ///
  /// In ar, this message translates to:
  /// **'تعديل تقييمي'**
  String get editMyReview;

  /// No description provided for @failedToLoadReviews.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل التقييمات'**
  String get failedToLoadReviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تقييمات لهذه الورشة حتى الآن'**
  String get noReviewsYet;

  /// No description provided for @beFirstToReview.
  ///
  /// In ar, this message translates to:
  /// **'كن أول من يشارك تجربته مع هذه الورشة'**
  String get beFirstToReview;

  /// No description provided for @editReview.
  ///
  /// In ar, this message translates to:
  /// **'تعديل التقييم'**
  String get editReview;

  /// No description provided for @deleteReviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف التقييم'**
  String get deleteReviewTitle;

  /// No description provided for @deleteReviewConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في حذف تقييمك لهذه الورشة؟'**
  String get deleteReviewConfirm;

  /// No description provided for @reviewDeletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف التقييم'**
  String get reviewDeletedSuccess;

  /// No description provided for @reviewDeleteFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حذف التقييم'**
  String get reviewDeleteFailed;

  /// No description provided for @reviewUpdatedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث تقييمك بنجاح'**
  String get reviewUpdatedSuccess;

  /// No description provided for @reviewPublishedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم نشر تقييمك بنجاح'**
  String get reviewPublishedSuccess;

  /// No description provided for @editYourReviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل تقييمك'**
  String get editYourReviewTitle;

  /// No description provided for @addWorkshopReviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'أضف تقييمك للورشة'**
  String get addWorkshopReviewTitle;

  /// No description provided for @ratingOutOfFive.
  ///
  /// In ar, this message translates to:
  /// **'{rating} من 5'**
  String ratingOutOfFive(int rating);

  /// No description provided for @ratingPoor.
  ///
  /// In ar, this message translates to:
  /// **'ضعيف'**
  String get ratingPoor;

  /// No description provided for @ratingFair.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get ratingFair;

  /// No description provided for @ratingGood.
  ///
  /// In ar, this message translates to:
  /// **'جيد'**
  String get ratingGood;

  /// No description provided for @ratingVeryGood.
  ///
  /// In ar, this message translates to:
  /// **'جيد جداً'**
  String get ratingVeryGood;

  /// No description provided for @ratingExcellent.
  ///
  /// In ar, this message translates to:
  /// **'ممتاز'**
  String get ratingExcellent;

  /// No description provided for @reviewCommentHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تعليقك عن الخدمة وجودة التنفيذ'**
  String get reviewCommentHint;

  /// No description provided for @pleaseWriteReviewComment.
  ///
  /// In ar, this message translates to:
  /// **'يرجى كتابة تعليق عن تجربتك مع الورشة'**
  String get pleaseWriteReviewComment;

  /// No description provided for @publishReview.
  ///
  /// In ar, this message translates to:
  /// **'نشر التقييم'**
  String get publishReview;

  /// No description provided for @requestMaintenanceFrom.
  ///
  /// In ar, this message translates to:
  /// **'طلب خدمة صيانة من {name}'**
  String requestMaintenanceFrom(String name);

  /// No description provided for @selectServiceAndDetails.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تحديد نوع الخدمة وتفاصيل المشكلة'**
  String get selectServiceAndDetails;

  /// No description provided for @sendingMaintenanceRequest.
  ///
  /// In ar, this message translates to:
  /// **'جاري إرسال الطلب وإنشاء المحادثة...'**
  String get sendingMaintenanceRequest;

  /// No description provided for @maintenanceRequestFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل في إرسال الطلب، يرجى المحاولة لاحقاً'**
  String get maintenanceRequestFailed;

  /// No description provided for @requiredServiceType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الخدمة المطلوبة'**
  String get requiredServiceType;

  /// No description provided for @inverterType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المحول (الإنفرتر)'**
  String get inverterType;

  /// No description provided for @batteryType.
  ///
  /// In ar, this message translates to:
  /// **'نوع البطاريات'**
  String get batteryType;

  /// No description provided for @systemSizeHint.
  ///
  /// In ar, this message translates to:
  /// **'حجم المنظومة (بالوات) - اختياري'**
  String get systemSizeHint;

  /// No description provided for @problemDetailsHint.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المشكلة (مثال: الشحن ضعيف وقت الظهيرة...)'**
  String get problemDetailsHint;

  /// No description provided for @sendRequest.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب'**
  String get sendRequest;

  /// No description provided for @cityCapital.
  ///
  /// In ar, this message translates to:
  /// **'أمانة العاصمة'**
  String get cityCapital;

  /// No description provided for @citySanaa.
  ///
  /// In ar, this message translates to:
  /// **'صنعاء'**
  String get citySanaa;

  /// No description provided for @cityAden.
  ///
  /// In ar, this message translates to:
  /// **'عدن'**
  String get cityAden;

  /// No description provided for @cityTaiz.
  ///
  /// In ar, this message translates to:
  /// **'تعز'**
  String get cityTaiz;

  /// No description provided for @cityHudaydah.
  ///
  /// In ar, this message translates to:
  /// **'الحديدة'**
  String get cityHudaydah;

  /// No description provided for @cityIbb.
  ///
  /// In ar, this message translates to:
  /// **'إب'**
  String get cityIbb;

  /// No description provided for @cityHadramaut.
  ///
  /// In ar, this message translates to:
  /// **'حضرموت'**
  String get cityHadramaut;

  /// No description provided for @cityDhamar.
  ///
  /// In ar, this message translates to:
  /// **'ذمار'**
  String get cityDhamar;

  /// No description provided for @cityAmran.
  ///
  /// In ar, this message translates to:
  /// **'عمران'**
  String get cityAmran;

  /// No description provided for @cityDhale.
  ///
  /// In ar, this message translates to:
  /// **'الضالع'**
  String get cityDhale;

  /// No description provided for @cityLahij.
  ///
  /// In ar, this message translates to:
  /// **'لحج'**
  String get cityLahij;

  /// No description provided for @cityAbyan.
  ///
  /// In ar, this message translates to:
  /// **'أبين'**
  String get cityAbyan;

  /// No description provided for @cityMahrah.
  ///
  /// In ar, this message translates to:
  /// **'المهرة'**
  String get cityMahrah;

  /// No description provided for @cityShabwah.
  ///
  /// In ar, this message translates to:
  /// **'شبوة'**
  String get cityShabwah;

  /// No description provided for @cityBayda.
  ///
  /// In ar, this message translates to:
  /// **'البيضاء'**
  String get cityBayda;

  /// No description provided for @cityMarib.
  ///
  /// In ar, this message translates to:
  /// **'مأرب'**
  String get cityMarib;

  /// No description provided for @cityJawf.
  ///
  /// In ar, this message translates to:
  /// **'الجوف'**
  String get cityJawf;

  /// No description provided for @citySaada.
  ///
  /// In ar, this message translates to:
  /// **'صعدة'**
  String get citySaada;

  /// No description provided for @cityMahwit.
  ///
  /// In ar, this message translates to:
  /// **'المحويت'**
  String get cityMahwit;

  /// No description provided for @cityHajjah.
  ///
  /// In ar, this message translates to:
  /// **'حجة'**
  String get cityHajjah;

  /// No description provided for @cityRaymah.
  ///
  /// In ar, this message translates to:
  /// **'ريمة'**
  String get cityRaymah;

  /// No description provided for @citySocotra.
  ///
  /// In ar, this message translates to:
  /// **'سقطرى'**
  String get citySocotra;

  /// No description provided for @serviceInstallNewSystem.
  ///
  /// In ar, this message translates to:
  /// **'تركيب منظومة جديدة'**
  String get serviceInstallNewSystem;

  /// No description provided for @serviceSolarPanelMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'صيانة ألواح شمسية'**
  String get serviceSolarPanelMaintenance;

  /// No description provided for @serviceInverterMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'صيانة عاكس (Inverter)'**
  String get serviceInverterMaintenance;

  /// No description provided for @serviceBatteryMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'صيانة بطاريات'**
  String get serviceBatteryMaintenance;

  /// No description provided for @serviceSolarWaterPumps.
  ///
  /// In ar, this message translates to:
  /// **'مضخات مياه شمسية'**
  String get serviceSolarWaterPumps;

  /// No description provided for @serviceFullInspection.
  ///
  /// In ar, this message translates to:
  /// **'فحص شامل للمنظومة'**
  String get serviceFullInspection;

  /// No description provided for @serviceSpareParts.
  ///
  /// In ar, this message translates to:
  /// **'توريد قطع غيار'**
  String get serviceSpareParts;

  /// No description provided for @batteryLithium.
  ///
  /// In ar, this message translates to:
  /// **'ليثيوم (LiFePO4)'**
  String get batteryLithium;

  /// No description provided for @batteryGel.
  ///
  /// In ar, this message translates to:
  /// **'جل (Gel)'**
  String get batteryGel;

  /// No description provided for @batteryAgm.
  ///
  /// In ar, this message translates to:
  /// **'حمض رصاص (AGM)'**
  String get batteryAgm;

  /// No description provided for @errNoInternet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get errNoInternet;

  /// No description provided for @errUnexpected.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get errUnexpected;

  /// No description provided for @errSignInFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل تسجيل الدخول'**
  String get errSignInFailed;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو كلمة المرور غير صحيحة'**
  String get errInvalidCredentials;

  /// No description provided for @errConfirmEmail.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تأكيد بريدك الإلكتروني أولاً'**
  String get errConfirmEmail;

  /// No description provided for @errCreateAccountFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل إنشاء الحساب'**
  String get errCreateAccountFailed;

  /// No description provided for @errEmailAlreadyRegistered.
  ///
  /// In ar, this message translates to:
  /// **'هذا البريد الإلكتروني مسجل مسبقاً، حاول تسجيل الدخول من الشاشة السابقة'**
  String get errEmailAlreadyRegistered;

  /// No description provided for @errNoSignedInUser.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مستخدم مسجل دخول'**
  String get errNoSignedInUser;

  /// No description provided for @errUserNotSignedIn.
  ///
  /// In ar, this message translates to:
  /// **'المستخدم غير مسجل الدخول'**
  String get errUserNotSignedIn;

  /// No description provided for @errInvalidWorkshopId.
  ///
  /// In ar, this message translates to:
  /// **'معرّف الورشة غير صالح'**
  String get errInvalidWorkshopId;

  /// No description provided for @errInvalidReviewId.
  ///
  /// In ar, this message translates to:
  /// **'معرّف التقييم غير صالح'**
  String get errInvalidReviewId;

  /// No description provided for @errSelectRatingRange.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار تقييم من 1 إلى 5 نجوم'**
  String get errSelectRatingRange;

  /// No description provided for @errNoChangesToSave.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تعديلات لحفظها'**
  String get errNoChangesToSave;

  /// No description provided for @errImageUploadFailedWithReason.
  ///
  /// In ar, this message translates to:
  /// **'فشل رفع الصورة: {reason}'**
  String errImageUploadFailedWithReason(String reason);

  /// No description provided for @errPhotoUploadErrorWithReason.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء رفع الصورة: {reason}'**
  String errPhotoUploadErrorWithReason(String reason);

  /// No description provided for @errProfileUpdateErrorWithReason.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تحديث بيانات الملف: {reason}'**
  String errProfileUpdateErrorWithReason(String reason);
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
