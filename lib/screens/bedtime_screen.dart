import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:history_zukan/models/index.dart';

/// C3: 寝る前歴史モード
/// 端末TTSで0.8x速度で読み上げ、オレンジ暗闇UIで就寝前リスニング体験を提供。
class BedtimeScreen extends StatefulWidget {
  const BedtimeScreen({super.key});

  @override
  State<BedtimeScreen> createState() => _BedtimeScreenState();
}

class _BedtimeScreenState extends State<BedtimeScreen> {
  late FlutterTts _tts;
  bool _isPlaying = false;
  bool _isPaused = false;
  int _currentIndex = 0;
  int _remainingSeconds = 600; // 10分タイマー
  Timer? _countdownTimer;

  // 寝る前歴史プレイリスト（拡張版）
  final List<_BedtimeEntry> _entries = [
    _BedtimeEntry(
      title: '大化の改新',
      era: '飛鳥時代・645年',
      text:
          '大化元年、中大兄皇子と中臣鎌足は、権力を一手に握っていた蘇我入鹿を宮中で暗殺しました。これを「乙巳の変」といいます。その後、天皇中心の中央集権国家を目指した政治改革が断行されます。戸籍の作成、班田収授法の施行、そして公地公民制の採用。日本という国の骨格が、この時代に形づくられていきました。',
    ),
    _BedtimeEntry(
      title: '壇ノ浦の戦い',
      era: '平安時代末期・1185年',
      text:
          '文治元年3月、関門海峡の壇ノ浦で、源義経率いる源氏と平家の最後の戦いが行われました。潮の流れを巧みに読んだ源氏軍が大勝し、幼い安徳天皇は三種の神器とともに海に沈んだといわれます。「平家物語」はその悲劇を「諸行無常の響きあり」という言葉で語り始めます。海面を赤く染めた血の記憶は、歌や物語として語り継がれました。',
    ),
    _BedtimeEntry(
      title: '元寇と神風',
      era: '鎌倉時代・1274年と1281年',
      text:
          '2回にわたって日本に攻め込んだモンゴル帝国の大軍は、いずれも暴風雨に見舞われて撤退を余儀なくされました。「てつはう」と呼ばれる爆弾を使うモンゴル軍に日本武士は苦戦しましたが、この「神風」が日本を救ったと信じられました。しかし無敵の元軍と戦い続けた武士たちは疲弊し、やがて鎌倉幕府が倒れるきっかけともなりました。',
    ),
    _BedtimeEntry(
      title: '本能寺の変',
      era: '戦国時代・1582年',
      text:
          '天正10年6月2日の深夜。京都の本能寺に宿泊していた織田信長は、家臣・明智光秀の謀反により突然囲まれました。信長は抵抗するも多勢に無勢、最終的に寺に火を放ち自害したと伝えられています。天下統一まであと一歩だった信長の夢は、炎の中に消えていきました。しかしその意志は、秀吉・家康へと受け継がれていきます。',
    ),
    _BedtimeEntry(
      title: '関ヶ原の戦い',
      era: '江戸時代初期・1600年',
      text:
          '慶長5年9月15日、天下分け目と呼ばれる一大決戦が美濃国関ヶ原で行われました。東軍・徳川家康と西軍・石田三成が激突。わずか半日で決着し、東軍の圧勝に終わりました。この戦いをきっかけに徳川幕府が開かれ、260年以上続く太平の世が始まります。一つの朝の戦いが、日本の形を大きく変えた瞬間でした。',
    ),
    _BedtimeEntry(
      title: '黒船来航',
      era: '幕末・1853年',
      text:
          '嘉永6年、アメリカ合衆国の東インド艦隊司令官ペリーが4隻の黒船を率いて浦賀に来航しました。その蒸気船の威容に江戸の人々は驚き、「泰平の眠りをさます上喜撰」と川柳に詠まれました。開国か攘夷かをめぐる議論は幕府を揺るがし、やがて明治維新へとつながる大きなうねりを生み出しました。',
    ),
    _BedtimeEntry(
      title: '邪馬台国の女王・卑弥呼',
      era: '弥生時代・3世紀',
      text:
          '今から1800年ほど前、日本には邪馬台国という国があり、卑弥呼という女王が治めていました。彼女は「鬼道」と呼ばれる占いや祈りで人々をまとめ、中国・魏の皇帝に使いを送りました。皇帝は喜んで「親魏倭王」という称号と100枚の銅鏡を贈りました。邪馬台国がどこにあったかは今もわかっていません。謎に包まれた女王の物語は今も人々を惹きつけます。',
    ),
    _BedtimeEntry(
      title: 'ガリレオと宇宙の謎',
      era: '近世ヨーロッパ・1609年',
      text:
          'イタリアの科学者ガリレオは望遠鏡を空に向け、月の山々や木星の衛星を発見しました。「地球は太陽の周りを回っている」と主張したため、教会に裁判にかけられ「それでも地球は動く」とつぶやいたといいます。真実を追い求めることをあきらめなかったガリレオ。その勇気が近代科学のとびらを開きました。夜空の星は今も変わらず輝いています。',
    ),
    _BedtimeEntry(
      title: 'マハトマ・ガンジーの平和の革命',
      era: '近代インド・1930年',
      text:
          'インドのガンジーは「武器を持たずに戦える」ことを世界に示しました。塩の行進では何百キロも歩いて海まで行き、自分たちで塩を作ることでイギリスへの抵抗を示しました。刑務所に入れられても、殴られても、暴力でやり返しませんでした。「目には目を」では世界は盲目になる、と語ったガンジー。平和な心で眠りにつきましょう。',
    ),
    _BedtimeEntry(
      title: '源氏物語と紫式部',
      era: '平安時代・1000年ごろ',
      text:
          '今から1000年以上前、宮中に仕える紫式部という女性が、光源氏という貴公子の恋と人生を描いた物語を書きました。全54巻、世界最古の長編小説といわれる「源氏物語」です。秋の月を眺めながら、筆を走らせた紫式部。彼女の言葉は1000年の時を越えて、今もあなたに届いています。おやすみなさい。',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(0.4); // 0.8x相当（FlutterTts基準で0.4）
    await _tts.setVolume(0.9);
    await _tts.setPitch(0.95);

    _tts.setCompletionHandler(() {
      // 現在のエントリ読み上げ完了 → 次へ
      if (mounted && _isPlaying) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _entries.length;
        });
        _speakCurrent();
      }
    });
  }

  Future<void> _speakCurrent() async {
    final entry = _entries[_currentIndex];
    await _tts.speak('${entry.title}。${entry.era}。${entry.text}');
  }

  Future<void> _play() async {
    if (_isPaused) {
      await _tts.speak(_entries[_currentIndex].text);
    } else {
      await _speakCurrent();
    }
    setState(() {
      _isPlaying = true;
      _isPaused = false;
    });
    _startTimer();
  }

  Future<void> _pause() async {
    await _tts.stop();
    setState(() {
      _isPaused = true;
      _isPlaying = false;
    });
    _countdownTimer?.cancel();
  }

  Future<void> _stop() async {
    await _tts.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _remainingSeconds = 600;
    });
    _countdownTimer?.cancel();
  }

  void _skipNext() {
    _tts.stop();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _entries.length;
    });
    if (_isPlaying) _speakCurrent();
  }

  void _skipPrev() {
    _tts.stop();
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _entries.length) % _entries.length;
    });
    if (_isPlaying) _speakCurrent();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        _stop();
      }
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _tts.stop();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entries[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF1A0A00), // 深い暗闇
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFF8C00),
        elevation: 0,
        title: const Text(
          '🌙 寝る前歴史',
          style: TextStyle(color: Color(0xFFFF8C00)),
        ),
        actions: [
          // タイマー表示
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              _formatTime(_remainingSeconds),
              style: const TextStyle(
                color: Color(0xFFFF8C00),
                fontSize: 14,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 上部：エントリ情報
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 現在の話
                  Text(
                    entry.era,
                    style: const TextStyle(
                      color: Color(0xFF996633),
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.title,
                    style: const TextStyle(
                      color: Color(0xFFFFB347),
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    entry.text,
                    style: const TextStyle(
                      color: Color(0xFFE8C99A),
                      fontSize: 18,
                      height: 1.9,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // プレイリスト一覧
                  const Text(
                    '今夜のお話',
                    style: TextStyle(
                      color: Color(0xFF996633),
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_entries.length, (i) {
                    final isActive = i == _currentIndex;
                    return GestureDetector(
                      onTap: () {
                        _tts.stop();
                        setState(() => _currentIndex = i);
                        if (_isPlaying) _speakCurrent();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF3D1A00)
                              : Colors.transparent,
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFFFF8C00)
                                : const Color(0xFF4A2800),
                            width: isActive ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            if (isActive && _isPlaying)
                              const Icon(Icons.volume_up,
                                  size: 14, color: Color(0xFFFF8C00))
                            else
                              Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? const Color(0xFFFF8C00)
                                      : const Color(0xFF664422),
                                  fontSize: 12,
                                ),
                              ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _entries[i].title,
                                style: TextStyle(
                                  color: isActive
                                      ? const Color(0xFFFFB347)
                                      : const Color(0xFF996633),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // 下部コントロール
          Container(
            color: const Color(0xFF0D0500),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: _skipPrev,
                  icon: const Icon(Icons.skip_previous_rounded),
                  color: const Color(0xFF996633),
                  iconSize: 36,
                ),
                // 再生 / 一時停止
                GestureDetector(
                  onTap: _isPlaying ? _pause : _play,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isPlaying
                          ? const Color(0xFF3D1A00)
                          : const Color(0xFFFF8C00),
                      border: Border.all(
                        color: const Color(0xFFFF8C00),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: _isPlaying
                          ? const Color(0xFFFF8C00)
                          : const Color(0xFF1A0A00),
                      size: 36,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _skipNext,
                  icon: const Icon(Icons.skip_next_rounded),
                  color: const Color(0xFF996633),
                  iconSize: 36,
                ),
                IconButton(
                  onPressed: _isPlaying || _isPaused ? _stop : null,
                  icon: const Icon(Icons.stop_rounded),
                  color: (_isPlaying || _isPaused)
                      ? const Color(0xFF664422)
                      : const Color(0xFF2A1200),
                  iconSize: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BedtimeEntry {
  final String title;
  final String era;
  final String text;
  const _BedtimeEntry(
      {required this.title, required this.era, required this.text});
}
