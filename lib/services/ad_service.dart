import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._privateConstructor();
  static final AdService instance = AdService._privateConstructor();

  bool _isInitialized = false;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  // Test Ad Unit IDs provided by Google AdMob
  String get _interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-2256332337444717/4212701960'; // Android Real Interstitial
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4486959549'; // iOS Test Interstitial
    }
    return '';
  }

  String get _rewardedAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return 'ca-app-pub-2256332337444717/8175997707'; // Android Real Rewarded
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // iOS Test Rewarded
    }
    return '';
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('[AdService] MobileAds initialized successfully.');
      preloadAds();
    } catch (e) {
      debugPrint('[AdService] Initialization error: $e');
    }
  }

  void preloadAds() {
    loadInterstitialAd();
    loadRewardedAd();
  }

  void loadInterstitialAd() {
    if (kIsWeb || _isInterstitialLoading || _interstitialAd != null) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdService] Interstitial Ad loaded.');
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Interstitial Ad failed to load: ${error.message}');
          _interstitialAd = null;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  void showInterstitialAd({VoidCallback? onAdClosed}) {
    if (_interstitialAd == null) {
      debugPrint('[AdService] Interstitial Ad not ready. Continuing flow.');
      loadInterstitialAd();
      onAdClosed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdService] Interstitial Ad dismissed.');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Interstitial Ad failed to show: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onAdClosed?.call();
      },
    );

    _interstitialAd!.show();
  }

  void loadRewardedAd() {
    if (kIsWeb || _isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdService] Rewarded Ad loaded.');
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Rewarded Ad failed to load: ${error.message}');
          _rewardedAd = null;
          _isRewardedLoading = false;
        },
      ),
    );
  }

  void showRewardedAd({required Function(bool rewardEarned) onCompleted}) {
    if (_rewardedAd == null) {
      debugPrint('[AdService] Rewarded Ad not ready. Fallback handling.');
      loadRewardedAd();
      onCompleted(false);
      return;
    }

    bool earnedReward = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdService] Rewarded Ad dismissed. Earned: $earnedReward');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onCompleted(earnedReward);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Rewarded Ad failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onCompleted(false);
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('[AdService] User earned reward: ${reward.amount} ${reward.type}');
        earnedReward = true;
      },
    );
  }

  bool get isRewardedAdReady => _rewardedAd != null;
  bool get isInterstitialAdReady => _interstitialAd != null;
}
