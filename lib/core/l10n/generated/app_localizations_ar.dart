// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'شمس';

  @override
  String get editProfile => 'تعديل الملف';

  @override
  String get myBusiness => 'إدارة أعمالي';

  @override
  String get settingsPreferences => 'الإعدادات والتفضيلات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get privacySecurity => 'الخصوصية والأمان';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get contactSupport => 'تواصل مع الدعم';

  @override
  String get technicalSupport => 'تواصل مع الدعم الفني';

  @override
  String get aboutShams => 'عن شمس';

  @override
  String get shareApp => 'مشاركة التطبيق';

  @override
  String get shareAppText =>
      'حمّل تطبيق شمس وانضم إلينا الآن!\nhttps://shams.app/download';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutTitle => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get logoutError => 'حدث خطأ أثناء تسجيل الخروج';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get workshopDashboard => 'لوحة تحكم الورشة';

  @override
  String get workshopDashboardSubtitle => 'إدارة منشوراتك وإحصاءات ورشتك';

  @override
  String get addNewWorkshop => 'إضافة ورشة جديدة';

  @override
  String get addNewWorkshopSubtitle => 'انقر هنا لإضافة تفاصيل الورشة';

  @override
  String get workshopCreatedSuccess => 'تم إنشاء الورشة بنجاح! 🎉';

  @override
  String get arabic => 'عربي';

  @override
  String get english => 'English';

  @override
  String get arabicOption => 'عربي (AR)';

  @override
  String get englishOption => 'English (EN)';

  @override
  String get home => 'الصفحة الرئيسية';

  @override
  String get workshops => 'قائمة الورش';

  @override
  String get myChats => 'محادثاتي';

  @override
  String get governorates => 'المحافظات';

  @override
  String get selectGovernorates => 'اختر المحافظات';

  @override
  String get done => 'تم';

  @override
  String get readMore => 'قراءة المزيد...';

  @override
  String get showLess => 'عرض أقل';

  @override
  String get chooseFromGallery => 'اختر من المعرض';

  @override
  String get takePhoto => 'التقط صورة';

  @override
  String get whatsapp => 'واتساب';

  @override
  String get phoneCall => 'اتصال هاتفي';

  @override
  String get email => 'إيميل';

  @override
  String get emailFull => 'البريد الإلكتروني';

  @override
  String get whatsappError =>
      'لم نتمكن من فتح تطبيق واتساب. يرجى التأكد من تثبيت التطبيق.';

  @override
  String get phoneError => 'تعذر إجراء الاتصال الهاتفي حالياً.';

  @override
  String get emailError => 'لم نتمكن من فتح تطبيق البريد الإلكتروني.';

  @override
  String get signin => 'تسجيل الدخول';

  @override
  String get signup => 'إنشاء حساب';

  @override
  String get password => 'كلمة المرور';

  @override
  String get workshopOwner => 'صاحب ورشة 🛠️';

  @override
  String get shamsClient => 'عميل شمس ☀️';

  @override
  String get editMyProfile => 'تعديل الملف الشخصي';

  @override
  String get myMaintenanceRequests => 'طلبات الصيانة الخاصة بي';

  @override
  String get aboutShamsPlatform => 'عن منصة شمس';

  @override
  String get technicalSupportContact => 'الدعم الفني والاتصال';

  @override
  String get nowRelative => 'الآن';

  @override
  String minutesAgo(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String hoursAgo(int count) {
    return 'منذ $count ساعة';
  }

  @override
  String daysAgo(int count) {
    return 'منذ $count يوم';
  }

  @override
  String get inlineSearchHint => 'ابحث عن ورشة...';

  @override
  String get searchHint => 'ابحث هنا...';

  @override
  String get homeNav => 'الرئيسية';

  @override
  String get workshopsNav => 'الورش';

  @override
  String get followNav => 'المتابعة';

  @override
  String get profileNav => 'الملف';

  @override
  String get technicalSupportTitle => 'تواصل مع الدعم الفني';

  @override
  String get welcomeBack => 'مرحباً بك مجدداً';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get profileLoadError => 'فشل تحميل الملف الشخصي';

  @override
  String get add => 'إضافة';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get close => 'إغلاق';

  @override
  String get back => 'رجوع';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get search => 'بحث';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String noResultsFor(String query) {
    return 'لا توجد نتائج لـ \"$query\"';
  }

  @override
  String get tryDifferentKeyword => 'جرّب كلمة مختلفة';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get saveEdits => 'حفظ التعديلات';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get like => 'إعجاب';

  @override
  String get unknownUser => 'مستخدم غير معروف';

  @override
  String get userFallback => 'مستخدم';

  @override
  String get shamsUser => 'مستخدم شمس';

  @override
  String get shamsClientPlain => 'عميل شمس';

  @override
  String get loadingLabel => 'جاري التحميل...';

  @override
  String get yesterday => 'أمس';

  @override
  String get today => 'اليوم';

  @override
  String get other => 'أخرى';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get video => 'فيديو';

  @override
  String get photo => 'صورة';

  @override
  String get newLabel => 'جديد';

  @override
  String get monthJan => 'يناير';

  @override
  String get monthFeb => 'فبراير';

  @override
  String get monthMar => 'مارس';

  @override
  String get monthApr => 'أبريل';

  @override
  String get monthMay => 'مايو';

  @override
  String get monthJun => 'يونيو';

  @override
  String get monthJul => 'يوليو';

  @override
  String get monthAug => 'أغسطس';

  @override
  String get monthSep => 'سبتمبر';

  @override
  String get monthOct => 'أكتوبر';

  @override
  String get monthNov => 'نوفمبر';

  @override
  String get monthDec => 'ديسمبر';

  @override
  String get welcomeTagline => 'طاقة موثوقة.. لمجتمع متصل';

  @override
  String get highEfficiency => 'كفاءة عالية';

  @override
  String get smartControl => 'تحكم ذكي';

  @override
  String get termsOfServiceNotice =>
      'من خلال الاستمرار، أنت توافق على شروط الخدمة';

  @override
  String get welcomeBackExclaim => 'مرحباً بعودتك!';

  @override
  String get signInSubtitle => 'سجل الدخول للمتابعة في رحلتك مع شمس';

  @override
  String get emailOrPhone => 'البريد الإلكتروني أو الهاتف';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get signInWithGoogle => 'تسجيل الدخول بواسطة Google';

  @override
  String get joinUsNow => 'انضم إلينا الآن';

  @override
  String get joinShamsCommunity => 'انضم إلى مجتمع شمس';

  @override
  String get signUpSubtitle => 'خطوتك الأولى لتجربة فريدة ومتميزة معنا';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get next => 'التالي';

  @override
  String get orSignUpWith => 'أو إنشاء حساب عبر';

  @override
  String get completeYourProfile => 'أكمل ملفك الشخصي';

  @override
  String get completeProfileSubtitle => 'دع مجتمع شمس يتعرف عليك أكثر';

  @override
  String get fullNameRequired => 'الاسم الكامل *';

  @override
  String get enterFullName => 'أدخل اسمك الكامل';

  @override
  String get usernameRequiredLabel => 'اسم المستخدم *';

  @override
  String get enterUsername => 'أدخل اسم المستخدم';

  @override
  String get locationRequiredLabel => 'الموقع *';

  @override
  String get phoneOptional => 'رقم الهاتف (اختياري)';

  @override
  String get bioOptional => 'نبذة شخصية (اختياري)';

  @override
  String get bioHint => 'مهتم بالطاقة المتجددة...';

  @override
  String get createAccountBtn => 'إنشاء الحساب';

  @override
  String get pleaseVerifyEmail => 'يرجى التحقق من البريد الإلكتروني';

  @override
  String get incorrectPassword => 'كلمة المرور غير صحيحة';

  @override
  String get signInError => 'حدث خطأ أثناء تسجيل الدخول';

  @override
  String get googleSignInFailed => 'فشل تسجيل الدخول عبر جوجل';

  @override
  String get invalidEmail => 'البريد الإلكتروني غير صالح';

  @override
  String get passwordTooShort => 'كلمة المرور قصيرة جداً (6 أحرف على الأقل)';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get signUpError => 'حدث خطأ أثناء التسجيل';

  @override
  String get pleaseEnterFullName => 'يرجى إدخال اسمك الكامل';

  @override
  String get completeAccountError => 'حدث خطأ أثناء إكمال الحساب';

  @override
  String get usernameHintExample =>
      'مثال: ahmed_solar.99  |  3–30 حرفاً، إنجليزية فقط';

  @override
  String get usernameAvailable => 'اسم المستخدم متاح ومقبول';

  @override
  String get usernameRequiredError => 'اسم المستخدم مطلوب';

  @override
  String get usernameMinLengthError => 'يجب أن يكون 3 أحرف على الأقل';

  @override
  String get usernameMaxLengthError => 'يجب ألا يتجاوز 30 حرفاً';

  @override
  String get usernameAllowedCharsError =>
      'يُسمح فقط بـ: أحرف إنجليزية، أرقام، نقطة، شرطة سفلية';

  @override
  String get usernameStartCharError => 'لا يمكن أن يبدأ بنقطة أو شرطة سفلية';

  @override
  String get usernameEndCharError => 'لا يمكن أن ينتهي بنقطة أو شرطة سفلية';

  @override
  String get usernameConsecutiveCharsError =>
      'لا يمكن استخدام رمزين خاصين متتاليين';

  @override
  String get profileUpdatedSuccess => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String saveEditsError(String error) {
    return 'حدث خطأ أثناء حفظ التعديلات في السيرفر: $error';
  }

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get enterPhoneNumber => 'أدخل رقم الهاتف';

  @override
  String get bio => 'نبذة شخصية';

  @override
  String get whoWeAre => 'من نحن؟';

  @override
  String get aboutDescription =>
      'نحن في \"شمس\" نؤمن بأن الطاقة المستقبلية يجب أن تكون نظيفة، مستدامة، وصالحة للجميع. نسعى جاهدين لتحويل كل منزل ومؤسسة إلى واحة من الطاقة المتجددة باستخدام أحدث الحلول التقنية.';

  @override
  String get ourVision => 'رؤيتنا';

  @override
  String get visionDescription =>
      'أن نكون الرواد في تمكين المجتمعات العربية من خلال الابتكار في تقنيات الطاقة الشمسية، لنبني مستقبل أنضر ومشرق للأجيال القادمة.';

  @override
  String get whyChooseUs => 'لماذا تختارنا؟';

  @override
  String get featureAccessibility => 'سهولة الوصول';

  @override
  String get featureSustainability => 'الاستدامة';

  @override
  String get featureDirectWorkshop => 'ورشة مباشرة';

  @override
  String get featureHighReliability => 'موثوقية عالية';

  @override
  String get featureContinuousSupport => 'دعم مستمر';

  @override
  String get featureFastPerformance => 'أداء سريع';

  @override
  String get versionLabel => 'الإصدار v1.0.0 Alpha';

  @override
  String get copyrightLabel => 'جميع الحقوق محفوظة © 2026 شركة شمس';

  @override
  String get privacyIntro =>
      'نحن نلتزم بحماية خصوصيتك وأمان بياناتك الشخصية. تتبع هذه الإعدادات التي تمنحك التحكم الكامل في كيفية معالجة ومشاركتك لمعلوماتك الشخصية لضمان تجربة آمنة ومتوازنة.';

  @override
  String get dataEncryption => 'تشفير البيانات';

  @override
  String get dataEncryptionBody =>
      'نحن نحمي بياناتك واستخدامها الشخصي بأعلى معايير الأمان. يتم تشفير جميع البيانات المرسلة بين الخادم والتطبيق باستخدام بروتوكول SSL/TLS.';

  @override
  String get accountSecurity => 'أمان الحساب';

  @override
  String get accountSecurityBody =>
      'يمكنك تأمين حسابك عبر تفعيل التحقق بخطوتين، وإدارة الأجهزة المرتبطة بحسابك. نوصي بتغيير كلمة المرور بشكل دوري.';

  @override
  String get informationSharing => 'مشاركة المعلومات';

  @override
  String get informationSharingBody =>
      'تحكم في البيانات التي تشاركها مع الآخرين داخل المنصة. يمكنك في أي وقت مراجعة وإلغاء الأذونات الممنوحة للتطبيقات الأخرى.';

  @override
  String get locationAccess => 'الوصول للموقع';

  @override
  String get locationAccessBody =>
      'تستخدم المنصة الموقع الجغرافي فقط لتزويدك بخدمات ذات صلة بمنطقتك. يمكنك إلغاء هذا الإذن في أي وقت من إعدادات الجهاز.';

  @override
  String get fullPrivacyPolicy => 'سياسة الخصوصية الكاملة';

  @override
  String get markAllRead => 'قراءة الكل';

  @override
  String get notificationDeleted => 'تم حذف الإشعار';

  @override
  String chatLoadError(String error) {
    return 'حدث خطأ أثناء تحميل المحادثة: $error';
  }

  @override
  String get maintenanceChatNotFound =>
      'لم يتم العثور على محادثة لطلب الصيانة هذا';

  @override
  String get noNotificationsNow => 'لا توجد إشعارات حالياً';

  @override
  String get notificationsWillAppearHere => 'ستظهر إشعاراتك هنا عند وصولها';

  @override
  String get chatsTitle => 'المحادثات';

  @override
  String get searchChatsHint => 'ابحث في المحادثات...';

  @override
  String get recentChats => 'المحادثات الأخيرة';

  @override
  String selectedCount(int count) {
    return 'تم تحديد $count';
  }

  @override
  String get deselectAll => 'إلغاء تحديد الكل';

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String get failedToLoadChats => 'تعذر تحميل المحادثات';

  @override
  String get noChatsYet => 'لا توجد محادثات بعد';

  @override
  String get startChatFromWorkshop => 'ابدأ محادثة من صفحة ورشة لطلب الصيانة';

  @override
  String get exploreWorkshops => 'تصفح الورش';

  @override
  String noChatsMatching(String query) {
    return 'لا توجد محادثات تطابق \"$query\"';
  }

  @override
  String get chatFallbackTitle => 'محادثة';

  @override
  String get noMessagesYetShort => 'لا توجد رسائل';

  @override
  String get deleteChatTitle => 'حذف المحادثة';

  @override
  String get deleteSelectedChatsTitle => 'حذف المحادثات المحددة';

  @override
  String get deleteChatConfirm =>
      'هل أنت متأكد أنك تريد حذف هذه المحادثة نهائياً؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String deleteSelectedChatsConfirm(int count) {
    return 'هل أنت متأكد أنك تريد حذف المحادثات المحددة (عددها: $count) نهائياً؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get chatDeletedSuccess => 'تم حذف المحادثة بنجاح';

  @override
  String get chatsDeletedSuccess => 'تم حذف المحادثات بنجاح';

  @override
  String get deleteError => 'حدث خطأ أثناء الحذف';

  @override
  String get writeMessageHint => 'اكتب رسالتك...';

  @override
  String get failedToSendMessage => 'تعذر إرسال الرسالة';

  @override
  String get chatMuted => 'تم كتم إشعارات هذه المحادثة';

  @override
  String get chatUnmuted => 'تم تفعيل إشعارات هذه المحادثة';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get muteNotifications => 'كتم الإشعارات';

  @override
  String get clearChat => 'مسح المحادثة';

  @override
  String get searchInChatHint => 'ابحث في المحادثة...';

  @override
  String get clearChatConfirm =>
      'هل أنت متأكد أنك تريد مسح جميع الرسائل في هذه المحادثة؟';

  @override
  String get clearAction => 'مسح';

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get startConversationNow => 'ابدأ المحادثة الآن!';

  @override
  String get homeSearchHint => 'ابحث عن قبليات، مشاريع أو قطع غيار...';

  @override
  String get noPostsYet => 'لا توجد منشورات حتى الآن';

  @override
  String get postShared => 'تمت مشاركة المنشور';

  @override
  String get savePost => 'حفظ المنشور';

  @override
  String get followAccount => 'متابعة الحساب';

  @override
  String get reportPost => 'الإبلاغ عن المنشور';

  @override
  String get postNotFound => 'لم يُعثر على المنشور';

  @override
  String get postDetails => 'تفاصيل المنشور';

  @override
  String get comments => 'التعليقات';

  @override
  String get writeCommentHint => 'اكتب تعليقك هنا...';

  @override
  String get noCommentsYet => 'لا توجد تعليقات بعد.\nكن أول من يعلّق!';

  @override
  String get copyText => 'نسخ النص';

  @override
  String get commentCopied => 'تم نسخ التعليق';

  @override
  String get deleteComment => 'حذف التعليق';

  @override
  String get addNewWork => 'إضافة عمل جديد';

  @override
  String get editPost => 'تعديل المنشور';

  @override
  String get addAttachment => 'إضافة مرفق';

  @override
  String get chooseFileType => 'اختر نوع الملف الذي تريد إرفاقه:';

  @override
  String get chooseAttachMethod => 'اختر طريقة الإرفاق:';

  @override
  String get galleryPhotos => 'المعرض (صور)';

  @override
  String get galleryVideo => 'المعرض (فيديو)';

  @override
  String get camera => 'الكاميرا';

  @override
  String get cameraNotSupported =>
      'عذراً، الكاميرا أو هذه الميزة قد لا تكون مدعومة على هذا الجهاز حالياً.';

  @override
  String get addPostContentError => 'الرجاء إضافة محتوى أو صورة للمنشور';

  @override
  String publishError(String error) {
    return 'حدث خطأ أثناء النشر: $error';
  }

  @override
  String editPostError(String error) {
    return 'حدث خطأ أثناء تعديل المنشور: $error';
  }

  @override
  String get attachMedia => 'إرفاق صور أو فيديوهات';

  @override
  String get documentSolarAchievements => 'وثّق إنجازاتك في الطاقة الشمسية';

  @override
  String get postDetailsLabel => 'تفاصيل المنشور';

  @override
  String get writePostDetailsHint => 'اكتب تفاصيل المنشور هنا';

  @override
  String get highlightPostInProfile => 'تمييز المنشور في البروفايل';

  @override
  String get highlightPostSubtitle => 'سيظهر في أعلى صفحتك الشخصية';

  @override
  String get highlightPost => 'تمييز المنشور';

  @override
  String get highlightHint =>
      'المنشورات المميزة تساعدك في الوصول لأفضل أعمالك بسرعة أكبر';

  @override
  String get publishWorkNow => 'نشر العمل الآن';

  @override
  String get searchWorkshopHint => 'ابحث عن الورشة المفضلة...';

  @override
  String get noWorkshopsInCities => 'لا توجد ورش في المحافظات المحددة.';

  @override
  String get followToggleError => 'تعذر تحديث المتابعة';

  @override
  String get follow => 'متابعة';

  @override
  String get following => 'متابَع';

  @override
  String get unfollow => 'إلغاء المتابعة';

  @override
  String get enterWorkshop => 'عرض الورشة';

  @override
  String get addWorkshop => 'إضافة ورشة';

  @override
  String get fillRequiredFields => 'يرجى تعبئة جميع الحقول المطلوبة';

  @override
  String get workshopAddedSuccess => 'تم إضافة الورشة بنجاح!';

  @override
  String get workshopCreateFailed => 'فشل إنشاء الورشة';

  @override
  String get workshopNameRequired => 'اسم الورشة *';

  @override
  String get enterFullWorkshopName => 'أدخل اسم الورشة الكامل';

  @override
  String get yearsOfExperience => 'سنوات الخبرة';

  @override
  String get governorateRequired => 'المحافظة *';

  @override
  String get selectGovernorate => 'اختر المحافظة';

  @override
  String get servicesDescriptionRequired => 'وصف مختصر للخدمات *';

  @override
  String get servicesDescriptionHint =>
      'اكتب وصفاً موجزاً للخدمات التي تقدمها الورشة...';

  @override
  String get workshopImages => 'صور الورشة';

  @override
  String get createWorkshopBtn => 'إنشاء الورشة';

  @override
  String get changeCover => 'تغيير الغلاف';

  @override
  String get tapToAddCover => 'اضغط لإضافة صورة الغلاف';

  @override
  String get myWorkshopOnShams => 'ورشتي على شمس';

  @override
  String get editWorkshopProfile => 'تعديل ملف الورشة';

  @override
  String get followers => 'المتابعون';

  @override
  String get postsCountLabel => 'المنشورات';

  @override
  String get publishedWorkLog => 'سجل الأعمال المنشور';

  @override
  String get noPublishedWorkYet =>
      'لا توجد أعمال منشورة حالياً.\nاضغط \"نشر عمل جديد\" للبدء!';

  @override
  String get publishNewWork => 'نشر عمل جديد';

  @override
  String get deletePostTitle => 'حذف المنشور';

  @override
  String get deletePostConfirm =>
      'هل أنت متأكد من حذف هذا المنشور؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get postDeletedSuccess => 'تم حذف المنشور بنجاح';

  @override
  String get deletePostFailed => 'تعذر حذف المنشور';

  @override
  String get uploadCoverFailed => 'تعذر رفع صورة الغلاف';

  @override
  String get uploadLogoFailed => 'تعذر رفع شعار الورشة';

  @override
  String get uploadImageFailed => 'تعذر رفع الصورة';

  @override
  String get deleteImageFailed => 'تعذر حذف الصورة';

  @override
  String get cameraUnavailable => 'الكاميرا غير متاحة على هذا الجهاز.';

  @override
  String get workshopNameLabel => 'اسم الورشة';

  @override
  String get governorateLabel => 'المحافظة';

  @override
  String get workshopInfoSaved => 'تم حفظ معلومات الورشة بنجاح';

  @override
  String get saveEditsFailed => 'تعذر حفظ التعديلات';

  @override
  String get workshopUnavailable => 'الورشة المطلوبة غير متوفرة حالياً.';

  @override
  String get requestMaintenanceNow => 'طلب خدمة صيانة الآن';

  @override
  String get searchInWorkshopHint => 'ابحث في الورشة...';

  @override
  String reviewsCountLabel(int count) {
    return '($count تقييم)';
  }

  @override
  String get contactSoon => 'ميزة التواصل متوفرة قريباً';

  @override
  String get workLogTitle => 'سجل الأعمال';

  @override
  String get fullWorkLogSoon => 'فتح سجل الأعمال بالكامل (قريباً)...';

  @override
  String get noWorkLogYet => 'لا توجد أعمال في هذا السجل حالياً.';

  @override
  String get reviewsAndOpinions => 'التقييمات والآراء';

  @override
  String get addYourReview => 'أضف تقييمك';

  @override
  String get editMyReview => 'تعديل تقييمي';

  @override
  String get failedToLoadReviews => 'تعذر تحميل التقييمات';

  @override
  String get noReviewsYet => 'لا توجد تقييمات لهذه الورشة حتى الآن';

  @override
  String get beFirstToReview => 'كن أول من يشارك تجربته مع هذه الورشة';

  @override
  String get editReview => 'تعديل التقييم';

  @override
  String get deleteReviewTitle => 'حذف التقييم';

  @override
  String get deleteReviewConfirm =>
      'هل أنت متأكد من رغبتك في حذف تقييمك لهذه الورشة؟';

  @override
  String get reviewDeletedSuccess => 'تم حذف التقييم';

  @override
  String get reviewDeleteFailed => 'تعذر حذف التقييم';

  @override
  String get reviewUpdatedSuccess => 'تم تحديث تقييمك بنجاح';

  @override
  String get reviewPublishedSuccess => 'تم نشر تقييمك بنجاح';

  @override
  String get editYourReviewTitle => 'تعديل تقييمك';

  @override
  String get addWorkshopReviewTitle => 'أضف تقييمك للورشة';

  @override
  String ratingOutOfFive(int rating) {
    return '$rating من 5';
  }

  @override
  String get ratingPoor => 'ضعيف';

  @override
  String get ratingFair => 'مقبول';

  @override
  String get ratingGood => 'جيد';

  @override
  String get ratingVeryGood => 'جيد جداً';

  @override
  String get ratingExcellent => 'ممتاز';

  @override
  String get reviewCommentHint => 'اكتب تعليقك عن الخدمة وجودة التنفيذ';

  @override
  String get pleaseWriteReviewComment => 'يرجى كتابة تعليق عن تجربتك مع الورشة';

  @override
  String get publishReview => 'نشر التقييم';

  @override
  String requestMaintenanceFrom(String name) {
    return 'طلب خدمة صيانة من $name';
  }

  @override
  String get selectServiceAndDetails => 'يرجى تحديد نوع الخدمة وتفاصيل المشكلة';

  @override
  String get sendingMaintenanceRequest => 'جاري إرسال الطلب وإنشاء المحادثة...';

  @override
  String get maintenanceRequestFailed =>
      'فشل في إرسال الطلب، يرجى المحاولة لاحقاً';

  @override
  String get requiredServiceType => 'نوع الخدمة المطلوبة';

  @override
  String get inverterType => 'نوع المحول (الإنفرتر)';

  @override
  String get batteryType => 'نوع البطاريات';

  @override
  String get systemSizeHint => 'حجم المنظومة (بالوات) - اختياري';

  @override
  String get problemDetailsHint =>
      'تفاصيل المشكلة (مثال: الشحن ضعيف وقت الظهيرة...)';

  @override
  String get sendRequest => 'إرسال الطلب';

  @override
  String get cityCapital => 'أمانة العاصمة';

  @override
  String get citySanaa => 'صنعاء';

  @override
  String get cityAden => 'عدن';

  @override
  String get cityTaiz => 'تعز';

  @override
  String get cityHudaydah => 'الحديدة';

  @override
  String get cityIbb => 'إب';

  @override
  String get cityHadramaut => 'حضرموت';

  @override
  String get cityDhamar => 'ذمار';

  @override
  String get cityAmran => 'عمران';

  @override
  String get cityDhale => 'الضالع';

  @override
  String get cityLahij => 'لحج';

  @override
  String get cityAbyan => 'أبين';

  @override
  String get cityMahrah => 'المهرة';

  @override
  String get cityShabwah => 'شبوة';

  @override
  String get cityBayda => 'البيضاء';

  @override
  String get cityMarib => 'مأرب';

  @override
  String get cityJawf => 'الجوف';

  @override
  String get citySaada => 'صعدة';

  @override
  String get cityMahwit => 'المحويت';

  @override
  String get cityHajjah => 'حجة';

  @override
  String get cityRaymah => 'ريمة';

  @override
  String get citySocotra => 'سقطرى';

  @override
  String get serviceInstallNewSystem => 'تركيب منظومة جديدة';

  @override
  String get serviceSolarPanelMaintenance => 'صيانة ألواح شمسية';

  @override
  String get serviceInverterMaintenance => 'صيانة عاكس (Inverter)';

  @override
  String get serviceBatteryMaintenance => 'صيانة بطاريات';

  @override
  String get serviceSolarWaterPumps => 'مضخات مياه شمسية';

  @override
  String get serviceFullInspection => 'فحص شامل للمنظومة';

  @override
  String get serviceSpareParts => 'توريد قطع غيار';

  @override
  String get batteryLithium => 'ليثيوم (LiFePO4)';

  @override
  String get batteryGel => 'جل (Gel)';

  @override
  String get batteryAgm => 'حمض رصاص (AGM)';

  @override
  String get errNoInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get errUnexpected => 'حدث خطأ غير متوقع';

  @override
  String get errSignInFailed => 'فشل تسجيل الدخول';

  @override
  String get errInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get errConfirmEmail => 'يرجى تأكيد بريدك الإلكتروني أولاً';

  @override
  String get errCreateAccountFailed => 'فشل إنشاء الحساب';

  @override
  String get errEmailAlreadyRegistered =>
      'هذا البريد الإلكتروني مسجل مسبقاً، حاول تسجيل الدخول من الشاشة السابقة';

  @override
  String get errNoSignedInUser => 'لا يوجد مستخدم مسجل دخول';

  @override
  String get errUserNotSignedIn => 'المستخدم غير مسجل الدخول';

  @override
  String get errInvalidWorkshopId => 'معرّف الورشة غير صالح';

  @override
  String get errInvalidReviewId => 'معرّف التقييم غير صالح';

  @override
  String get errSelectRatingRange => 'يرجى اختيار تقييم من 1 إلى 5 نجوم';

  @override
  String get errNoChangesToSave => 'لا توجد تعديلات لحفظها';

  @override
  String errImageUploadFailedWithReason(String reason) {
    return 'فشل رفع الصورة: $reason';
  }

  @override
  String errPhotoUploadErrorWithReason(String reason) {
    return 'حدث خطأ أثناء رفع الصورة: $reason';
  }

  @override
  String errProfileUpdateErrorWithReason(String reason) {
    return 'حدث خطأ أثناء تحديث بيانات الملف: $reason';
  }
}
