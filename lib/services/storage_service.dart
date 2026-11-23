import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bucket_item.dart';
import '../models/moment.dart';
import '../models/important_date.dart';

class StorageService extends ChangeNotifier {
  static const String _keyAnniversary = 'app_anniversary_date';
  static const String _keyNickMiftah = 'app_nick_miftah';
  static const String _keyNickCinta = 'app_nick_cinta';
  static const String _keyCurrentUser = 'app_current_user_email';
  static const String _keyIsLoggedIn = 'app_is_logged_in';
  static const String _keyBucketItems = 'app_bucket_items_json';
  static const String _keyMoments = 'app_moments_json';
  static const String _keyImportantDates = 'app_important_dates_json';

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  DateTime _anniversaryDate = DateTime(2025, 1, 10);
  String _nickMiftah = 'Miftah (Mas Sayang)';
  String _nickCinta = 'Cinta (Bidadari)';
  String _currentUserEmail = 'miftah@berdua.internal';
  bool _isLoggedIn = true;

  List<BucketItem> _bucketItems = [];
  List<Moment> _moments = [];
  List<ImportantDate> _importantDates = [];

  // Getters
  bool get isInitialized => _isInitialized;
  DateTime get anniversaryDate => _anniversaryDate;
  String get nickMiftah => _nickMiftah;
  String get nickCinta => _nickCinta;
  String get currentUserEmail => _currentUserEmail;
  bool get isLoggedIn => _isLoggedIn;
  List<BucketItem> get bucketItems => List.unmodifiable(_bucketItems);
  List<Moment> get moments => List.unmodifiable(_moments);
  List<ImportantDate> get importantDates => List.unmodifiable(_importantDates);

  String get currentUserName =>
      _currentUserEmail.contains('miftah') ? _nickMiftah : _nickCinta;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final dateStr = _prefs.getString(_keyAnniversary);
    if (dateStr != null) {
      _anniversaryDate = DateTime.tryParse(dateStr) ?? DateTime(2025, 1, 10);
    } else {
      _anniversaryDate = DateTime(2025, 1, 10);
    }

    _nickMiftah = _prefs.getString(_keyNickMiftah) ?? 'Miftah (Mas Sayang)';
    _nickCinta = _prefs.getString(_keyNickCinta) ?? 'Cinta (Bidadari)';
    _currentUserEmail = _prefs.getString(_keyCurrentUser) ?? 'miftah@berdua.internal';
    _isLoggedIn = _prefs.getBool(_keyIsLoggedIn) ?? true;

    _loadBucketItems();
    _loadMoments();
    _loadImportantDates();

    _isInitialized = true;
    notifyListeners();
  }

  // --- Auth & Session ---
  Future<void> login(String email, String password) async {
    _currentUserEmail = email;
    _isLoggedIn = true;
    await _prefs.setString(_keyCurrentUser, email);
    await _prefs.setBool(_keyIsLoggedIn, true);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    await _prefs.setBool(_keyIsLoggedIn, false);
    notifyListeners();
  }

  // --- Settings ---
  Future<void> updateAnniversaryDate(DateTime newDate) async {
    _anniversaryDate = newDate;
    await _prefs.setString(_keyAnniversary, newDate.toIso8601String());
    notifyListeners();
  }

  Future<void> updateNicknames(String miftah, String cinta) async {
    _nickMiftah = miftah;
    _nickCinta = cinta;
    await _prefs.setString(_keyNickMiftah, miftah);
    await _prefs.setString(_keyNickCinta, cinta);
    notifyListeners();
  }

  // --- Bucket Items ---
  Future<void> addBucketItem(BucketItem item) async {
    _bucketItems.insert(0, item);
    await _saveBucketItems();
    notifyListeners();
  }

  Future<void> updateBucketItem(BucketItem item) async {
    final index = _bucketItems.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _bucketItems[index] = item;
      await _saveBucketItems();
      notifyListeners();
    }
  }

  Future<void> toggleBucketItemStatus(String id) async {
    final index = _bucketItems.indexWhere((e) => e.id == id);
    if (index != -1) {
      final item = _bucketItems[index];
      item.isCompleted = !item.isCompleted;
      if (item.isCompleted) {
        item.completedAt = DateTime.now();
        // Automatically add to Moments timeline if not yet added
        final exists = _moments.any((m) => m.bucketItemId == item.id);
        if (!exists) {
          final newMoment = Moment(
            id: 'moment_${DateTime.now().millisecondsSinceEpoch}',
            title: '${item.title} ✨',
            date: item.completedAt!,
            location: item.categoryLabel,
            story: item.memoryNote.isNotEmpty
                ? item.memoryNote
                : 'Impian bersama berhasil terwujud dan terlaksana dengan penuh cinta!',
            photos: item.photos,
            createdBy: currentUserName,
            isBucketListCompleted: true,
            bucketItemId: item.id,
          );
          _moments.insert(0, newMoment);
          await _saveMoments();
        }
      } else {
        item.completedAt = null;
      }
      await _saveBucketItems();
      notifyListeners();
    }
  }

  Future<void> deleteBucketItem(String id) async {
    _bucketItems.removeWhere((e) => e.id == id);
    await _saveBucketItems();
    notifyListeners();
  }

  // --- Moments ---
  Future<void> addMoment(Moment moment) async {
    _moments.insert(0, moment);
    await _saveMoments();
    notifyListeners();
  }

  Future<void> deleteMoment(String id) async {
    _moments.removeWhere((e) => e.id == id);
    await _saveMoments();
    notifyListeners();
  }

  // --- Important Dates ---
  Future<void> addImportantDate(ImportantDate date) async {
    _importantDates.add(date);
    _sortImportantDates();
    await _saveImportantDates();
    notifyListeners();
  }

  Future<void> deleteImportantDate(String id) async {
    _importantDates.removeWhere((e) => e.id == id);
    await _saveImportantDates();
    notifyListeners();
  }

  void _sortImportantDates() {
    _importantDates.sort((a, b) => a.daysRemaining().compareTo(b.daysRemaining()));
  }

  // --- Persistence helpers ---
  void _loadBucketItems() {
    final raw = _prefs.getString(_keyBucketItems);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _bucketItems = list.map((e) => BucketItem.fromJson(e as Map<String, dynamic>)).toList();
        return;
      } catch (_) {}
    }
    // Default seed items matching Stitch design
    _bucketItems = [
      BucketItem(
        id: 'b1',
        title: 'Liburan ke Bromo & Liat Sunrise Bareng',
        category: 'tempat',
        notes: 'Sewa jeep bareng, bawa jaket tebal dan kamera analog untuk foto sunrise berdua di Penanjakan.',
        targetDate: DateTime(2026, 11, 20),
        createdBy: 'Miftah',
      ),
      BucketItem(
        id: 'b2',
        title: 'Bikin Pasta Truffle Homemade Berdua',
        category: 'makanan',
        notes: 'Beli truffle oil dan fresh pasta dari pasar kuliner, masak sambil dengar jazz santai.',
        targetDate: DateTime(2026, 11, 8),
        createdBy: 'Cinta',
      ),
      BucketItem(
        id: 'b3',
        title: 'Marathon Film Ghibli di Akhir Pekan',
        category: 'film',
        notes: 'Nonton Spirited Away, Howl\'s Moving Castle, bawa selimut tebal dan popcorn karamel.',
        targetDate: DateTime(2026, 11, 15),
        createdBy: 'Miftah',
      ),
      BucketItem(
        id: 'b4',
        title: 'Piknik Sore & Sunset di Pantai Melasti',
        category: 'tempat',
        notes: 'Bawa tikar piknik estetik, roti bakar keju, dan speaker bluetooth mini.',
        isCompleted: true,
        completedAt: DateTime(2026, 10, 12),
        memoryNote:
            'Sunset terindah yang pernah kita lihat bersama! Pasangan bawa roti bakar keju favorit dan playlist lagu jazz kita. Angin sorenya syahdu banget.',
        createdBy: 'Miftah',
        isFavorite: true,
      ),
      BucketItem(
        id: 'b5',
        title: 'Makan Malam Romantis di Rooftop Jakarta',
        category: 'makanan',
        notes: 'Merayakan anniversary dengan pemandangan lampu malam kota Jakarta.',
        isCompleted: true,
        completedAt: DateTime(2026, 9, 20),
        memoryNote: 'Lampu-lampu kota malam itu kalah indah dengan senyum manis kamu.',
        createdBy: 'Cinta',
        isFavorite: true,
      ),
    ];
    _saveBucketItems();
  }

  void _loadMoments() {
    final raw = _prefs.getString(_keyMoments);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _moments = list.map((e) => Moment.fromJson(e as Map<String, dynamic>)).toList();
        return;
      } catch (_) {}
    }
    // Default seed moments matching Stitch design
    _moments = [
      Moment(
        id: 'm1',
        title: 'Piknik Sore di Pantai Melasti',
        date: DateTime(2026, 10, 12),
        location: 'Pantai Melasti, Ungasan Bali',
        story:
            'Menikmati langit jingga keemasan bersama semilir angin laut. Tertawa lepas sambil menyantap camilan favorit.',
        createdBy: 'Miftah',
        isBucketListCompleted: true,
      ),
      Moment(
        id: 'm2',
        title: 'Dinner Ultah Pertama Bareng',
        date: DateTime(2026, 2, 14),
        location: 'Sky Lounge Jakarta',
        story:
            'Momen manis penuh tawa dengan lilin kecil di atas kue cokelat kesukaan dan surat cinta tulisan tangan.',
        createdBy: 'Cinta',
      ),
      Moment(
        id: 'm3',
        title: 'Hari Pertama Jadian',
        date: DateTime(2025, 1, 10),
        location: 'Taman Suropati, Menteng',
        story:
            'Awal mula cerita indah dua hati berpadu. Hari di mana kita berjanji untuk saling menjaga dan bertumbuh bersama.',
        createdBy: 'Miftah',
      ),
    ];
    _saveMoments();
  }

  void _loadImportantDates() {
    final raw = _prefs.getString(_keyImportantDates);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _importantDates = list.map((e) => ImportantDate.fromJson(e as Map<String, dynamic>)).toList();
        _sortImportantDates();
        return;
      } catch (_) {}
    }
    // Default seed dates
    _importantDates = [
      ImportantDate(
        id: 'd1',
        title: 'Tanggal Jadian Berdua',
        date: DateTime(2025, 1, 10),
        repeatsYearly: true,
        iconEmoji: '💖',
      ),
      ImportantDate(
        id: 'd2',
        title: 'Ulang Tahun Cinta',
        date: DateTime(2026, 2, 14),
        repeatsYearly: true,
        iconEmoji: '🎂',
      ),
      ImportantDate(
        id: 'd3',
        title: 'Ulang Tahun Miftah',
        date: DateTime(2026, 5, 20),
        repeatsYearly: true,
        iconEmoji: '🎁',
      ),
      ImportantDate(
        id: 'd4',
        title: 'Liburan Akhir Tahun Bersama',
        date: DateTime(2026, 12, 25),
        repeatsYearly: false,
        iconEmoji: '✈️',
      ),
    ];
    _sortImportantDates();
    _saveImportantDates();
  }

  Future<void> _saveBucketItems() async {
    final list = _bucketItems.map((e) => e.toJson()).toList();
    await _prefs.setString(_keyBucketItems, jsonEncode(list));
  }

  Future<void> _saveMoments() async {
    final list = _moments.map((e) => e.toJson()).toList();
    await _prefs.setString(_keyMoments, jsonEncode(list));
  }

  Future<void> _saveImportantDates() async {
    final list = _importantDates.map((e) => e.toJson()).toList();
    await _prefs.setString(_keyImportantDates, jsonEncode(list));
  }

  /// Exports entire user data to a formatted JSON string
  String exportDataAsJson() {
    final data = {
      'anniversaryDate': _anniversaryDate.toIso8601String(),
      'nickMiftah': _nickMiftah,
      'nickCinta': _nickCinta,
      'currentUserEmail': _currentUserEmail,
      'bucketItems': _bucketItems.map((e) => e.toJson()).toList(),
      'moments': _moments.map((e) => e.toJson()).toList(),
      'importantDates': _importantDates.map((e) => e.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
