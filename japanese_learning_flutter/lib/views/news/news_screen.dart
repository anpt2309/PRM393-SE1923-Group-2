import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/app_setting_provider.dart';
import '../../../widgets/add_menu_button.dart';
import '../../../providers/news_provider.dart';
import '../../../providers/vocab_provider.dart';
import '../../../data/models/news.dart';
import '../../../data/models/vocabulary.dart';

class NewsScreen extends ConsumerStatefulWidget {
  final double initialFontSize;
  final bool initialDarkMode;
  final Map<String, String>? targetArticle;

  const NewsScreen({
    super.key,
    this.initialFontSize = 14.0,
    this.initialDarkMode = false,
    this.targetArticle,
  });

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // --- QUẢN LÝ CẤU HÌNH GIAO DIỆN NỘI BỘ (Khi cấu hình từ cài đặt nhanh) ---
  double? _customFontSize;
  bool? _customDarkMode;

  // --- CÁC BIẾN QUẢN LÝ FILE NGHE THỰC TẾ ---
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _currentlyPlayingUrl;

  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _tabController = TabController(length: 0, vsync: this);

    _audioPlayer = AudioPlayer();
    _setupAudioListeners();

    Future.microtask(() {
      if (widget.targetArticle != null) {
        ref.read(newsProvider.notifier).selectArticleByMap(widget.targetArticle!);
      } else {
        ref.read(newsProvider.notifier).loadInitialData();
      }
    });
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
    final settings = ref.watch(appSettingProvider);
    final newsState = ref.watch(newsProvider);

    ref.listen<NewsState>(newsProvider, (previous, next) {
      final prevArticle = previous?.selectedArticle;
      final nextArticle = next.selectedArticle;
      
      if (nextArticle != null) {
        if (prevArticle == null || prevArticle.id != nextArticle.id) {
          _noteController.text = next.articleNotes[nextArticle.id] ?? '';
        } else {
          final prevNote = previous?.articleNotes[nextArticle.id] ?? '';
          final nextNote = next.articleNotes[nextArticle.id] ?? '';
          if (prevNote != nextNote && _noteController.text == prevNote) {
            _noteController.text = nextNote;
          }
        }
      }
    });

    // 1. Khai báo biến cơ bản chỉ 1 lần
    final isCustomDark = _customDarkMode ?? settings.isDarkMode;
    final double scale = settings.textScaleFactor;
    final double currentFontSize =
        _customFontSize ?? (widget.initialFontSize * scale);

    // Dynamic TabController recreation
    if (newsState.categories.isNotEmpty &&
        newsState.categories.length != _tabController.length) {
      _tabController.dispose();
      final selectedIndex = newsState.selectedCategory != null
          ? newsState.categories.indexOf(newsState.selectedCategory!)
          : 0;
      _tabController = TabController(
        length: newsState.categories.length,
        vsync: this,
        initialIndex: selectedIndex.clamp(0, newsState.categories.length - 1),
      );
    }

    // 2. Định nghĩa màu sắc
    final backgroundColor =
        isCustomDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isCustomDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isCustomDark ? Colors.white70 : Colors.black87;
    final subTextColor = isCustomDark ? Colors.white60 : Colors.black54;
    final tabBgColor =
        isCustomDark ? const Color(0xFF2C2C2C) : const Color(0xFFB0BEC5);

    // 3. Định nghĩa màu cho AppBar dựa trên các biến đã khai báo ở trên
    final appBarColor = isCustomDark ? cardColor : Colors.blue;
    final appBarTextColor = isCustomDark ? textColor : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: newsState.showDetail
          ? _buildDetailAppBar(appBarColor, appBarTextColor)
          : _buildListAppBar(newsState, appBarColor, appBarTextColor, tabBgColor),
      body: newsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : newsState.showDetail
              ? _buildNewsDetailView(newsState, cardColor, textColor, subTextColor,
                  isCustomDark, currentFontSize, scale)
              : _buildNewsListView(newsState.articles, cardColor, textColor,
                  subTextColor, currentFontSize),
    );
  }

  PreferredSizeWidget _buildListAppBar(
      NewsState newsState, Color appBarColor, Color appBarTextColor, Color tabBgColor) {
    return AppBar(
      title: Text('Tin Tức',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: appBarTextColor,
              fontSize: 18)),
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
          child: newsState.categories.isEmpty
              ? const SizedBox.shrink()
              : TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: const Color(0xFF1E88E5),
                  unselectedLabelColor: appBarTextColor,
                  indicator: const BoxDecoration(),
                  labelStyle:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  unselectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.normal, fontSize: 13.5),
                  onTap: (index) {
                    if (index < newsState.categories.length) {
                      ref
                          .read(newsProvider.notifier)
                          .selectCategory(newsState.categories[index]);
                    }
                  },
                  tabs: newsState.categories
                      .map((cat) => Tab(text: cat.categoryName))
                      .toList(),
                ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildDetailAppBar(
      Color appBarColor, Color appBarTextColor) {
    return AppBar(
      title: Text('Chi Tiết',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: appBarTextColor,
              fontSize: 18)),
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
            ref.read(newsProvider.notifier).goBackToList();
            setState(() {
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
          icon: const Icon(Icons.add, color: Colors.white, size: 26),
          onAction: (value) {
            if (value == 'settings') {
              context.push('/profile/settings');
            }
          },
        ),
      ],
    );
  }

  Widget _buildNewsListView(List<NewsArticle> articlesSource,
      Color cardColor, Color textColor, Color subTextColor, double fontSize) {
    if (articlesSource.isEmpty) {
      return Center(
          child:
              Text("Không có bài viết nào", style: TextStyle(color: subTextColor)));
    }
    final favoriteIds = ref.watch(newsProvider).favoriteArticleIds;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: articlesSource.length,
      itemBuilder: (context, index) {
        final article = articlesSource[index];
        bool isStarred = favoriteIds.contains(article.id);

        return Card(
          color: cardColor,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                article.imageUrl,
                width: 75,
                height: 75,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 75,
                  height: 75,
                  color: Colors.blue.withOpacity(0.1),
                  child: const Icon(Icons.image, color: Colors.blue),
                ),
              ),
            ),
            title: Text(article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    height: 1.3,
                    color: textColor)),
            subtitle: article.description.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(article.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: fontSize - 2, color: subTextColor)))
                : null,
            trailing: IconButton(
              icon: Icon(isStarred ? Icons.star : Icons.star_border,
                  color: isStarred ? Colors.amber : const Color(0xFF1E88E5),
                  size: 24),
              onPressed: () {
                ref.read(newsProvider.notifier).toggleFavorite(article.id);
                _showSnackBarShort(isStarred
                    ? 'Đã bỏ lưu bài viết!'
                    : 'Đã lưu bài viết thành công!');
              },
            ),
            onTap: () {
              ref.read(newsProvider.notifier).selectArticle(article);
              setState(() {
                _position = Duration.zero;
                _duration = Duration.zero;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildNewsDetailView(NewsState newsState, Color cardColor, Color textColor,
      Color subTextColor, bool isDarkMode, double fontSize, double scale) {
    final article = newsState.selectedArticle;
    if (article == null) return const SizedBox.shrink();
    String audioUrl = article.audioUrl;

    return Column(
      children: [
        Container(
          color: cardColor,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: TextStyle(
                    fontSize: fontSize + 1,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E88E5),
                    height: 1.4),
              ),
              if (article.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  article.description,
                  style: TextStyle(
                      fontSize: fontSize - 1.5,
                      fontStyle: FontStyle.italic,
                      color: subTextColor,
                      height: 1.4),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF2C2C2C)
                        : const Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: [
                    _buildSubTabButton('Script', subTextColor, newsState.currentSubTab),
                    _buildSubTabButton('Ẩn Hira', subTextColor, newsState.currentSubTab),
                    _buildSubTabButton('Dịch', subTextColor, newsState.currentSubTab),
                    _buildSubTabButton('Từ Vựng', subTextColor, newsState.currentSubTab),
                    _buildSubTabButton('Note', subTextColor, newsState.currentSubTab),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
            height: 1,
            thickness: 1,
            color: isDarkMode ? Colors.white10 : const Color(0xFFE0E0E0)),
        Expanded(
          child: Container(
            color: cardColor,
            width: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: _buildContentLayoutByTab(
                  article, newsState.currentSubTab, textColor, subTextColor, isDarkMode, fontSize),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubTabButton(String title, Color subTextColor, String currentSubTab) {
    bool isSelected = currentSubTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(newsProvider.notifier).changeSubTab(title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1E88E5) : Colors.transparent,
              borderRadius: BorderRadius.circular(6)),
          alignment: Alignment.center,
          child: Text(title,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : subTextColor)),
        ),
      ),
    );
  }

  Widget _buildContentLayoutByTab(
      NewsArticle article, String currentSubTab, Color textColor, Color subTextColor, bool isDarkMode, double fontSize) {
    bool showFurigana = currentSubTab != 'Ẩn Hira';
    bool showTranslation = currentSubTab == 'Dịch';
    bool showVocabList = currentSubTab == 'Từ Vựng';

    if (currentSubTab == 'Note') {
      final savedTime = ref.read(newsProvider).noteSavedTimes[article.id] ?? "Chưa có";
      return Container(
        width: double.infinity,
        height: 320,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF2D2A1E)
                : const Color(0xFFFFFDE7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200, width: 1.2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.edit_note, color: Colors.amber, size: 22),
                  const SizedBox(width: 4),
                  Text('Cập nhật: $savedTime',
                      style: TextStyle(
                          fontSize: 11,
                          color: subTextColor,
                          fontStyle: FontStyle.italic))
                ]),
                SizedBox(
                    height: 32,
                    child: TextButton(
                        onPressed: () {
                          ref.read(newsProvider.notifier).saveNote(article.id, _noteController.text);
                          _showSnackBarShort('Đã lưu ghi chú thành công!');
                        },
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.amber.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16)),
                        child: const Text('Lưu',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold)))),
              ],
            ),
            const Divider(color: Colors.amber, thickness: 0.8, height: 16),
            Expanded(
                child: TextField(
                    controller: _noteController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: TextStyle(
                        fontSize: fontSize, color: textColor, height: 1.5),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Nhập ghi chú...',
                        hintStyle: TextStyle(
                            color: isDarkMode ? Colors.white30 : Colors.black38,
                            fontSize: 13)))),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildParagraphBlock(
          showFurigana: showFurigana,
          spans: article.spans
              .map((s) => _textSpan(s.text, s.furigana, currentSubTab, fontSize, textColor, subTextColor))
              .toList(),
        ),
        if (showTranslation) ...[
          const SizedBox(height: 12),
          Text(
            article.contentTranslation,
            style: TextStyle(
                color: const Color(0xFF29B6F6),
                fontSize: fontSize,
                height: 1.4,
                fontWeight: FontWeight.w500),
          ),
        ],
        if (showVocabList) ...[
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                  color: isDarkMode ? Colors.white10 : Colors.black12)),
          if (article.vocabularies.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Không có từ vựng tiêu biểu cho bài báo này.',
                style: TextStyle(fontSize: fontSize, color: subTextColor),
              ),
            ),
          ...article.vocabularies.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final v = entry.value;
            return _buildVocabularyItem(
              v,
              '$idx/ ${v.word}',
              fontSize,
              textColor,
              subTextColor,
              isDarkMode,
            );
          }),
        ],
      ],
    );
  }

  Widget _buildParagraphBlock(
          {required bool showFurigana, required List<Widget> spans}) =>
      Wrap(spacing: 2, runSpacing: 10, children: spans);

  Widget _textSpan(String text, String furigana, String currentSubTab, double fontSize,
      Color textColor, Color subTextColor) {
    bool hasFurigana = currentSubTab != 'Ẩn Hira' && furigana.isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(hasFurigana ? furigana : '',
            style: TextStyle(
                fontSize: fontSize - 4,
                color: subTextColor,
                height: 1.0,
                fontFamily: 'sans-serif')),
        Text(text,
            style:
                TextStyle(fontSize: fontSize + 2, color: textColor, height: 1.2)),
      ],
    );
  }

  Widget _buildVocabularyItem(
      VocabularyWord vocab,
      String indexLabel,
      double fontSize,
      Color textColor,
      Color subTextColor,
      bool isDarkMode) {
    final favoriteVocabIds = ref.watch(vocabStudyProvider).favoriteVocabIds;
    final isStarred = favoriteVocabIds.contains(vocab.id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$indexLabel  ',
                  style: TextStyle(
                      fontSize: fontSize + 2,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E88E5))),
              Text(vocab.hiragana,
                  style: TextStyle(
                      fontSize: fontSize + 1, color: const Color(0xFF1E88E5))),
              const Spacer(),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(vocab.wordType,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  isStarred ? Icons.star : Icons.star_border,
                  color: isStarred ? Colors.amber : subTextColor,
                  size: 24,
                ),
                onPressed: () {
                  ref.read(vocabStudyProvider.notifier).toggleFavorite(vocab.id);
                  _showSnackBarShort(isStarred
                      ? 'Đã bỏ lưu từ vựng!'
                      : 'Đã lưu từ vựng thành công!');
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 4),
          Text(vocab.vietnameseMeaning,
              style: TextStyle(
                  fontSize: fontSize,
                  color: textColor,
                  overflow: TextOverflow.ellipsis)),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Divider(
                height: 1,
                thickness: 0.5,
                color: isDarkMode ? Colors.white10 : Colors.black12),
          ),
        ],
      ),
    );
  }
}