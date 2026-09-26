import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pluster/services/leaderboard_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Nickname validation rejects too short or too long names', () async {
    final resShort = await LeaderboardService.instance.setNickname('ab');
    expect(resShort['success'], isFalse);
    expect(resShort['errorMessage'], contains('3 ile 20'));

    final resLong = await LeaderboardService.instance.setNickname('a' * 21);
    expect(resLong['success'], isFalse);
  });

  test('Nickname validation rejects reserved default names', () async {
    final res1 = await LeaderboardService.instance.setNickname('Pluster Oyuncusu');
    expect(res1['success'], isFalse);
    expect(res1['errorMessage'], contains('ayrılmıştır'));

    final res2 = await LeaderboardService.instance.setNickname('pluster player');
    expect(res2['success'], isFalse);

    final res3 = await LeaderboardService.instance.setNickname('pluster');
    expect(res3['success'], isFalse);
  });

  test('Nickname validation rejects profanity', () async {
    expect(LeaderboardService.containsProfanity('kötükelimeleramk'), isTrue);
    final res = await LeaderboardService.instance.setNickname('super_amk_player');
    expect(res['success'], isFalse);
    expect(res['errorMessage'], contains('uygunsuz'));
  });
}
