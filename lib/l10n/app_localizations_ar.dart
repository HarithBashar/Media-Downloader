// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get navDownload => 'تنزيل';

  @override
  String get navPlaylist => 'قائمة التشغيل';

  @override
  String get navQueue => 'قائمة الانتظار';

  @override
  String get navHistory => 'السجل';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get homeTitle => 'تنزيل';

  @override
  String get addDownload => 'إضافة تنزيل';

  @override
  String get addDownloadSubtitle =>
      'الصق رابطًا، أو اسحبه وأفلته، أو دعنا نكتشفه من الحافظة';

  @override
  String get invalidUrl => 'الرجاء إدخال رابط صالح';

  @override
  String get selectDownloadLocation => 'اختر موقع التنزيل';

  @override
  String get downloadAddedToQueue => 'تمت إضافة التنزيل إلى قائمة الانتظار';

  @override
  String get dropUrlHere => 'أفلت الرابط هنا…';

  @override
  String get pasteUrlHint =>
      'الصق الرابط هنا (يوتيوب، فيميو، تيك توك، و1000+ موقع آخر)';

  @override
  String get clear => 'مسح';

  @override
  String get pasteFromClipboard => 'لصق من الحافظة';

  @override
  String get type => 'النوع';

  @override
  String get quality => 'الجودة';

  @override
  String get saveTo => 'حفظ في';

  @override
  String get filename => 'اسم الملف';

  @override
  String get filenameHint => 'اتركه فارغًا لاستخدام العنوان الأصلي';

  @override
  String get options => 'خيارات';

  @override
  String get embedThumbnail => 'تضمين الصورة المصغّرة';

  @override
  String get embedMetadata => 'تضمين البيانات الوصفية';

  @override
  String get subtitles => 'الترجمة';

  @override
  String get sponsorBlock => 'SponsorBlock';

  @override
  String get subtitleSettings => 'إعدادات الترجمة';

  @override
  String get language => 'اللغة';

  @override
  String get embedInVideo => 'تضمين في الفيديو';

  @override
  String get noFolderSelected => 'لم يتم اختيار مجلد';

  @override
  String get browse => 'استعراض';

  @override
  String get startDownload => 'بدء التنزيل';

  @override
  String get playlistTitle => 'تنزيل قائمة التشغيل';

  @override
  String get fetchAndDownloadPlaylist => 'جلب وتنزيل قائمة التشغيل';

  @override
  String get playlistSubtitle =>
      'الصق رابط قائمة تشغيل أو قناة لتحميل جميع الفيديوهات قبل التنزيل.';

  @override
  String get pastePlaylistUrlHint => 'الصق رابط قائمة التشغيل هنا...';

  @override
  String get fetching => 'جارٍ الجلب...';

  @override
  String get fetch => 'جلب';

  @override
  String get selectAtLeastOneVideo =>
      'الرجاء اختيار فيديو واحد على الأقل للتنزيل.';

  @override
  String get selectDownloadFolder => 'الرجاء اختيار مجلد التنزيل.';

  @override
  String get selectDownloadFolderDialog => 'اختر مجلد التنزيل';

  @override
  String addedVideosToQueue(int count) {
    return 'تمت إضافة $count فيديو إلى قائمة الانتظار.';
  }

  @override
  String get noVideosFound =>
      'لم يتم العثور على فيديوهات في قائمة التشغيل هذه.';

  @override
  String videosFound(int count) {
    return 'تم العثور على $count فيديو';
  }

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String get deselectAll => 'إلغاء تحديد الكل';

  @override
  String get format => 'الصيغة';

  @override
  String get selectFolder => 'اختر مجلدًا';

  @override
  String downloadCount(int count) {
    return 'تنزيل $count';
  }

  @override
  String get queueTitle => 'قائمة الانتظار';

  @override
  String get clearCompleted => 'مسح المكتملة';

  @override
  String get noDownloadsYet => 'لا توجد تنزيلات بعد';

  @override
  String get noDownloadsSubtitle => 'أضف رابطًا في تبويب التنزيل للبدء.';

  @override
  String get statActive => 'نشط';

  @override
  String get statQueued => 'في الانتظار';

  @override
  String get statCompleted => 'مكتمل';

  @override
  String get statFailed => 'فشل';

  @override
  String get downloadingEllipsis => 'جارٍ التنزيل…';

  @override
  String statBadge(int count, String label) {
    return '$count $label';
  }

  @override
  String get historyTitle => 'السجل';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get cancel => 'إلغاء';

  @override
  String get searchHistoryHint => 'البحث في السجل…';

  @override
  String get noResultsFound => 'لم يتم العثور على نتائج';

  @override
  String get noDownloadHistory => 'لا يوجد سجل تنزيلات';

  @override
  String get tryDifferentSearch => 'جرّب مصطلح بحث مختلفًا.';

  @override
  String get completedDownloadsAppearHere => 'ستظهر تنزيلاتك المكتملة هنا.';

  @override
  String get clearAllHistory => 'مسح كل السجل؟';

  @override
  String get actionCannotBeUndone => 'لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get openFolder => 'فتح المجلد';

  @override
  String get openFile => 'فتح الملف';

  @override
  String get deleteFromHistory => 'حذف من السجل';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String errorLoadingSettings(String error) {
    return 'خطأ في تحميل الإعدادات: $error';
  }

  @override
  String get general => 'عام';

  @override
  String get startOnStartup => 'التشغيل عند بدء تشغيل النظام';

  @override
  String get startOnStartupSubtitle =>
      'تشغيل Media Downloader عند تسجيل الدخول';

  @override
  String get minimizeToTray => 'التصغير إلى شريط النظام';

  @override
  String get minimizeToTraySubtitle =>
      'إبقاء التطبيق يعمل في الخلفية عند إغلاق النافذة';

  @override
  String get downloads => 'التنزيلات';

  @override
  String get defaultDownloadLocation => 'موقع التنزيل الافتراضي';

  @override
  String get systemDownloadsFolder => 'مجلد التنزيلات في النظام';

  @override
  String get selectDefaultDownloadLocation => 'اختر موقع التنزيل الافتراضي';

  @override
  String get concurrentDownloads => 'التنزيلات المتزامنة';

  @override
  String concurrentDownloadsSubtitle(int count) {
    return '$count تنزيلات متزامنة';
  }

  @override
  String get retryCountLabel => 'عدد المحاولات';

  @override
  String retryCountSubtitle(int count) {
    return '$count محاولات عند الفشل';
  }

  @override
  String get openFileAfterDownload => 'فتح الملف بعد التنزيل';

  @override
  String get openFileAfterDownloadSubtitle => 'فتح الملفات المكتملة تلقائيًا';

  @override
  String get openFolderAfterDownload => 'فتح المجلد بعد التنزيل';

  @override
  String get openFolderAfterDownloadSubtitle => 'إظهار الملف المكتمل في مجلده';

  @override
  String get autoUpdateYtDlp => 'تحديث yt-dlp تلقائيًا';

  @override
  String get autoUpdateYtDlpSubtitle => 'تنزيل أحدث إصدار عند بدء التشغيل';

  @override
  String get embedMetadataByDefault => 'تضمين البيانات الوصفية افتراضيًا';

  @override
  String get embedMetadataByDefaultSubtitle =>
      'إضافة العنوان والفنان وعلامات أخرى إلى الملفات';

  @override
  String get useDownloadArchive => 'استخدام أرشيف التنزيل';

  @override
  String get useDownloadArchiveSubtitle =>
      'تخطّي الفيديوهات التي تم تنزيلها مسبقًا في قوائم التشغيل';

  @override
  String get customYtDlpArgs => 'وسائط yt-dlp مخصصة';

  @override
  String get customYtDlpArgsSubtitle => 'وسائط إضافية تُضاف إلى كل عملية تنزيل';

  @override
  String get customYtDlpArgsHint => 'مثال: --no-playlist --geo-bypass';

  @override
  String get proxyUrl => 'رابط الوكيل (Proxy)';

  @override
  String get proxyUrlSubtitle => 'وكيل HTTP/HTTPS/SOCKS5 للتنزيلات';

  @override
  String get advanced => 'متقدّم';

  @override
  String get debugLogging => 'تسجيل التصحيح';

  @override
  String get debugLoggingSubtitle =>
      'كتابة سجلات مفصّلة على القرص لاستكشاف الأخطاء';

  @override
  String get resetAllSettingsQuestion => 'إعادة تعيين كل الإعدادات؟';

  @override
  String get resetAllSettingsConfirm =>
      'سيؤدي هذا إلى استعادة جميع الإعدادات إلى قيمها الافتراضية.';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get theme => 'المظهر';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'النظام';

  @override
  String get speedLimit => 'حد السرعة';

  @override
  String get unlimited => 'غير محدود';

  @override
  String speedLimitValue(int count) {
    return '$count ك.ب/ث';
  }

  @override
  String get speedLimitHint => '0 = غير محدود';

  @override
  String get dangerZone => 'منطقة الخطر';

  @override
  String get resetAllSettingsToDefaults =>
      'إعادة تعيين كل الإعدادات إلى الافتراضي';

  @override
  String get leadDeveloper => 'المطوّر والمصمّم الرئيسي';

  @override
  String get settingUpEngine => 'جارٍ إعداد محرّك التنزيل…';

  @override
  String get setupFailed => 'فشل الإعداد.';

  @override
  String get ready => 'جاهز!';

  @override
  String get retrySetup => 'إعادة محاولة الإعداد';

  @override
  String get splashTagline => 'وسائطك في كل مكان';

  @override
  String get statusWaiting => 'في الانتظار';

  @override
  String get statusPreparing => 'جارٍ التحضير';

  @override
  String get statusDownloading => 'جارٍ التنزيل';

  @override
  String get statusConverting => 'جارٍ التحويل';

  @override
  String get statusMerging => 'جارٍ الدمج';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusFailed => 'فشل';

  @override
  String get statusPaused => 'متوقّف مؤقتًا';

  @override
  String get statusCancelled => 'مُلغى';

  @override
  String get typeVideo => 'فيديو';

  @override
  String get typeAudio => 'صوت';

  @override
  String get qualityBest => 'أفضل جودة متاحة';

  @override
  String get qualityHigh => 'عالية (1080p)';

  @override
  String get qualityMedium => 'متوسطة (720p)';

  @override
  String get qualityLow => 'منخفضة (480p)';

  @override
  String get qualityCustom => 'صيغة مخصصة';

  @override
  String get audioBest => 'أفضل جودة متاحة';

  @override
  String get audioMp3_320 => 'MP3 320kbps';

  @override
  String get audioMp3_256 => 'MP3 256kbps';

  @override
  String get audioMp3_192 => 'MP3 192kbps';

  @override
  String get audioMp3_128 => 'MP3 128kbps';

  @override
  String get audioOriginal => 'الصوت الأصلي';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get resume => 'استئناف';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get remove => 'إزالة';

  @override
  String get play => 'تشغيل';
}
