import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[Locale('en'), Locale('hi')];
  static const delegate = _AppStringsDelegate();

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings) ??
        const AppStrings(Locale('en'));
  }

  String t(String key) => (_values[locale.languageCode] ?? _values['en']!)[key] ??
      _values['en']![key] ??
      key;

  String items(int count) => locale.languageCode == 'hi' ? '$count आइटम' : '$count items';

  static const _values = <String, Map<String, String>>{
    'en': {
      'appName': 'DukaanAI',
      'today': 'Today',
      'entries': 'Entries',
      'ask': 'Ask / Add',
      'stock': 'Stock',
      'parties': 'Parties',
      'changeLanguage': 'हिंदी में देखें',
      'location': 'Location',
      'offline': 'Offline — draft only',
      'offlineDetail': 'Nothing will be recorded until you reconnect and confirm.',
      'demo': 'Demo data',
      'demoDetail': 'Explore safely. These are sample business records.',
      'goodMorning': 'Good morning',
      'goodAfternoon': 'Good afternoon',
      'goodEvening': 'Good evening',
      'assistantPrompt': 'Tell DukaanAI what happened',
      'assistantExample': '“Ramesh bought 3 shirts for ₹2,400, ₹900 pending.”',
      'salesToday': 'Sales today',
      'expenses': 'Expenses',
      'toReceive': 'You will receive',
      'toPay': 'You will pay',
      'lowStock': 'Low stock',
      'needsAttention': 'Needs attention',
      'dailySummary': 'Daily AI summary',
      'asOf': 'As of',
      'draftsWaiting': 'drafts waiting for review',
      'viewAll': 'View all',
      'manualSale': 'New sale',
      'all': 'All',
      'sales': 'Sales',
      'purchases': 'Purchases',
      'payments': 'Payments',
      'noEntries': 'No entries here yet',
      'noEntriesDetail': 'Record a sale or tell the assistant what happened.',
      'products': 'Products',
      'retail': 'Retail',
      'wholesale': 'Wholesale',
      'inStock': 'in stock',
      'belowMinimum': 'Below minimum',
      'customers': 'Customers',
      'suppliers': 'Suppliers',
      'shareReminder': 'Share reminder',
      'recordPayment': 'Record external payment',
      'noMoneyMovement': 'DukaanAI records payment information. It does not collect or transfer money.',
      'type': 'Type',
      'speak': 'Speak',
      'scanBill': 'Scan bill',
      'upload': 'Upload',
      'tryExample': 'Try example',
      'listening': 'Listening…',
      'stopListening': 'Stop listening',
      'parsing': 'Understanding your entry…',
      'reviewTitle': 'Review before recording',
      'reviewDetail': 'DukaanAI has not changed your books yet.',
      'confirm': 'Confirm and record',
      'editRequest': 'Edit request',
      'saved': 'Entry recorded',
      'savedDetail': 'The server confirmed this entry.',
      'draftSaved': 'Draft saved on this phone',
      'draftSavedDetail': 'Reconnect, review, and confirm it. It will never post automatically.',
      'couldNotUnderstand': 'More details are needed',
      'retry': 'Try again',
      'product': 'Product',
      'customerOptional': 'Customer (optional)',
      'quantity': 'Quantity',
      'unitPrice': 'Unit price',
      'paidNow': 'Paid externally',
      'paymentMethod': 'Payment method',
      'reviewSale': 'Review sale',
      'recordSale': 'Record sale',
      'saveDraft': 'Save offline draft',
      'total': 'Total',
      'pending': 'Pending',
      'taxServer': 'GST is calculated by the server from product and party settings.',
      'required': 'Required',
      'invalidAmount': 'Enter a valid amount',
      'selectProduct': 'Select a product',
      'customerDueRequired': 'Choose a customer when an amount is pending',
      'stockEffect': 'Stock effect',
      'saleNotRecorded': 'This sale has not been recorded yet.',
      'cancel': 'Cancel',
      'backToEntries': 'Back to entries',
      'source': 'Source',
      'voiceUnavailable': 'Voice input is unavailable. You can type instead.',
      'captureFailed': 'Could not open that file. Please try again.',
      'permissionDenied': 'Permission was not granted.',
      'loading': 'Loading business data…',
      'loadFailed': 'Business data could not be loaded.',
    },
    'hi': {
      'appName': 'दुकानAI',
      'today': 'आज',
      'entries': 'एंट्री',
      'ask': 'पूछें / जोड़ें',
      'stock': 'स्टॉक',
      'parties': 'पार्टियाँ',
      'changeLanguage': 'View in English',
      'location': 'दुकान',
      'offline': 'ऑफ़लाइन — केवल ड्राफ़्ट',
      'offlineDetail': 'इंटरनेट आने और आपकी पुष्टि तक कुछ दर्ज नहीं होगा।',
      'demo': 'डेमो डेटा',
      'demoDetail': 'यह सुरक्षित नमूना कारोबार डेटा है।',
      'goodMorning': 'सुप्रभात',
      'goodAfternoon': 'नमस्ते',
      'goodEvening': 'शुभ संध्या',
      'assistantPrompt': 'दुकानAI को बताइए क्या हुआ',
      'assistantExample': '“रमेश ने 3 शर्ट ₹2,400 में लीं, ₹900 बाकी।”',
      'salesToday': 'आज की बिक्री',
      'expenses': 'खर्च',
      'toReceive': 'आपको लेना है',
      'toPay': 'आपको देना है',
      'lowStock': 'कम स्टॉक',
      'needsAttention': 'ध्यान दें',
      'dailySummary': 'आज का AI सारांश',
      'asOf': 'इस समय तक',
      'draftsWaiting': 'ड्राफ़्ट जाँच के लिए बाकी',
      'viewAll': 'सभी देखें',
      'manualSale': 'नई बिक्री',
      'all': 'सभी',
      'sales': 'बिक्री',
      'purchases': 'खरीद',
      'payments': 'भुगतान',
      'noEntries': 'अभी कोई एंट्री नहीं',
      'noEntriesDetail': 'बिक्री दर्ज करें या असिस्टेंट को बताएं।',
      'products': 'सामान',
      'retail': 'रिटेल',
      'wholesale': 'थोक',
      'inStock': 'स्टॉक में',
      'belowMinimum': 'न्यूनतम से कम',
      'customers': 'ग्राहक',
      'suppliers': 'सप्लायर',
      'shareReminder': 'रिमाइंडर शेयर करें',
      'recordPayment': 'बाहर हुआ भुगतान दर्ज करें',
      'noMoneyMovement': 'दुकानAI केवल भुगतान की जानकारी दर्ज करता है। यह पैसे लेता या भेजता नहीं है।',
      'type': 'टाइप करें',
      'speak': 'बोलें',
      'scanBill': 'बिल स्कैन',
      'upload': 'अपलोड',
      'tryExample': 'उदाहरण आज़माएँ',
      'listening': 'सुन रहा है…',
      'stopListening': 'सुनना बंद करें',
      'parsing': 'आपकी एंट्री समझी जा रही है…',
      'reviewTitle': 'दर्ज करने से पहले जाँचें',
      'reviewDetail': 'दुकानAI ने अभी आपके हिसाब में बदलाव नहीं किया है।',
      'confirm': 'पुष्टि करके दर्ज करें',
      'editRequest': 'बात बदलें',
      'saved': 'एंट्री दर्ज हो गई',
      'savedDetail': 'सर्वर ने इस एंट्री की पुष्टि की है।',
      'draftSaved': 'ड्राफ़्ट इस फ़ोन पर सेव हुआ',
      'draftSavedDetail': 'इंटरनेट आने पर जाँच कर पुष्टि करें। यह अपने-आप दर्ज नहीं होगा।',
      'couldNotUnderstand': 'कुछ और जानकारी चाहिए',
      'retry': 'फिर कोशिश करें',
      'product': 'सामान',
      'customerOptional': 'ग्राहक (ज़रूरी नहीं)',
      'quantity': 'मात्रा',
      'unitPrice': 'एक का भाव',
      'paidNow': 'बाहर मिला भुगतान',
      'paymentMethod': 'भुगतान का तरीका',
      'reviewSale': 'बिक्री जाँचें',
      'recordSale': 'बिक्री दर्ज करें',
      'saveDraft': 'ऑफ़लाइन ड्राफ़्ट सेव करें',
      'total': 'कुल',
      'pending': 'बाकी',
      'taxServer': 'GST की गणना सर्वर पर सामान और पार्टी की सेटिंग से होती है।',
      'required': 'ज़रूरी',
      'invalidAmount': 'सही रकम डालें',
      'selectProduct': 'सामान चुनें',
      'customerDueRequired': 'बाकी रकम के लिए ग्राहक चुनें',
      'stockEffect': 'स्टॉक में बदलाव',
      'saleNotRecorded': 'यह बिक्री अभी दर्ज नहीं हुई है।',
      'cancel': 'रद्द करें',
      'backToEntries': 'एंट्री पर लौटें',
      'source': 'स्रोत',
      'voiceUnavailable': 'आवाज़ उपलब्ध नहीं है। आप टाइप कर सकते हैं।',
      'captureFailed': 'फ़ाइल नहीं खुली। दोबारा कोशिश करें।',
      'permissionDenied': 'अनुमति नहीं मिली।',
      'loading': 'कारोबार का डेटा लोड हो रहा है…',
      'loadFailed': 'कारोबार का डेटा लोड नहीं हो सका।',
    },
  };
}

extension AppStringsContext on BuildContext {
  AppStrings get strings => AppStrings.of(this);
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => const {'en', 'hi'}.contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) => SynchronousFuture(AppStrings(locale));

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
