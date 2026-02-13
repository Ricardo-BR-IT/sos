import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Resgate SOS Mobile',
      'initializingSecurity': 'Initializing Security...',
      'secureIdentityLoaded': 'Secure Identity Loaded',
      'activeNode': 'Active Node:',
      'error': 'Error:',
    },
    'pt': {
      'appTitle': 'Resgate SOS Mobile',
      'initializingSecurity': 'Inicializando Segurança...',
      'secureIdentityLoaded': 'Identidade Segura Carregada',
      'activeNode': 'Nó Ativo:',
      'error': 'Erro:',
    },
    'es': {
      'appTitle': 'Resgate SOS Móvil',
      'initializingSecurity': 'Inicializando seguridad...',
      'secureIdentityLoaded': 'Identidad segura cargada',
      'activeNode': 'Nodo activo:',
      'error': 'Error:',
    },
    'fr': {
      'appTitle': 'Resgate SOS Mobile',
      'initializingSecurity': 'Initialisation de la sécurité...',
      'secureIdentityLoaded': 'Identité sécurisée chargée',
      'activeNode': 'Nœud actif :',
      'error': 'Erreur :',
    },
    'de': {
      'appTitle': 'Resgate SOS Mobil',
      'initializingSecurity': 'Sicherheit wird initialisiert...',
      'secureIdentityLoaded': 'Sichere Identität geladen',
      'activeNode': 'Aktiver Knoten:',
      'error': 'Fehler:',
    },
    'zh': {
      'appTitle': 'Resgate SOS 移动版',
      'initializingSecurity': '正在初始化安全性...',
      'secureIdentityLoaded': '安全身份已加载',
      'activeNode': '活动节点：',
      'error': '错误：',
    },
    'hi': {
      'appTitle': 'Resgate SOS मोबाइल',
      'initializingSecurity': 'सुरक्षा प्रारंभ हो रही है...',
      'secureIdentityLoaded': 'सुरक्षित पहचान लोड की गई',
      'activeNode': 'सक्रिय नोड:',
      'error': 'त्रुटि:',
    },
    'sw': {
      'appTitle': 'Resgate SOS Simu',
      'initializingSecurity': 'Inaanzisha Usalama...',
      'secureIdentityLoaded': 'Utambulisho Salama Umepakiwa',
      'activeNode': 'Nodi Inayotumika:',
      'error': 'Hitilafu:',
    },
    'ru': {
      'appTitle': 'Resgate SOS Мобильный',
      'initializingSecurity': 'Инициализация безопасности...',
      'secureIdentityLoaded': 'Безопасная личность загружена',
      'activeNode': 'Активный узел:',
      'error': 'Ошибка:',
    },
    'ar': {
      'appTitle': 'Resgate SOS الجوال',
      'initializingSecurity': 'جاري تهيئة الأمان...',
      'secureIdentityLoaded': 'تم تحميل الهوية الآمنة',
      'activeNode': 'العقدة النشطة:',
      'error': 'خطأ:',
    },
    'bn': {
      'appTitle': 'Resgate SOS মোবাইল',
      'initializingSecurity': 'নিরাপত্তা আরম্ভ হচ্ছে...',
      'secureIdentityLoaded': 'নিরাপদ পরিচয় লোড হয়েছে',
      'activeNode': 'সক্রিয় নোড:',
      'error': 'ত্রুটি:',
    },
    'id': {
      'appTitle': 'Resgate SOS Mobile',
      'initializingSecurity': 'Menginisialisasi keamanan...',
      'secureIdentityLoaded': 'Identitas aman dimuat',
      'activeNode': 'Node aktif:',
      'error': 'Kesalahan:',
    },
    'ur': {
      'appTitle': 'Resgate SOS موبائل',
      'initializingSecurity': 'سیکورٹی شروع ہو رہی ہے...',
      'secureIdentityLoaded': 'محفوظ شناخت لوڈ ہوگئی',
      'activeNode': 'فعال نوڈ:',
      'error': 'خرابی:',
    },
    'ja': {
      'appTitle': 'Resgate SOS モバイル',
      'initializingSecurity': 'セキュリティを初期化中...',
      'secureIdentityLoaded': '安全なIDが読み込まれました',
      'activeNode': 'アクティブノード:',
      'error': 'エラー:',
    },
    'mr': {
      'appTitle': 'Resgate SOS मोबाइल',
      'initializingSecurity': 'सुरक्षा सुरू होत आहे...',
      'secureIdentityLoaded': 'सुरक्षित ओळख लोड झाली',
      'activeNode': 'सक्रिय नोड:',
      'error': 'त्रुटी:',
    },
    'vi': {
      'appTitle': 'Resgate SOS Di dong',
      'initializingSecurity': 'Dang khoi tao bao mat...',
      'secureIdentityLoaded': 'Da tai danh tinh an toan',
      'activeNode': 'Nut hoat dong:',
      'error': 'Loi:',
    },
    'te': {
      'appTitle': 'Resgate SOS మొబైల్',
      'initializingSecurity': 'భద్రత ప్రారంభమవుతోంది...',
      'secureIdentityLoaded': 'సురక్షిత గుర్తింపు లోడ్ అయింది',
      'activeNode': 'సక్రియ నోడ్:',
      'error': 'పొరపాటు:',
    },
    'ha': {
      'appTitle': 'Resgate SOS Wayar Salula',
      'initializingSecurity': 'Ana fara tsaro...',
      'secureIdentityLoaded': 'An loda sahihin shaida',
      'activeNode': 'Nodi mai aiki:',
      'error': 'Kuskure:',
    },
    'tr': {
      'appTitle': 'Resgate SOS Mobil',
      'initializingSecurity': 'Guvenlik baslatiliyor...',
      'secureIdentityLoaded': 'Guvenli kimlik yuklendi',
      'activeNode': 'Etkin dugum:',
      'error': 'Hata:',
    },
    'ta': {
      'appTitle': 'Resgate SOS மொபைல்',
      'initializingSecurity': 'பாதுகாப்பை தொடங்குகிறது...',
      'secureIdentityLoaded': 'பாதுகாப்பான அடையாளம் ஏற்றப்பட்டது',
      'activeNode': 'செயலில் உள்ள நோடு:',
      'error': 'பிழை:',
    },
    'it': {
      'appTitle': 'Resgate SOS Mobile',
      'initializingSecurity': 'Inizializzazione della sicurezza...',
      'secureIdentityLoaded': 'Identita sicura caricata',
      'activeNode': 'Nodo attivo:',
      'error': 'Errore:',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get initializingSecurity =>
      _localizedValues[locale.languageCode]!['initializingSecurity']!;
  String get secureIdentityLoaded =>
      _localizedValues[locale.languageCode]!['secureIdentityLoaded']!;
  String get activeNode =>
      _localizedValues[locale.languageCode]!['activeNode']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => [
        'en',
        'pt',
        'es',
        'fr',
        'de',
        'zh',
        'hi',
        'sw',
        'ru',
        'ar',
        'bn',
        'id',
        'ur',
        'ja',
        'mr',
        'vi',
        'te',
        'ha',
        'tr',
        'ta',
        'it'
      ].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
