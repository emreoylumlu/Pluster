import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum BossType {
  chaosMiniBoss,
  corruptedTileMiniBoss,
  hydraCoreFinalBoss,
  chronosPulsarFinalBoss,
  // ── 8 Yeni Mini-Boss ──
  mysteryMiniBoss,
  voltBomberMiniBoss,
  energyThiefMiniBoss,
  energyDrainerMiniBoss,
  stoneMonsterMiniBoss,
  earthquakeMiniBoss,
  iceSprayerMiniBoss,
  decayLordMiniBoss,
}

class BossInfo {
  final String name;
  final String title;
  final String subtitle;
  final String icon;
  final Color primaryColor;
  final int healthOrTargetScore;
  final bool isHpBoss;
  final List<BossAbilityInfo> abilities;
  final List<String> tactics;

  const BossInfo({
    required this.name,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.healthOrTargetScore,
    required this.isHpBoss,
    required this.abilities,
    required this.tactics,
  });

  static BossInfo getInfo(BossType type) {
    switch (type) {
      case BossType.chaosMiniBoss:
        return const BossInfo(
          name: 'KAOS BOSSU',
          title: 'ARA BOSS • KAT 8',
          subtitle: 'Izgara Düzenini Alt Üst Eden Siber Parazit',
          icon: '🌀',
          primaryColor: Color(0xFFE040FB),
          healthOrTargetScore: 1600,
          isHpBoss: false,
          abilities: [
            BossAbilityInfo(
              title: 'Kaos Karmaşası',
              description: 'Her 3 taş yerleştirmede bir, ızgaradaki tüm taşların yerlerini rastgele karıştırır.',
              icon: Icons.shuffle_rounded,
            ),
            BossAbilityInfo(
              title: 'Yüksek Skor Şartı',
              description: 'Katı tamamlamak için normal bölümlere kıyasla %60 daha yüksek skor hedeflenir (1600 Puan).',
              icon: Icons.trending_up_rounded,
            ),
          ],
          tactics: [
            'Karmaşaya yakalanmadan hızlı kombolarla 8+ patlamaları tetikle.',
            'Prizma ve Bomba taşlarını karıştırma anından hemen önce stratejik kullan.',
          ],
        );

      case BossType.corruptedTileMiniBoss:
        return const BossInfo(
          name: 'BOZUK VERİ BOSSU',
          title: 'ARA BOSS • KAT 8 (ACT 2)',
          subtitle: 'Taş Havuzunu Zehirleyen Virüs Çekirdeği',
          icon: '👾',
          primaryColor: Color(0xFFFF5252),
          healthOrTargetScore: 2000,
          isHpBoss: false,
          abilities: [
            BossAbilityInfo(
              title: 'Bozuk Taş Bulaştırma',
              description: 'Alt taraftaki 3\'lü taş havuzunuza rastgele Bozuk Taş (👾) ekler.',
              icon: Icons.bug_report_rounded,
            ),
            BossAbilityInfo(
              title: 'Pulse Enerji Emilimi',
              description: 'Bozuk Taş ızgaraya konup birleştirilirse skor vermez, %5 Pulse Enerjisi (-5⚡) çeker!',
              icon: Icons.battery_alert_rounded,
            ),
          ],
          tactics: [
            'Bozuk taşı ızgara köşesine atıp Bomba (🔥) ile yok et.',
            'Prizma (💎) koyarak Bozuk Taşı temizlenmiş sayıya dönüştür.',
            'Taş Yenileme (Reroll) ile Bozuk Taşı havuzdan silebilirsin!',
          ],
        );

      case BossType.hydraCoreFinalBoss:
        return const BossInfo(
          name: 'HYDRA-CORE',
          title: 'ACT 1 NİHAİ BOSS • KAT 15',
          subtitle: 'Siber Ağaç Ve Savunma Duvarı',
          icon: '👑',
          primaryColor: Color(0xFFFFD166),
          healthOrTargetScore: 1000,
          isHpBoss: true,
          abilities: [
            BossAbilityInfo(
              title: '1000 HP Savunma Kalkanı',
              description: 'Boss üst panelde devasa Can Barı ile belirir. Izgarada yaptığınız 8+ patlamaları doğrudan Boss\'a hasar vurur.',
              icon: Icons.shield_rounded,
            ),
            BossAbilityInfo(
              title: 'Veri Bozulması Uyarısı',
              description: 'Gelen taşların değerleri gizlenebilir, yüksek kombolar yaparak Boss\'u devirmelisiniz!',
              icon: Icons.bolt_rounded,
            ),
          ],
          tactics: [
            'Mıknatıs ve Çarpan taşları ile zincirleme kombolar kurarak tek hamlede devasa hasar ver!',
          ],
        );

      case BossType.chronosPulsarFinalBoss:
        return const BossInfo(
          name: 'CHRONOS-PULSAR',
          title: 'ACT 2 NİHAİ BOSS • KAT 15',
          subtitle: 'Kozmik Karadelik Ve Zaman Bükücü',
          icon: '🌌',
          primaryColor: Color(0xFF6AD4FF),
          healthOrTargetScore: 2500,
          isHpBoss: true,
          abilities: [
            BossAbilityInfo(
              title: '2500 HP Karadelik Çekirdeği',
              description: 'Izgarada yapılan her 8+ patlaması Boss\'un devasa 2500 HP barını azaltır.',
              icon: Icons.brightness_7_rounded,
            ),
            BossAbilityInfo(
              title: 'Madde Yutma & Geri Sayım',
              description: '5 hamlelik sayaç dolduğunda patlatılamayan en yüksek değerli taşı yutar ve HP tazeler!',
              icon: Icons.timer_rounded,
            ),
          ],
          tactics: [
            'Yüksek değerli taşların yutulmasını önlemek için sayacı sürekli sıfırla.',
          ],
        );

      case BossType.mysteryMiniBoss:
        return const BossInfo(
          name: 'BİLİNMEZ BOSSU',
          title: 'ARA BOSS • SIZINTI',
          subtitle: 'Taş Değerlerini Gizleyen Siber Sis',
          icon: '❓',
          primaryColor: Color(0xFF00E5FF),
          healthOrTargetScore: 1600,
          isHpBoss: false,
          abilities: [
            BossAbilityInfo(
              title: 'Görünmez Taş Sisleri',
              description: 'Savaş boyunca taşların sayısal değerlerini görmeden mantık yürüterek oynamalısınız.',
              icon: Icons.help_outline_rounded,
            ),
          ],
          tactics: [
            'Bomba ve Prizma taşlarını stratejik kullanarak alanı temizle.',
          ],
        );

      case BossType.voltBomberMiniBoss:
        return const BossInfo(
          name: 'VOLTAJ BOMBALAYICI',
          title: 'ARA BOSS • TEHLİKE',
          subtitle: 'Geri Sayımlı Volt Bombası Jeneratörü',
          icon: '💣',
          primaryColor: Color(0xFFFFAB40),
          healthOrTargetScore: 1800,
          isHpBoss: false,
          abilities: [
            BossAbilityInfo(
              title: 'Volt Bombası',
              description: 'Her 3 turda 3, 2, 1 geri sayımlı bomba bırakır. Patlarsa %15 Enerji harcar, 8 yapılırsa +500 skor ve +15⚡ verir.',
              icon: Icons.timer_rounded,
            ),
          ],
          tactics: [
            'Volt bombası patlamadan önce 8 değerli taş seviyesine getirip patlat.',
          ],
        );

      case BossType.energyThiefMiniBoss:
        return const BossInfo(
          name: 'ENERJİ HIRSIZI',
          title: 'ARA BOSS • YÜKSEK RİSK',
          subtitle: 'Enerji Çalan ve Hücre Aşırı Yükleyen Parazit',
          icon: '👿',
          primaryColor: Color(0xFFBA68C8),
          healthOrTargetScore: 2400,
          isHpBoss: false,
          abilities: [
            BossAbilityInfo(
              title: 'Hırsızlık & Şarj',
              description: 'Her 2 turda -5⚡ çalar ve rastgele hücreye +2 değer ekler. Hedef Skor 2 katıdır.',
              icon: Icons.bolt_rounded,
            ),
          ],
          tactics: [
            'Boss\'un +2 değer eklediği hücreleri 8 patlamasına dönüştürerek avantaja çevir.',
          ],
        );

      case BossType.energyDrainerMiniBoss:
        return const BossInfo(
          name: 'ENERJİ SÖMÜRÜCÜ',
          title: 'ARA BOSS • EMİLİM',
          subtitle: 'Birleşme Enerjisini Emen Vampir Çekirdek',
          icon: '🩸',
          primaryColor: Color(0xFFFF4081),
          healthOrTargetScore: 2000,
          isHpBoss: false,
          abilities: [
            BossAbilityInfo(
              title: 'Enerji Emilimi',
              description: 'Birleşmelerden kazanılan enerjinin %25\'ini çalar.',
              icon: Icons.water_drop_rounded,
            ),
          ],
          tactics: [
            'Yüksek kombolarla enerji kaybını kompanse et.',
          ],
        );

      case BossType.stoneMonsterMiniBoss:
        return const BossInfo(
          name: 'TAŞ CANAVARI',
          title: 'ARA BOSS • TAŞLAŞMA',
          subtitle: 'Hücreleri Taşlaştıran Sert Çekirdek',
          icon: '🗿',
          primaryColor: Color(0xFF8D6E63),
          healthOrTargetScore: 1800,
          isHpBoss: false,
          abilities: [
            BossAbilityInfo(
              title: 'Taşlaşma',
              description: 'Her 10 turda 1 rastgele taş taşlaşır ve kilitlenir.',
              icon: Icons.lock_rounded,
            ),
          ],
          tactics: [
            'Kilitlenen hücreleri Bomba veya Joker Prizma ile aç.',
          ],
        );

      case BossType.earthquakeMiniBoss:
        return const BossInfo(
          name: 'DEPREM YARATICI',
          title: 'ARA BOSS • TEKTONİK',
          subtitle: 'Tahtayı Sarsan Şok Dalgası',
          icon: '🌍',
          primaryColor: Color(0xFF795548),
          healthOrTargetScore: 2200,
          isHpBoss: false,
          abilities: [
            BossAbilityInfo(
              title: 'Şok Dalgası',
              description: 'Her 4 turda tahtayı sallar, tüm hücrelerin değeri 1 azalır.',
              icon: Icons.waves_rounded,
            ),
          ],
          tactics: [
            'Taş değerleri düşmeden 8 patlamalarını tamamla.',
          ],
        );

      case BossType.iceSprayerMiniBoss:
        return const BossInfo(
          name: 'BUZ PÜSKÜRTEN',
          title: 'ARA BOSS • DONMA',
          subtitle: 'Satırları Donduran Soğutucu Virüs',
          icon: '❄️',
          primaryColor: Color(0xFF40C4FF),
          healthOrTargetScore: 1900,
          isHpBoss: false,
          abilities: [
            BossAbilityInfo(
              title: 'Satır Dondurma',
              description: 'Her 3 turda rastgele bir satırı 1 tur boyunca dondurur.',
              icon: Icons.ac_unit_rounded,
            ),
          ],
          tactics: [
            'Donmuş satır dışındaki boş hücreleri kullan.',
          ],
        );

      case BossType.decayLordMiniBoss:
        return const BossInfo(
          name: 'ÇÜRÜME EFENDİSİ',
          title: 'ARA BOSS • SALGIN',
          subtitle: 'Hücreleri Çürüten ve Yayılan Enfeksiyon',
          icon: '🦠',
          primaryColor: Color(0xFF76FF03),
          healthOrTargetScore: 2000,
          isHpBoss: false,
          abilities: [
            BossAbilityInfo(
              title: 'Çürüme Bulaştırma',
              description: 'Her 2 turda çürüme bulaştırır, tur başı -1 değer düşürür ve komşu hücreye yayılır.',
              icon: Icons.bug_report_rounded,
            ),
          ],
          tactics: [
            'Çürüyen hücreleri patlatarak enfeksiyonu temizle.',
          ],
        );
    }
  }
}

class BossAbilityInfo {
  final String title;
  final String description;
  final IconData icon;

  const BossAbilityInfo({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class BossIntroScreen extends StatelessWidget {
  final BossType bossType;
  final VoidCallback onStartBattle;

  const BossIntroScreen({
    super.key,
    required this.bossType,
    required this.onStartBattle,
  });

  @override
  Widget build(BuildContext context) {
    final BossInfo info = BossInfo.getInfo(bossType);
    final Color mainColor = info.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFF060913),
      body: Stack(
        children: [
          // Background Gradient & Aura
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.3,
                  colors: [
                    mainColor.withValues(alpha: 0.35),
                    const Color(0xFF090E1A),
                    const Color(0xFF04060C),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Top Warning Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '⚠️ TEHLİKE! BOSS TEHDİDİ SAPTANDI',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Boss Avatar / Icon Box
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0F172A),
                      border: Border.all(color: mainColor, width: 3.0),
                      boxShadow: [
                        BoxShadow(
                          color: mainColor.withValues(alpha: 0.6),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        info.icon,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Boss Titles
                  Text(
                    info.title,
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Target Stat Badge (HP or Target Score)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: mainColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: mainColor, width: 1.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          info.isHpBoss ? Icons.favorite_rounded : Icons.military_tech_rounded,
                          color: mainColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          info.isHpBoss
                              ? 'BOSS CANI: ${info.healthOrTargetScore} HP'
                              : 'SKOR HEDEFİ: ${info.healthOrTargetScore} PUAN',
                          style: TextStyle(
                            color: mainColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Abilities Section
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '⚡ BOSS YETENEKLERİ VE TEHLİKELERİ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        ...info.abilities.map((ability) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: mainColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: mainColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(ability.icon, color: mainColor, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ability.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        ability.description,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11.5,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 8),
                        // Tactics Box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.lightbulb_rounded, color: Color(0xFF00E676), size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'ÖNERİLEN TAKTİK',
                                    style: TextStyle(
                                      color: Color(0xFF00E676),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                               ...info.tactics.map((tactic) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '• $tactic',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.87),
                                      fontSize: 11,
                                      height: 1.3,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Start Battle Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        onStartBattle();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 12,
                        shadowColor: mainColor.withValues(alpha: 0.5),
                      ),
                      icon: const Icon(Icons.flash_on_rounded, size: 22),
                      label: Text(
                        '${info.name} İLE SAVAŞA BAŞLA ⚔️',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
