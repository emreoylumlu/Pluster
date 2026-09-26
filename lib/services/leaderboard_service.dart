import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../firebase_options.dart';

class LeaderboardEntry {
  final String userId;
  final String nickname;
  final int highScore;
  final String avatarId;

  LeaderboardEntry({
    required this.userId,
    required this.nickname,
    required this.highScore,
    this.avatarId = 'default_avatar',
  });

  factory LeaderboardEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LeaderboardEntry(
      userId: doc.id,
      nickname: data['nickname'] as String? ?? 'Pluster Oyuncusu',
      highScore: (data['highScore'] as num? ?? 0).toInt(),
      avatarId: data['avatarId'] as String? ?? 'default_avatar',
    );
  }
}

class LeaderboardService {
  static final LeaderboardService instance = LeaderboardService._internal();
  LeaderboardService._internal();

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  GoogleSignIn get _googleSignIn => GoogleSignIn();

  static const String _pendingScoreKey = 'pending_leaderboard_scores';

  Future<void> _ensureFirebaseInitialized() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (_) {}
  }

  /// Ensures user is signed in (anonymously if not logged in with Google)
  Future<User?> ensureAnonymousAuth() async {
    try {
      await _ensureFirebaseInitialized();
      final auth = _auth;
      if (auth == null) return null;

      if (auth.currentUser == null) {
        final credential = await auth.signInAnonymously();
        return credential.user;
      }
      return auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  /// Sign in or link current anonymous account with Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _ensureFirebaseInitialized();
      final auth = _auth;
      if (auth == null) return null;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final currentUser = auth.currentUser;
      UserCredential userCredential;
      if (currentUser != null && currentUser.isAnonymous) {
        userCredential = await currentUser.linkWithCredential(credential);
      } else {
        userCredential = await auth.signInWithCredential(credential);
      }

      if (googleUser.displayName != null && googleUser.displayName!.isNotEmpty) {
        await setNickname(googleUser.displayName!);
      }

      return userCredential;
    } catch (e) {
      return null;
    }
  }

  /// Calculates ISO-8601 week string on client side (e.g. "2026-W34")
  static String getIsoWeekId([DateTime? date]) {
    final d = date ?? DateTime.now().toUtc();
    final dayNumber = (d.weekday == 7) ? 7 : d.weekday;
    final thursday = d.add(Duration(days: 4 - dayNumber));
    final firstDayOfYear = DateTime.utc(thursday.year, 1, 1);
    final weekNo = ((thursday.difference(firstDayOfYear).inDays) / 7).floor() + 1;
    final formattedWeek = weekNo.toString().padLeft(2, '0');
    return '${thursday.year}-W$formattedWeek';
  }

  /// Submits Endless Mode Score directly to Firestore via atomic Batch Write
  Future<Map<String, dynamic>> submitScore(int score, int moveCount) async {
    final user = await ensureAnonymousAuth();
    final db = _firestore;
    if (user == null || db == null) {
      return {'success': false, 'isNewHighScore': false, 'globalRank': null};
    }

    final String sessionId = const Uuid().v4();

    try {
      final sessionRef = db.collection('game_sessions').doc(sessionId);
      final globalRef = db.collection('leaderboard_endless').doc(user.uid);
      final weekId = getIsoWeekId();
      final weeklyRef = db.collection('leaderboard_endless_weekly').doc(weekId).collection('scores').doc(user.uid);

      final sessionDoc = await sessionRef.get();
      if (sessionDoc.exists) {
        return {'success': false, 'isNewHighScore': false, 'globalRank': null};
      }

      final globalDoc = await globalRef.get();
      int currentHighScore = score;
      bool isNewHighScore = false;
      String nickname = _auth?.currentUser?.displayName ?? 'Pluster Oyuncusu';

      if (globalDoc.exists) {
        final data = globalDoc.data() ?? {};
        currentHighScore = (data['highScore'] as num? ?? 0).toInt();
        nickname = data['nickname'] as String? ?? nickname;

        if (score > currentHighScore) {
          isNewHighScore = true;
          currentHighScore = score;
        }
      } else {
        isNewHighScore = true;
      }

      final weeklyDoc = await weeklyRef.get();
      final existingWeeklyScore = weeklyDoc.exists ? (weeklyDoc.data()?['highScore'] as num? ?? 0).toInt() : 0;

      final batch = db.batch();
      batch.set(sessionRef, {
        'uid': user.uid,
        'score': score,
        'moveCount': moveCount,
        'submittedAt': FieldValue.serverTimestamp(),
      });

      if (isNewHighScore) {
        batch.set(globalRef, {
          'nickname': nickname,
          'nickname_lowercase': nickname.toLowerCase(),
          'highScore': currentHighScore,
          'achievedAt': FieldValue.serverTimestamp(),
          'avatarId': 'default_avatar',
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      if (!weeklyDoc.exists || score > existingWeeklyScore) {
        batch.set(weeklyRef, {
          'nickname': nickname,
          'nickname_lowercase': nickname.toLowerCase(),
          'highScore': score,
          'achievedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();

      // Calculate Rank locally via Count Query
      int? rank;
      try {
        final higherCountSnap = await db.collection('leaderboard_endless').where('highScore', isGreaterThan: currentHighScore).count().get();
        rank = (higherCountSnap.count ?? 0) + 1;
      } catch (_) {}

      // Retry any previously cached offline submissions
      retryPendingSubmissions();

      return {
        'success': true,
        'isNewHighScore': isNewHighScore,
        'globalRank': rank,
      };
    } catch (e) {
      await _saveScoreForRetry(score: score, moveCount: moveCount, sessionId: sessionId);
      return {'success': false, 'isNewHighScore': false, 'globalRank': null};
    }
  }

  /// Saves failed submissions to SharedPreferences for background retry
  Future<void> _saveScoreForRetry({required int score, required int moveCount, required String sessionId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = prefs.getStringList(_pendingScoreKey) ?? [];
      list.add(jsonEncode({
        'score': score,
        'moveCount': moveCount,
        'sessionId': sessionId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }));
      await prefs.setStringList(_pendingScoreKey, list);
    } catch (_) {}
  }

  /// Retries sending any cached offline score submissions
  Future<void> retryPendingSubmissions() async {
    try {
      final db = _firestore;
      final auth = _auth;
      if (db == null || auth == null) return;

      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = prefs.getStringList(_pendingScoreKey) ?? [];
      if (rawList.isEmpty) return;

      final List<String> remaining = [];

      for (String item in rawList) {
        try {
          final Map<String, dynamic> data = jsonDecode(item) as Map<String, dynamic>;
          final score = (data['score'] as num).toInt();
          final moveCount = (data['moveCount'] as num).toInt();
          final sessionId = data['sessionId'] as String;

          final user = auth.currentUser;
          if (user != null) {
            await db.collection('game_sessions').doc(sessionId).set({
              'uid': user.uid,
              'score': score,
              'moveCount': moveCount,
              'submittedAt': FieldValue.serverTimestamp(),
            });
          }
        } catch (_) {
          remaining.add(item);
        }
      }

      await prefs.setStringList(_pendingScoreKey, remaining);
    } catch (_) {}
  }

  static bool containsProfanity(String text) {
    final normalized = text
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('@', 'a')
        .replaceAll('0', 'o')
        .replaceAll('1', 'i')
        .replaceAll('3', 'e')
        .replaceAll('5', 's')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');

    final badWords = [
      'sik', 'amk', 'amq', 'oc', 'orospu', 'pic', 'piç', 'yarrak', 'yarak',
      'got', 'göt', 'ibne', 'ipne', 'kahpe', 'fuck', 'shit', 'bitch', 'asshole',
      'cunt', 'dick', 'pussy', 'bastard', 'slut', 'whore', 'nigger', 'nigga',
      'aq', 'oç', 'sikerim', 'sikeyim', 'amcık', 'amcik', 'yarag'
    ];

    for (final word in badWords) {
      if (normalized.contains(word)) return true;
    }
    return false;
  }

  /// Check if player has already set a custom nickname
  Future<bool> hasSetNickname() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('has_set_nickname') == true) return true;
    final saved = await getSavedNickname();
    if (saved != null && saved.isNotEmpty && saved != 'Pluster Oyuncusu') {
      await prefs.setBool('has_set_nickname', true);
      return true;
    }
    return false;
  }

  /// Check if a nickname is available to be taken
  Future<bool> isNicknameAvailable(String nickname, {String? excludeUid}) async {
    final cleanNick = nickname.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleanNick.length < 3 || cleanNick.length > 20) return false;

    final lower = cleanNick.toLowerCase();
    if (lower == 'pluster oyuncusu' || lower == 'pluster player' || lower == 'pluster') {
      return false;
    }

    final db = _firestore;
    if (db == null) return true;

    try {
      final snapExact = await db
          .collection('leaderboard_endless')
          .where('nickname', isEqualTo: cleanNick)
          .limit(2)
          .get();

      for (final doc in snapExact.docs) {
        if (excludeUid != null && doc.id == excludeUid) continue;
        return false;
      }

      final snapLower = await db
          .collection('leaderboard_endless')
          .where('nickname_lowercase', isEqualTo: lower)
          .limit(2)
          .get();

      for (final doc in snapLower.docs) {
        if (excludeUid != null && doc.id == excludeUid) continue;
        return false;
      }

      return true;
    } catch (_) {
      return true;
    }
  }

  /// Update Nickname directly in Firestore with uniqueness and profanity filtering
  Future<Map<String, dynamic>> setNickname(String nickname, {bool isEn = false}) async {
    final cleanNick = nickname.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleanNick.length < 3 || cleanNick.length > 20) {
      return {
        'success': false,
        'errorMessage': isEn
            ? 'Nickname must be between 3 and 20 characters.'
            : 'Kullanıcı adı 3 ile 20 karakter arasında olmalıdır.'
      };
    }

    final lower = cleanNick.toLowerCase();
    if (lower == 'pluster oyuncusu' || lower == 'pluster player' || lower == 'pluster') {
      return {
        'success': false,
        'errorMessage': isEn
            ? 'This nickname is reserved. Please choose another.'
            : 'Bu kullanıcı adı sistem tarafından ayrılmıştır. Lütfen başka bir isim seçin.'
      };
    }

    if (containsProfanity(cleanNick)) {
      return {
        'success': false,
        'errorMessage': isEn
            ? 'The entered nickname contains inappropriate language.'
            : 'Girdiğiniz kullanıcı adı uygunsuz sözcükler içermektedir.'
      };
    }

    final user = await ensureAnonymousAuth();
    final db = _firestore;
    if (user == null || db == null) {
      return {
        'success': false,
        'errorMessage': isEn ? 'Could not sign in.' : 'Oturum açılamadı.'
      };
    }

    try {
      // 1) Check if nickname already exists (exact match)
      final snapExact = await db
          .collection('leaderboard_endless')
          .where('nickname', isEqualTo: cleanNick)
          .limit(2)
          .get();

      for (final doc in snapExact.docs) {
        if (doc.id != user.uid) {
          return {
            'success': false,
            'errorMessage': isEn
                ? 'This nickname is already taken. Please choose another.'
                : 'Bu kullanıcı adı zaten kullanılıyor. Lütfen başka bir isim seçin.'
          };
        }
      }

      // 2) Check if nickname already exists (case-insensitive match)
      final snapLower = await db
          .collection('leaderboard_endless')
          .where('nickname_lowercase', isEqualTo: lower)
          .limit(2)
          .get();

      for (final doc in snapLower.docs) {
        if (doc.id != user.uid) {
          return {
            'success': false,
            'errorMessage': isEn
                ? 'This nickname is already taken. Please choose another.'
                : 'Bu kullanıcı adı zaten kullanılıyor. Lütfen başka bir isim seçin.'
          };
        }
      }

      final now = FieldValue.serverTimestamp();
      final docRef = db.collection('leaderboard_endless').doc(user.uid);
      final docSnap = await docRef.get();
      final Map<String, dynamic> updateData = {
        'nickname': cleanNick,
        'nickname_lowercase': lower,
        'lastUpdated': now,
      };
      if (!docSnap.exists || docSnap.data()?['highScore'] == null) {
        updateData['highScore'] = 0;
      }
      await docRef.set(updateData, SetOptions(merge: true));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_nickname', cleanNick);
      await prefs.setBool('has_set_nickname', true);

      final weekId = getIsoWeekId();
      final weeklyRef = db.collection('leaderboard_endless_weekly').doc(weekId).collection('scores').doc(user.uid);
      final weeklyDoc = await weeklyRef.get();
      if (weeklyDoc.exists) {
        await weeklyRef.set({
          'nickname': cleanNick,
          'nickname_lowercase': lower,
        }, SetOptions(merge: true));
      }

      return {'success': true, 'nickname': cleanNick};
    } catch (e) {
      return {
        'success': false,
        'errorMessage': isEn ? 'Failed to update nickname.' : 'Kullanıcı adı güncellenemedi.'
      };
    }
  }

  /// Direct Firestore Query for Leaderboard (Allowed by Security Rules)
  Future<List<LeaderboardEntry>> fetchTopScores({bool weekly = false, int limit = 50}) async {
    try {
      await _ensureFirebaseInitialized();
      final db = _firestore;
      if (db == null) return [];

      Query query;
      if (weekly) {
        final weekId = getIsoWeekId();
        query = db
            .collection('leaderboard_endless_weekly')
            .doc(weekId)
            .collection('scores')
            .orderBy('highScore', descending: true)
            .limit(limit);
      } else {
        query = db
            .collection('leaderboard_endless')
            .orderBy('highScore', descending: true)
            .limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => LeaderboardEntry.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch Current User Rank via Direct Firestore Count
  Future<Map<String, dynamic>> getMyRank() async {
    final user = await ensureAnonymousAuth();
    final db = _firestore;
    if (user == null || db == null) {
      return {'rank': null, 'highScore': 0};
    }

    try {
      final globalRef = db.collection('leaderboard_endless').doc(user.uid);
      final globalDoc = await globalRef.get();

      if (!globalDoc.exists) {
        return {'rank': null, 'highScore': 0};
      }

      final myScore = (globalDoc.data()?['highScore'] as num? ?? 0).toInt();
      final higherCountSnap = await db.collection('leaderboard_endless').where('highScore', isGreaterThan: myScore).count().get();
      final rank = (higherCountSnap.count ?? 0) + 1;

      return {'rank': rank, 'highScore': myScore};
    } catch (e) {
      return {'rank': null, 'highScore': 0};
    }
  }

  /// Fetches saved local nickname if available
  Future<String?> getSavedNickname() async {
    final user = await ensureAnonymousAuth();
    final db = _firestore;
    if (user == null || db == null) return null;
    try {
      final doc = await db.collection('leaderboard_endless').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['nickname'] as String?;
      }
    } catch (_) {}
    return null;
  }
}
