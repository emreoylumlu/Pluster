const functions = require("firebase-functions");
const admin = require("firebase-admin");

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ── CONSTANTS ─────────────────────────────────────────────────────────────
// Maximum average score allowed per move for anti-cheat validation.
// Can easily be adjusted as game mechanics or combo multipliers evolve.
const MAX_SCORE_PER_MOVE = 600;

// ── HELPER FUNCTIONS ──────────────────────────────────────────────────────
/**
 * Calculates ISO-8601 week identifier string (e.g. "2026-W34")
 * Shared between score submission and weekly leaderboard reset functions.
 */
function getIsoWeekId(date = new Date()) {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay() || 7));
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  const weekNo = Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
  const year = d.getUTCFullYear();
  const formattedWeek = String(weekNo).padStart(2, "0");
  return `${year}-W${formattedWeek}`;
}

/**
 * Normalizes Turkish characters and removes non-alphanumeric symbols for profanity filtering.
 */
function normalizeText(text) {
  if (!text) return "";
  return text
    .toLowerCase()
    .replace(/ı/g, "i")
    .replace(/ş/g, "s")
    .replace(/ğ/g, "g")
    .replace(/ü/g, "u")
    .replace(/ö/g, "o")
    .replace(/ç/g, "c")
    .replace(/[^a-z0-9]/g, "");
}

// ── 2a. SUBMIT ENDLESS SCORE ──────────────────────────────────────────────
/**
 * Callable Function: submitEndlessScore
 * Validates auth, anti-cheat thresholds, and replay session IDs inside an
 * atomic Firestore Transaction before writing to leaderboards via Admin SDK.
 *
 * Input: { score: number, moveCount: number, sessionId: string }
 * Output: { success: boolean, isNewHighScore: boolean, globalRank: number|null }
 */
exports.submitEndlessScore = functions.https.onCall(async (data, context) => {
  // 1. Auth Validation
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Kullanıcı kimliği doğrulanmadı. Lütfen oyuna tekrar giriş yapın."
    );
  }

  const uid = context.auth.uid;
  const { score, moveCount, sessionId } = data || {};

  // 2. Parameter Validation
  if (typeof score !== "number" || typeof moveCount !== "number" || typeof sessionId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Geçersiz parametreler: score, moveCount ve sessionId gerekli."
    );
  }

  if (score < 0 || moveCount <= 0 || !sessionId.trim()) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Skor veya hamle sayısı geçersiz."
    );
  }

  // 3. Anti-Cheat Anomaly Check
  const scorePerMove = score / moveCount;
  if (scorePerMove > MAX_SCORE_PER_MOVE) {
    throw new functions.https.HttpsError(
      "out-of-range",
      `Anomali tespit edildi: Hamle başına skor üst sınırı (${MAX_SCORE_PER_MOVE}) aşıldı.`
    );
  }

  const now = admin.firestore.FieldValue.serverTimestamp();
  const weekId = getIsoWeekId();

  const sessionRef = db.collection("game_sessions").doc(sessionId);
  const globalRef = db.collection("leaderboard_endless").doc(uid);
  const weeklyRef = db
    .collection("leaderboard_endless_weekly")
    .doc(weekId)
    .collection("scores")
    .doc(uid);

  let isNewHighScore = false;
  let currentHighScore = score;

  // 4. ATOMIC TRANSACTION: Read & Write sessionId + Leaderboards
  await db.runTransaction(async (transaction) => {
    // Reads must occur before writes in Firestore Transactions
    const sessionDoc = await transaction.get(sessionRef);
    if (sessionDoc.exists) {
      throw new functions.https.HttpsError(
        "already-exists",
        "Bu oyun seansı daha önce kullanılmış. Tekrar gönderim engellendi."
      );
    }

    const globalDoc = await transaction.get(globalRef);
    let nickname = "Pluster Oyuncusu";

    if (globalDoc.exists) {
      const existingData = globalDoc.data();
      currentHighScore = existingData.highScore || 0;
      nickname = existingData.nickname || nickname;

      if (score > currentHighScore) {
        isNewHighScore = true;
        currentHighScore = score;
      }
    } else {
      isNewHighScore = true;
    }

    const weeklyDoc = await transaction.get(weeklyRef);
    const existingWeeklyHighScore = weeklyDoc.exists ? (weeklyDoc.data().highScore || 0) : 0;

    // Atomic Writes inside Transaction
    transaction.set(sessionRef, {
      uid: uid,
      score: score,
      moveCount: moveCount,
      submittedAt: now,
    });

    if (isNewHighScore) {
      transaction.set(
        globalRef,
        {
          nickname: nickname,
          highScore: currentHighScore,
          achievedAt: now,
          avatarId: "default_avatar",
          lastUpdated: now,
        },
        { merge: true }
      );
    }

    // Weekly score is ONLY updated if it strictly exceeds the existing weekly high score
    if (!weeklyDoc.exists || score > existingWeeklyHighScore) {
      transaction.set(
        weeklyRef,
        {
          nickname: nickname,
          highScore: score,
          achievedAt: now,
        },
        { merge: true }
      );
    }
  });

  // 5. Calculate Rank via Firestore Aggregation Count Query
  let globalRank = null;
  try {
    const higherCountSnap = await db
      .collection("leaderboard_endless")
      .where("highScore", ">", currentHighScore)
      .count()
      .get();
    globalRank = higherCountSnap.data().count + 1;
  } catch (_) {}

  return {
    success: true,
    isNewHighScore: isNewHighScore,
    globalRank: globalRank,
  };
});

// ── 2b. SET NICKNAME ──────────────────────────────────────────────────────
/**
 * Callable Function: setNickname
 * Validates length (3-20 chars) and performs normalized profanity filtering
 * against /banned_words before updating user nickname on leaderboards.
 *
 * Input: { nickname: string }
 * Output: { success: boolean, nickname: string }
 */
exports.setNickname = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Kullanıcı kimliği doğrulanmadı."
    );
  }

  const uid = context.auth.uid;
  const rawNickname = (data && data.nickname) ? String(data.nickname).trim() : "";

  // Length Validation
  if (rawNickname.length < 3 || rawNickname.length > 20) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Kullanıcı adı 3 ile 20 karakter arasında olmalıdır."
    );
  }

  // Normalized Profanity Filtering
  const normalizedInput = normalizeText(rawNickname);
  const bannedWordsSnap = await db.collection("banned_words").get();

  for (const doc of bannedWordsSnap.docs) {
    const bannedWord = doc.data().word;
    if (bannedWord) {
      const normalizedBanned = normalizeText(bannedWord);
      if (normalizedBanned && normalizedInput.includes(normalizedBanned)) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Girdiğiniz kullanıcı adı uygunsuz sözcükler içermektedir."
        );
      }
    }
  }

  const now = admin.firestore.FieldValue.serverTimestamp();
  const globalRef = db.collection("leaderboard_endless").doc(uid);
  const weekId = getIsoWeekId();
  const weeklyRef = db
    .collection("leaderboard_endless_weekly")
    .doc(weekId)
    .collection("scores")
    .doc(uid);

  const batch = db.batch();

  batch.set(
    globalRef,
    {
      nickname: rawNickname,
      lastUpdated: now,
    },
    { merge: true }
  );

  const weeklyDoc = await weeklyRef.get();
  if (weeklyDoc.exists) {
    batch.set(
      weeklyRef,
      {
        nickname: rawNickname,
      },
      { merge: true }
    );
  }

  await batch.commit();

  return {
    success: true,
    nickname: rawNickname,
  };
});

// ── 2c. GET MY RANK ───────────────────────────────────────────────────────
/**
 * Callable Function: getMyRank
 * Uses Firestore count() aggregation query to return the current user's rank.
 *
 * Output: { rank: number|null, highScore: number }
 */
exports.getMyRank = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Kullanıcı kimliği doğrulanmadı."
    );
  }

  const uid = context.auth.uid;
  const globalRef = db.collection("leaderboard_endless").doc(uid);
  const globalDoc = await globalRef.get();

  if (!globalDoc.exists) {
    return { rank: null, highScore: 0 };
  }

  const myScore = globalDoc.data().highScore || 0;
  const higherCountSnap = await db
    .collection("leaderboard_endless")
    .where("highScore", ">", myScore)
    .count()
    .get();

  const rank = higherCountSnap.data().count + 1;

  return {
    rank: rank,
    highScore: myScore,
  };
});

// ── 2d. RESET WEEKLY LEADERBOARD ──────────────────────────────────────────
/**
 * Scheduled Function: resetWeeklyLeaderboard
 * Triggers every Monday at 00:00 UTC+3 (Europe/Istanbul).
 * Archives previous week's Top 10 into /weekly_rewards_queue/{weekId}.
 */
exports.resetWeeklyLeaderboard = functions.pubsub
  .schedule("0 0 * * 1")
  .timeZone("Europe/Istanbul")
  .onRun(async (context) => {
    // Calculate last week's ISO weekId
    const lastWeekDate = new Date();
    lastWeekDate.setDate(lastWeekDate.getDate() - 7);
    const lastWeekId = getIsoWeekId(lastWeekDate);

    const topScoresSnap = await db
      .collection("leaderboard_endless_weekly")
      .doc(lastWeekId)
      .collection("scores")
      .orderBy("highScore", "desc")
      .limit(10)
      .get();

    if (topScoresSnap.empty) {
      console.log(`No weekly scores to archive for ${lastWeekId}`);
      return null;
    }

    const archiveRef = db.collection("weekly_rewards_queue").doc(lastWeekId);
    const topTen = topScoresSnap.docs.map((doc, idx) => ({
      rank: idx + 1,
      uid: doc.id,
      ...doc.data(),
    }));

    await archiveRef.set({
      weekId: lastWeekId,
      archivedAt: admin.firestore.FieldValue.serverTimestamp(),
      topTen: topTen,
    });

    console.log(`Successfully archived Top 10 for week ${lastWeekId}`);
    return null;
  });
