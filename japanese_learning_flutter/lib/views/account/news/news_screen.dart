import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';
import '../../../main.dart';
import '../../../widgets/add_menu_button.dart';

class NewsScreen extends StatefulWidget {
  // Thêm các tham số cấu hình giao diện động từ Settings truyền vào (hoặc dùng mặc định)
  final double initialFontSize;
  final bool initialDarkMode;
  // Nếu màn hình này được mở từ trang Favorite để xem một bài viết cụ thể
  final Map<String, String>? targetArticle;

  const NewsScreen({
    super.key,
    this.initialFontSize = 14.0,
    this.initialDarkMode = false,
    this.targetArticle,
  });

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showDetail = false;
  String _currentSubTab = 'Script';
  int _selectedTopicIndex = 0;

  // --- QUẢN LÝ CẤU HÌNH GIAO DIỆN NỘI BỘ (Khi cấu hình từ cài đặt nhanh) ---
  double? _customFontSize;
  bool? _customDarkMode;

  // --- CÁC BIẾN QUẢN LÝ FILE NGHE THỰC TẾ ---
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _currentlyPlayingUrl;

  String _lastSavedTime = "19:30 - 30/05/2026";

  late TextEditingController _noteController;
  Map<String, String>? _selectedArticle;

  // DANH SÁCH BÀI BÁO MẪU static để đồng bộ dữ liệu giữa các màn hình
  static final List<Map<String, String>> _mockArticles = [
    {
      'title': '「下着ユニバ」騒動 女性インスタグラマーが「聖地巡礼」',
      'subtitle': 'ネット衝撃「メンタル強すぎ」',
      'image': 'https://picsum.photos/id/101/200/200',
      'is_favorite': '0',
      'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'
    },
    {
      'title': '日本の桜 開花予想2026 今年の見頃 là khi nào?',
      'subtitle': '気象庁発表・旅行客に大人気',
      'image': 'https://picsum.photos/id/102/200/200',
      'is_favorite': '1',
      'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'
    },
    {
      'title': '東京スカイツリー 開業記念イベントが盛大に開催',
      'subtitle': '限定ライトアップも実施中',
      'image': 'https://picsum.photos/id/103/200/200',
      'is_favorite': '0',
      'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'
    },
    {
      'title': '京都の古い町並みを守る 新たな取り組みがスタート',
      'subtitle': '伝統文化 của Kinh Đô cổ kính',
      'image': 'https://picsum.photos/id/104/200/200',
      'is_favorite': '0',
      'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3'
    },
  ];

  // Getter static để màn hình Favorite dễ dàng lấy danh sách bài viết đã lưu
  static List<Map<String, String>> get favoriteArticles =>
      _mockArticles.where((article) => article['is_favorite'] == '1').toList();

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(
        text: "- Cần chú ý cấu trúc cụm từ: 「聖地巡礼」(せいちじゅんれい) - Hành hương thánh địa.\n- Học thêm từ vựng N2: 巡る (めぐる)."
    );

    _tabController = TabController(length: 9, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTopicIndex = _tabController.index;
        });
      }
    });

    // Nếu màn hình được mở chỉ định một bài viết cụ thể từ Favorite
    if (widget.targetArticle != null) {
      _selectedArticle = widget.targetArticle;
      _showDetail = true;
    }

    _audioPlayer = AudioPlayer();
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() => _duration = newDuration);
      }
    });
    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() => _position = newPosition);
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback(String url) async {
    try {
      if (_isPlaying && _currentlyPlayingUrl == url) {
        await _audioPlayer.pause();
      } else {
        if (_currentlyPlayingUrl != url) {
          await _audioPlayer.stop();
          _currentlyPlayingUrl = url;
          _position = Duration.zero;
          _duration = Duration.zero;
        }
        await _audioPlayer.play(UrlSource(url));
      }
    } catch (e) {
      _showSnackBarShort("Không thể tải file nghe lúc này!");
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _saveNoteToDatabase() {
    final String content = _noteController.text.trim();
    if (content.isEmpty) {
      _showSnackBarShort('Vui lòng nhập nội dung trước khi lưu!');
      return;
    }
    setState(() {
      final now = DateTime.now();
      _lastSavedTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} - ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    });
    _showSnackBarShort('Đã lưu ghi chú thành công!');
  }

  void _showSnackBarShort(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, child) {
        // 1. Khai báo biến cơ bản chỉ 1 lần
        final isCustomDark = _customDarkMode ?? appSettings.isCustomDarkColor;
        final double scale = appSettings.textScaleFactor;
        final double currentFontSize = _customFontSize ?? (widget.initialFontSize * scale);

        // 2. Định nghĩa màu sắc
        final backgroundColor = isCustomDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
        final cardColor = isCustomDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isCustomDark ? Colors.white70 : Colors.black87;
        final subTextColor = isCustomDark ? Colors.white60 : Colors.black54;
        final tabBgColor = isCustomDark ? const Color(0xFF2C2C2C) : const Color(0xFFB0BEC5);

        // 3. Định nghĩa màu cho AppBar dựa trên các biến đã khai báo ở trên
        final appBarColor = isCustomDark ? cardColor : Colors.blue;
        final appBarTextColor = isCustomDark ? textColor : Colors.white;
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: _showDetail
              ? _buildDetailAppBar(appBarColor, appBarTextColor)
              : _buildListAppBar(appBarColor, appBarTextColor, tabBgColor),
          body: _showDetail
              ? _buildNewsDetailView(cardColor, textColor, subTextColor, isCustomDark, currentFontSize, scale)
              : _buildNewsListView(_mockArticles, cardColor, textColor, subTextColor, currentFontSize),
        );
      },
    );
  }

  PreferredSizeWidget _buildListAppBar(Color appBarColor, Color appBarTextColor, Color tabBgColor) {
    return AppBar(
      title: Text('Tin Tức', style: TextStyle(fontWeight: FontWeight.bold, color: appBarTextColor, fontSize: 18)),
      centerTitle: true,
      backgroundColor: appBarColor,
      elevation: 0,
      leading: BackButton(color: appBarTextColor),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          width: double.infinity,
          height: 48,
          color: tabBgColor,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF1E88E5),
            unselectedLabelColor: appBarTextColor,
            indicator: const BoxDecoration(),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13.5),
            tabs: const [
              Tab(text: 'Easy News'), Tab(text: 'Top'), Tab(text: 'Chính Trị'),
              Tab(text: 'Kinh Tế'), Tab(text: 'Xã Hội'), Tab(text: 'Giải Trí'),
              Tab(text: 'Quốc Tế'), Tab(text: 'Giáo Dục'), Tab(text: 'Thể Thao'),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildDetailAppBar(Color appBarColor, Color appBarTextColor) {
    return AppBar(
      title: Text('Chi Tiết', style: TextStyle(fontWeight: FontWeight.bold, color: appBarTextColor, fontSize: 18)),
      centerTitle: true,
      backgroundColor: appBarColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: appBarTextColor, size: 20),
        onPressed: () async {
          await _audioPlayer.stop(); // Tắt audio ngay lập tức

          if (widget.targetArticle != null) {
            Navigator.pop(context);
          } else {
            setState(() {
              _showDetail = false;
              _isPlaying = false;
            });
          }
        },
      ),
      actions: [
        GlobalAddMenuButton(
          cardColor: appBarColor,
          textColor: appBarTextColor,
          subTextColor: appBarTextColor.withOpacity(0.7),
          icon: Icon(Icons.add, color: Colors.white, size: 26),
          onAction: (value) {
            if (value == 'settings') {
              // Điều hướng đến cài đặt
              context.push('/profile/settings');
            }
          },
        ),
      ],
    );
  }

  Widget _buildNewsListView(List<Map<String, String>> articlesSource, Color cardColor, Color textColor, Color subTextColor, double fontSize) {
    if (articlesSource.isEmpty) {
      return Center(child: Text("Không có bài viết nào", style: TextStyle(color: subTextColor)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: articlesSource.length,
      itemBuilder: (context, index) {
        final article = articlesSource[index];
        bool isStarred = article['is_favorite'] == '1';

        return Card(
          color: cardColor,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                article['image']!, width: 75, height: 75, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 75, height: 75, color: Colors.blue.withOpacity(0.1),
                  child: const Icon(Icons.image, color: Colors.blue),
                ),
              ),
            ),
            title: Text(
                article['title']!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, height: 1.3, color: textColor)
            ),
            subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(article['subtitle']!, style: TextStyle(fontSize: fontSize - 2, color: subTextColor))
            ),
            trailing: IconButton(
              icon: Icon(isStarred ? Icons.star : Icons.star_border, color: isStarred ? Colors.amber : const Color(0xFF1E88E5), size: 24),
              onPressed: () {
                setState(() {
                  if (article['is_favorite'] == '1') {
                    article['is_favorite'] = '0';
                    _showSnackBarShort('Đã bỏ lưu bài viết!');
                  } else {
                    article['is_favorite'] = '1';
                    _showSnackBarShort('Đã lưu bài viết thành công!');
                  }
                });
              },
            ),
            onTap: () {
              setState(() {
                _selectedArticle = article;
                _showDetail = true;
                _position = Duration.zero;
                _duration = Duration.zero;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildNewsDetailView(Color cardColor, Color textColor, Color subTextColor, bool isDarkMode, double fontSize, double scale) {
    if (_selectedArticle == null) return const SizedBox.shrink();
    String audioUrl = _selectedArticle!['audio_url'] ?? '';

    return Column(
      children: [
        Container(
          color: cardColor,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedArticle!['title']!,
                style: TextStyle(fontSize: fontSize + 1, fontWeight: FontWeight.bold, color: const Color(0xFF1E88E5), height: 1.4),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  IconButton(
                    icon: Icon(
                        _isPlaying && _currentlyPlayingUrl == audioUrl
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        color: const Color(0xFF1E88E5),
                        size: 38
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _togglePlayback(audioUrl),
                  ),
                  const SizedBox(width: 8),
                  Text(_formatDuration(_position), style: const TextStyle(color: Color(0xFFE57373), fontSize: 13, fontWeight: FontWeight.w500)),
                  Expanded(
                    child: Slider(
                      min: 0.0,
                      max: _duration.inMilliseconds.toDouble() == 0.0 ? 1.0 : _duration.inMilliseconds.toDouble(),
                      value: _position.inMilliseconds.toDouble().clamp(0.0, _duration.inMilliseconds.toDouble() == 0.0 ? 1.0 : _duration.inMilliseconds.toDouble()),
                      activeColor: const Color(0xFF1E88E5),
                      inactiveColor: isDarkMode ? Colors.white24 : Colors.black12,
                      onChanged: (value) async {
                        final seekPosition = Duration(milliseconds: value.toInt());
                        await _audioPlayer.seek(seekPosition);
                      },
                    ),
                  ),
                  Text(_formatDuration(_duration), style: const TextStyle(color: Color(0xFFE57373), fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFEFEFEF), borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: [
                    _buildSubTabButton('Script', subTextColor),
                    _buildSubTabButton('Ẩn Hira', subTextColor),
                    _buildSubTabButton('Dịch', subTextColor),
                    _buildSubTabButton('Từ Vựng', subTextColor),
                    _buildSubTabButton('Note', subTextColor),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: isDarkMode ? Colors.white10 : const Color(0xFFE0E0E0)),

        Expanded(
          child: Container(
            color: cardColor,
            width: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: _buildContentLayoutByTab(textColor, subTextColor, isDarkMode, fontSize),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubTabButton(String title, Color subTextColor) {
    bool isSelected = _currentSubTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentSubTab = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(color: isSelected ? const Color(0xFF1E88E5) : Colors.transparent, borderRadius: BorderRadius.circular(6)),
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : subTextColor)),
        ),
      ),
    );
  }

  Widget _buildContentLayoutByTab(Color textColor, Color subTextColor, bool isDarkMode, double fontSize) {
    bool showFurigana = _currentSubTab != 'Ẩn Hira';
    bool showTranslation = _currentSubTab == 'Dịch';
    bool showVocabList = _currentSubTab == 'Từ Vựng';

    if (_currentSubTab == 'Note') {
      return Container(
        width: double.infinity, height: 320, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2D2A1E) : const Color(0xFFFFFDE7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200, width: 1.2)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [const Icon(Icons.edit_note, color: Colors.amber, size: 22), const SizedBox(width: 4), Text('Cập nhật: $_lastSavedTime', style: TextStyle(fontSize: 11, color: subTextColor, fontStyle: FontStyle.italic))]),
                SizedBox(height: 32, child: TextButton(onPressed: _saveNoteToDatabase, style: TextButton.styleFrom(backgroundColor: Colors.amber.shade600, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), padding: const EdgeInsets.symmetric(horizontal: 16)), child: const Text('Lưu', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))),
              ],
            ),
            const Divider(color: Colors.amber, thickness: 0.8, height: 16),
            Expanded(child: TextField(controller: _noteController, maxLines: null, expands: true, textAlignVertical: TextAlignVertical.top, style: TextStyle(fontSize: fontSize, color: textColor, height: 1.5), decoration: InputDecoration(border: InputBorder.none, hintText: 'Nhập ghi chú...', hintStyle: TextStyle(color: isDarkMode ? Colors.white30 : Colors.black38, fontSize: 13)))),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildParagraphBlock(
          showFurigana: showFurigana,
          spans: [
            _textSpan('「下着', 'したぎ', fontSize, textColor, subTextColor), _textSpan('ユニバ」', '', fontSize, textColor, subTextColor), _textSpan('騒動', 'そうどう', fontSize, textColor, subTextColor),
            _textSpan('女性', 'じょせい', fontSize, textColor, subTextColor), _textSpan('インスタグラマーが', '', fontSize, textColor, subTextColor),
            _textSpan('“聖地', 'せいち', fontSize, textColor, subTextColor), _textSpan('巡礼”', 'じゅんれい', fontSize, textColor, subTextColor),
            _textSpan('「ちゃんと', '', fontSize, textColor, subTextColor), _textSpan('服装た', 'ふくそうた', fontSize, textColor, subTextColor),
            _textSpan('ネット', '', fontSize, textColor, subTextColor), _textSpan('衝撃', 'しょうげき', fontSize, textColor, subTextColor),
            _textSpan('「メンタル', '', fontSize, textColor, subTextColor), _textSpan('強すぎ」', 'つよすぎ', fontSize, textColor, subTextColor),
          ],
        ),
        if (showTranslation) ...[
          const SizedBox(height: 6),
          Text(
            'Vụ náo loạn "Underwear Univa" Một nữ Instagrammer "hành hương đến những nơi linh thiêng" và "ăn mặc chỉnh tề" đã tác động mạnh đến tinh thần "quá mạnh"',
            style: TextStyle(color: const Color(0xFF29B6F6), fontSize: fontSize, height: 1.4, fontWeight: FontWeight.w500),
          ),
        ],
        if (showVocabList) ...[
          Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(color: isDarkMode ? Colors.white10 : Colors.black12)),
          _buildVocabularyItem('1/ 楽しむ', 'たのしむ', '[LẠC/NHẠC] Vui, tận hưởng, thưởng thức (enj...', 'N4', fontSize, textColor, subTextColor, isDarkMode),
          _buildVocabularyItem('2/ 公式', 'こうしき', '[CÔNG THỨC] Công thức, định thức (非公式 :...', 'N2', fontSize, textColor, subTextColor, isDarkMode),
        ],
      ],
    );
  }

  Widget _buildParagraphBlock({required bool showFurigana, required List<Widget> spans}) => Wrap(spacing: 2, runSpacing: 10, children: spans);

  Widget _textSpan(String text, String furigana, double fontSize, Color textColor, Color subTextColor) {
    bool hasFurigana = _currentSubTab != 'Ẩn Hira' && furigana.isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(hasFurigana ? furigana : '', style: TextStyle(fontSize: fontSize - 4, color: subTextColor, height: 1.0, fontFamily: 'sans-serif')),
        Text(text, style: TextStyle(fontSize: fontSize + 2, color: textColor, height: 1.2)),
      ],
    );
  }

  Widget _buildVocabularyItem(String word, String hira, String meaning, String level, double fontSize, Color textColor, Color subTextColor, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$word  ', style: TextStyle(fontSize: fontSize + 2, fontWeight: FontWeight.bold, color: const Color(0xFF1E88E5))),
              Text(hira, style: TextStyle(fontSize: fontSize + 1, color: const Color(0xFF1E88E5))),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.blue.shade400, borderRadius: BorderRadius.circular(4)), child: Text(level, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              Icon(Icons.star_border, color: subTextColor, size: 22),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 4),
          Text(meaning, style: TextStyle(fontSize: fontSize, color: textColor, overflow: TextOverflow.ellipsis)),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Divider(height: 1, thickness: 0.5, color: isDarkMode ? Colors.white10 : Colors.black12),
          ),
        ],
      ),
    );
  }
}