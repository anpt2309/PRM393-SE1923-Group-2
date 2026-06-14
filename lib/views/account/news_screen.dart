import 'package:flutter/material.dart';
import 'settings_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showDetail = false;
  String _currentSubTab = 'Script';
  double _audioProgress = 0.0;

  // GIẢ ĐỊNH ID BÀI BÁO (Ánh xạ vào cột article_id trong DB)
  final int _currentArticleId = 101;

  // Thời gian cập nhật hiển thị trên giao diện (Ánh xạ updated_at)
  String _lastSavedTime = "19:30 - 30/05/2026";

  // Bộ điều khiển nội dung nhập của Notepad (Ánh xạ vào cột note_content)
  final TextEditingController _noteController = TextEditingController(
      text: "- Cần chú ý cấu trúc cụm từ: 「聖地巡礼」(せいちじゅんれい) - Hành hương thánh địa.\n- Học thêm từ vựng N2: 巡る (めぐる)."
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // HÀM XỬ LÝ LƯU GHI CHÚ XUỐNG DATABASE (user_article_notes)
  void _saveNoteToDatabase() {
    final String content = _noteController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung trước khi lưu!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Thực tế sẽ gọi API lên MySQL ở đây. Khi thành công thì cập nhật lại thời gian hiển thị:
    setState(() {
      final now = DateTime.now();
      _lastSavedTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} - ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã lưu ghi chú thành công!'),
        backgroundColor: Colors.amber.shade700,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _showDetail ? _buildDetailAppBar() : _buildListAppBar(),
      body: _showDetail ? _buildNewsDetailView() : _buildNewsListView(),
    );
  }

  // --- HÀM XÂY DỰNG APPBAR ---
  PreferredSizeWidget _buildListAppBar() {
    return AppBar(
      title: const Text('Tin Tức', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const BackButton(color: Colors.black87),
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.black54,
        indicatorColor: Colors.blue,
        tabs: const [
          Tab(text: 'Easy News'), Tab(text: 'Top'), Tab(text: 'Chính Trị'),
          Tab(text: 'Kinh Tế'), Tab(text: 'Xã Hội'), Tab(text: 'Giải Trí'),
          Tab(text: 'Quốc Tế'), Tab(text: 'Giáo Dục'), Tab(text: 'Thể Thao'),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildDetailAppBar() {
    return AppBar(
      title: const Text('Chi Tiết', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.blue, size: 20),
        onPressed: () => setState(() => _showDetail = false),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.add, color: Colors.blue, size: 28),
          onSelected: (value) {
            if (value == 'home') {
              setState(() => _showDetail = false);
            } else if (value == 'search') {
              _showQuickSearchBottomSheet();
            } else if (value == 'settings') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'home',
              child: Row(
                children: [
                  Icon(Icons.home_outlined, color: Colors.black54),
                  SizedBox(width: 10),
                  Text('Trang chính'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'search',
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.black54),
                  SizedBox(width: 10),
                  Text('Tra cứu'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, color: Colors.black54),
                  SizedBox(width: 10),
                  Text('Cài đặt'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showQuickSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tra cứu nhanh từ vựng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Nhập từ tiếng Nhật cần tra...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- GIAO DIỆN 1: DANH SÁCH BÀI BÁO ---
  Widget _buildNewsListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80, height: 80,
                color: Colors.blue.withValues(alpha: 0.1),
                child: const Icon(Icons.image, color: Colors.blue),
              ),
            ),
            title: const Text(
              '「下着ユニバ」騒動 女性インスタグラマーが「聖地巡礼」',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text('ネット衝撃「メンタル強すぎ」', style: TextStyle(fontSize: 12, color: Colors.black54)),
            ),
            trailing: const Icon(Icons.star_border, color: Colors.blue),
            onTap: () => setState(() => _showDetail = true),
          ),
        );
      },
    );
  }

  // --- GIAO DIỆN 2: CHI TIẾT BÀI BÁO TOÀN MÀN HÌNH ---
  Widget _buildNewsDetailView() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '「下着ユニバ」騒動 女性インスタグラマーが “聖地巡礼” 「ちゃんと服装た」ネット衝撃 「メンタル強すぎ」',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5), height: 1.4),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_circle_fill, color: Color(0xFF1E88E5), size: 36),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  const Text('00:00', style: TextStyle(color: Color(0xFFE57373), fontSize: 13, fontWeight: FontWeight.w500)),
                  Expanded(
                    child: Slider(
                      value: _audioProgress,
                      activeColor: const Color(0xFF1E88E5),
                      inactiveColor: Colors.black12,
                      onChanged: (value) => setState(() => _audioProgress = value),
                    ),
                  ),
                  const Text('00:00', style: TextStyle(color: Color(0xFFE57373), fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: const Color(0xFFEFEFEF), borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: [
                    _buildSubTabButton('Script'),
                    _buildSubTabButton('Ẩn Hira'),
                    _buildSubTabButton('Dịch'),
                    _buildSubTabButton('Từ Vựng'),
                    _buildSubTabButton('Note'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),

        Expanded(
          child: Container(
            color: Colors.white,
            width: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: _buildContentLayoutByTab(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubTabButton(String title) {
    bool isSelected = _currentSubTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentSubTab = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E88E5) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : Colors.black54),
          ),
        ),
      ),
    );
  }

  // --- HÀM PHÂN PHỐI NỘI DUNG THEO TAB ĐANG CHỌN ---
  Widget _buildContentLayoutByTab() {
    bool showFurigana = _currentSubTab != 'Ẩn Hira';
    bool showTranslation = _currentSubTab == 'Dịch';
    bool showVocabList = _currentSubTab == 'Từ Vựng';

    // =========================================================================
    // 🔴 BIẾN ĐỔI TAB NOTE THÀNH NOTEPAD CO GIÃN TOÀN MÀN HÌNH - CLICK ĐÂU CŨNG GÕ ĐƯỢC
    // =========================================================================
    if (_currentSubTab == 'Note') {
      return Container(
        width: double.infinity,
        height: 320, // Xác định vùng chiều cao cố định để tờ giấy luôn mở rộng ra
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDE7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade200, width: 1.2),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề và Thời gian cập nhật
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_note, color: Colors.amber, size: 22),
                    const SizedBox(width: 4),
                    Text(
                      'Cập nhật: $_lastSavedTime',
                      style: const TextStyle(fontSize: 11, color: Colors.black45, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                // Nút Lưu tối giản - Hài hòa, tiết kiệm diện tích tối đa
                Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    height: 32,
                    child: TextButton(
                      onPressed: _saveNoteToDatabase,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.amber.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Lưu', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.amber, thickness: 0.8, height: 16),

            // 🔴 ĐÃ SỬA: Dùng Expanded bao quanh TextField để click bất kỳ vị trí nào trên tờ giấy cũng Focus gõ chữ được
            Expanded(
              child: TextField(
                controller: _noteController,
                maxLines: null, // Cho phép tự động xuống dòng vô hạn theo không gian trống
                expands: true,  // Ép ô nhập liệu kéo giãn hết phần không gian trống phía dưới
                textAlignVertical: TextAlignVertical.top, // Đưa con trỏ bắt đầu luôn nằm trên cùng bên trái
                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Nhập ghi chú học tập của bạn tại đây...',
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 8),


          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Đoạn 1
        _buildParagraphBlock(
          showFurigana: showFurigana,
          spans: [
            _textSpan('「下着', 'したぎ'), _textSpan('ユニバ」', ''), _textSpan('騒動', 'そうどう'),
            _textSpan('女性', 'じょせい'), _textSpan('インスタグラマーが', ''),
            _textSpan('“聖地', 'せいち'), _textSpan('巡礼”', 'じゅんれい'),
            _textSpan('「ちゃんと', ''), _textSpan('服装た', 'ふくそうた'),
            _textSpan('ネット', ''), _textSpan('衝撃', 'しょうげき'),
            _textSpan('「メンタル', ''), _textSpan('強すぎ」', 'つよすぎ'),
          ],
        ),
        if (showTranslation) ...[
          const SizedBox(height: 6),
          const Text(
            'Vụ náo loạn "Underwear Univa" Một nữ Instagrammer "hành hương đến những nơi linh thiêng" và "ăn mặc chỉnh tề" đã tác động mạnh đến tinh thần "quá mạnh"',
            style: TextStyle(color: Color(0xFF29B6F6), fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
          ),
        ],

        const SizedBox(height: 20),

        // Đoạn 2
        _buildParagraphBlock(
          showFurigana: showFurigana,
          spans: [
            _textSpan('ユニバーサル・スタジオ・ジャパン', ''), _textSpan('(USJ) で', ''), _textSpan('過度な', 'かどな'),
            _textSpan('“露出', 'ろしゅつ'), _textSpan('コスプレ”をしたことで', ''), _textSpan('波紋', 'はもん'),
            _textSpan('\u3092', ''), _textSpan('呼んだ', 'よんだ'), _textSpan('女性', 'じょせい'), _textSpan('インスタグラマーが', ''),
            _textSpan('30日までにインスタグラムを', ''), _textSpan('更新', 'こうしん'), _textSpan('しました', ''),
          ],
        ),
        if (showTranslation) ...[
          const SizedBox(height: 6),
          const Text(
            'Một nữ Instagrammer nữ gây xôn xao khi thực hiện màn "cosplay lộ liễu" quá mức tại Universal Studios Japan (USJ) đã cập nhật Instagram của mình vào ngày 30.',
            style: TextStyle(color: Color(0xFF29B6F6), fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
          ),
        ],

        if (showVocabList) ...[
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(thickness: 1)),
          _buildVocabularyItem('1/ 楽しむ', 'たのしむ', '[LẠC/NHẠC] Vui, tận hưởng, thưởng thức (enj...', 'N4'),
          _buildVocabularyItem('2/ 公式', 'こうしき', '[CÔNG THỨC] Công thức, định thức (非公式 :...', 'N2'),
          _buildVocabularyItem('3/ 巡る', 'めぐる', '[TUẦN] Đi quanh, dạo quanh', 'N2'),
          _buildVocabularyItem('4/ 撮影', 'さつえい', '[TOÁT ẢNH] Sự chụp ảnh', 'N2'),
        ],
      ],
    );
  }

  Widget _buildParagraphBlock({required bool showFurigana, required List<Widget> spans}) {
    return Wrap(spacing: 2, runSpacing: 10, children: spans);
  }

  Widget _textSpan(String text, String furigana) {
    bool hasFurigana = _currentSubTab != 'Ẩn Hira' && furigana.isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          hasFurigana ? furigana : '',
          style: const TextStyle(fontSize: 10, color: Colors.black54, height: 1.0, fontFamily: 'sans-serif'),
        ),
        Text(text, style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.2)),
      ],
    );
  }

  Widget _buildVocabularyItem(String word, String hira, String meaning, String level) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$word  ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
              Text(hira, style: const TextStyle(fontSize: 15, color: Color(0xFF1E88E5))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.blue.shade400, borderRadius: BorderRadius.circular(4)),
                child: Text(level, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star_border, color: Colors.black45, size: 22),
              const SizedBox(width: 8),
             ],
          ),
          const SizedBox(height: 4),
          Text(meaning, style: const TextStyle(fontSize: 14, color: Colors.black87, overflow: TextOverflow.ellipsis)),
          const Divider(height: 16, thickness: 0.5),
        ],
      ),
    );
  }
}