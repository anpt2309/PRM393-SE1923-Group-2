import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/app_setting_provider.dart';

class CreateSetScreen extends ConsumerStatefulWidget {
  final int userId;
  final int? setId;
  final String? setName;
  final String? description;
  final bool? isPublic;

  const CreateSetScreen({
    super.key,
    required this.userId,
    this.setId,
    this.setName,
    this.description,
    this.isPublic,
  });

  @override
  ConsumerState<CreateSetScreen> createState() => _CreateSetScreenState();
}

class _CreateSetScreenState extends ConsumerState<CreateSetScreen> {
  // Thông tin bộ thẻ
  final TextEditingController _setNameController = TextEditingController();
  final TextEditingController _setDescriptionController = TextEditingController();
  late bool _isPublic;

  // Chế độ nhập thẻ: 'single' hoặc 'bulk'
  String _inputMode = 'single';

  // Dữ liệu cho chế độ nhập từng thẻ
  List<Map<String, dynamic>> _cards = [];
  List<int> _deletedCardIds = [];

  // Dữ liệu cho chế độ nhập bulk
  final TextEditingController _bulkController = TextEditingController();
  final TextEditingController _delimiterController = TextEditingController(text: '\t');
  String _bulkPreview = '';
  String _selectedDelimiter = '\t';

  // Các tùy chọn phân cách nhanh
  final List<Map<String, dynamic>> _quickDelimiters = [
    {'label': 'Tab', 'value': '\t', 'icon': '↹'},
    {'label': 'Dấu phẩy', 'value': ',', 'icon': ','},
    {'label': 'Dấu chấm phẩy', 'value': ';', 'icon': ';'},
    {'label': 'Khoảng trắng', 'value': ' ', 'icon': '␣'},
    {'label': 'Dấu |', 'value': '|', 'icon': '|'},
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isPublic = widget.isPublic ?? true;
    _setNameController.text = widget.setName ?? '';
    _setDescriptionController.text = widget.description ?? '';

    if (widget.setId != null) {
      Future.microtask(() => _loadExistingCards());
    } else {
      _addNewCard();
    }
    _delimiterController.addListener(_onDelimiterChanged);
  }

  Future<void> _loadExistingCards() async {
    setState(() => _isLoading = true);
    try {
      final provider = ref.read(flashcardProvider);
      final cards = await provider.loadFlashcards(widget.setId!);
      
      if (mounted) {
        setState(() {
          _cards = cards.map((c) => {
            'dbId': c.id,
            'id': c.id.toString(),
            'wordController': TextEditingController(text: c.front),
            'meaningController': TextEditingController(text: c.back),
            'exampleController': TextEditingController(text: c.note),
          }).toList();
          
          if (_cards.isEmpty) {
            _addNewCard();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Lỗi tải thẻ: $e', Colors.red);
      }
    }
  }

  @override
  void dispose() {
    _setNameController.dispose();
    _setDescriptionController.dispose();
    _bulkController.dispose();
    _delimiterController.dispose();
    for (var card in _cards) {
      card['wordController']?.dispose();
      card['meaningController']?.dispose();
      card['exampleController']?.dispose();
    }
    super.dispose();
  }

  void _onDelimiterChanged() {
    setState(() {
      _selectedDelimiter = _delimiterController.text;
      if (_selectedDelimiter.isEmpty) {
        _selectedDelimiter = '\t';
      }
    });
  }

  // ========== CHE DO NHAP DUNG THE ==========
  void _addNewCard() {
    setState(() {
      _cards.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'wordController': TextEditingController(),
        'meaningController': TextEditingController(),
        'exampleController': TextEditingController(),
      });
    });
  }

  void _removeCard(String id) {
    if (_cards.length == 1) {
      _showSnackBar('Bộ phải có ít nhất một thẻ', Colors.orange);
      return;
    }

    final cardIndex = _cards.indexWhere((card) => card['id'] == id);
    if (cardIndex != -1) {
      final card = _cards[cardIndex];
      if (card['dbId'] != null) {
        _deletedCardIds.add(card['dbId']);
      }
      
      card['wordController']?.dispose();
      card['meaningController']?.dispose();
      card['exampleController']?.dispose();

      setState(() {
        _cards.removeAt(cardIndex);
      });
    }
  }

  // ========== CHE DO NHAP NHIEU THE ==========
  void _setQuickDelimiter(String delimiter) {
    setState(() {
      _selectedDelimiter = delimiter;
      _delimiterController.text = delimiter;
    });
  }

  void _parseBulkText() {
    final text = _bulkController.text.trim();
    if (text.isEmpty) {
      _showSnackBar('Vui lòng nhập dữ liệu', Colors.orange);
      return;
    }

    String delimiter = _selectedDelimiter;
    if (delimiter.isEmpty) {
      delimiter = '\t';
    }

    // Xử lý ký tự đặc biệt trong regex
    String regexDelimiter;
    if (delimiter == '\t') {
      regexDelimiter = '\t';
    } else if (delimiter == '|') {
      regexDelimiter = '\\|';
    } else if (delimiter == '.') {
      regexDelimiter = '\\.';
    } else if (delimiter == '*') {
      regexDelimiter = '\\*';
    } else if (delimiter == '+') {
      regexDelimiter = '\\+';
    } else if (delimiter == '?') {
      regexDelimiter = '\\?';
    } else if (delimiter == '^') {
      regexDelimiter = '\\^';
    } else if (delimiter == '\$') {
      regexDelimiter = '\\\$';
    } else {
      regexDelimiter = RegExp.escape(delimiter);
    }

    final lines = text.split('\n');
    final List<Map<String, String>> parsedCards = [];

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      List<String> parts;
      try {
        parts = line.split(RegExp(regexDelimiter));
      } catch (e) {
        parts = [line];
      }

      final word = parts[0].trim();
      final meaning = parts.length > 1 ? parts[1].trim() : '';
      final example = parts.length > 2 ? parts[2].trim() : '';

      if (word.isNotEmpty && meaning.isNotEmpty) {
        parsedCards.add({
          'word': word,
          'meaning': meaning,
          'example': example,
        });
      }
    }

    if (parsedCards.isEmpty) {
      _showSnackBar('Không tìm thấy dữ liệu hợp lệ. Kiểm tra lại ký tự phân cách!', Colors.red);
      return;
    }

    // Ghi nhận các card cũ có dbId để xóa sau này nếu người dùng muốn thay thế hoàn toàn
    for (var card in _cards) {
      if (card['dbId'] != null) {
        _deletedCardIds.add(card['dbId']);
      }
      card['wordController']?.dispose();
      card['meaningController']?.dispose();
      card['exampleController']?.dispose();
    }

    setState(() {
      _cards.clear();
      for (var card in parsedCards) {
        _cards.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString() + parsedCards.indexOf(card).toString(),
          'wordController': TextEditingController(text: card['word']),
          'meaningController': TextEditingController(text: card['meaning']),
          'exampleController': TextEditingController(text: card['example']),
        });
      }
    });

    _showSnackBar('Đã tạo ${parsedCards.length} thẻ mới. Hãy nhấn Cập nhật để lưu!', Colors.green);

    // Tạo preview
    String preview = '';
    for (var i = 0; i < parsedCards.length && i < 5; i++) {
      preview += '${i + 1}. ${parsedCards[i]['word']} -> ${parsedCards[i]['meaning']}\n';
    }
    if (parsedCards.length > 5) {
      preview += '... và ${parsedCards.length - 5} thẻ khác';
    }
    setState(() {
      _bulkPreview = preview;
    });
  }

  void _clearBulk() {
    _bulkController.clear();
    setState(() {
      _bulkPreview = '';
    });
  }

  // ========== TAO/SUA BO THE ==========
  Future<void> _submitSet() async {
    if (_setNameController.text.trim().isEmpty) {
      _showSnackBar('Vui lòng nhập tên bộ', Colors.red);
      return;
    }

    final invalidCards = _cards.where((card) =>
    card['wordController'].text.trim().isEmpty ||
        card['meaningController'].text.trim().isEmpty);

    if (invalidCards.isNotEmpty) {
      _showSnackBar('Tất cả thẻ phải có từ và nghĩa', Colors.red);
      return;
    }

    final provider = ref.read(flashcardProvider);
    setState(() => _isLoading = true);

    bool success = false;
    int? currentSetId = widget.setId;

    try {
      if (currentSetId == null) {
        // TAO BO THE MOI
        final newSet = await provider.createSet(
          userId: widget.userId,
          name: _setNameController.text.trim(),
          description: _setDescriptionController.text.trim(),
          isPublic: _isPublic,
        );

        if (newSet != null) {
          currentSetId = newSet.id;
          // Tạo các thẻ
          for (var card in _cards) {
            await provider.createFlashcard(
              userId: widget.userId,
              setId: currentSetId!,
              front: card['wordController'].text.trim(),
              back: card['meaningController'].text.trim(),
              note: card['exampleController'].text.trim().isEmpty ? null : card['exampleController'].text.trim(),
            );
          }
          success = true;
        }
      } else {
        // CAP NHAT BO THE DA CO
        success = await provider.updateSet(
          setId: currentSetId,
          userId: widget.userId,
          name: _setNameController.text.trim(),
          description: _setDescriptionController.text.trim(),
          isPublic: _isPublic,
        );

        if (success) {
          // 1. Xóa các thẻ đã bị gỡ
          for (var id in _deletedCardIds) {
            await provider.deleteFlashcard(flashcardId: id, userId: widget.userId);
          }

          // 2. Cập nhật thẻ cũ hoặc tạo thẻ mới
          for (var card in _cards) {
            if (card['dbId'] != null) {
              // Cập nhật thẻ đã có
              await provider.updateFlashcard(
                flashcardId: card['dbId'],
                userId: widget.userId,
                front: card['wordController'].text.trim(),
                back: card['meaningController'].text.trim(),
                note: card['exampleController'].text.trim().isEmpty ? null : card['exampleController'].text.trim(),
              );
            } else {
              // Tạo thẻ mới được thêm vào lúc sửa
              await provider.createFlashcard(
                userId: widget.userId,
                setId: currentSetId,
                front: card['wordController'].text.trim(),
                back: card['meaningController'].text.trim(),
                note: card['exampleController'].text.trim().isEmpty ? null : card['exampleController'].text.trim(),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Submit error: $e");
      success = false;
    }

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        _showSnackBar(
          widget.setId == null
              ? 'Đã tạo bộ "${_setNameController.text}" thành công!'
              : 'Đã cập nhật bộ "${_setNameController.text}" thành công!',
          Colors.green,
        );
        Navigator.pop(context, true);
      } else {
        _showSnackBar(
          provider.error ?? 'Có lỗi xảy ra, vui lòng thử lại',
          Colors.red,
        );
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingProvider);
    final isDark = settings.isDarkMode;

    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFF1E88E5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.setId == null ? 'Tạo bộ thẻ' : 'Chỉnh sửa bộ thẻ',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSetInfoForm(isDark),
            const SizedBox(height: 24),
            _buildCardInputSection(isDark),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.setId == null ? 'Tạo bộ thẻ mới' : 'Chỉnh sửa bộ thẻ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.setId == null
                ? 'Tạo bộ thẻ để học từ vựng hiệu quả hơn'
                : 'Cập nhật thông tin bộ thẻ của bạn',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSetInfoForm(bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin bộ thẻ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 16),

          _buildLabel('Tên bộ *', isDark),
          const SizedBox(height: 8),
          _buildTextField(_setNameController, 'VD: Từ vựng JLPT N5', isDark),
          const SizedBox(height: 16),

          _buildLabel('Mô tả bộ', isDark),
          const SizedBox(height: 8),
          _buildTextField(_setDescriptionController, 'Mô tả ngắn gọn về bộ thẻ', isDark,
              maxLines: 2),
          const SizedBox(height: 16),

          // Public / Private Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _isPublic ? Icons.public : Icons.lock,
                    color: const Color(0xFF1E88E5),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isPublic ? 'Công khai (Public)' : 'Riêng tư (Private)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _isPublic,
                onChanged: (value) => setState(() => _isPublic = value),
                activeThumbColor: const Color(0xFF1E88E5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardInputSection(bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thêm thẻ vào bộ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 12),

          // Tab chọn chế độ nhập
          Row(
            children: [
              _buildInputModeButton('single', 'Theo từng thẻ', isDark),
              const SizedBox(width: 12),
              _buildInputModeButton('bulk', 'Nhập nhiều thẻ 1 lúc', isDark),
            ],
          ),
          const SizedBox(height: 20),

          // Nội dung theo chế độ
          _inputMode == 'single' ? _buildSingleCardInput(isDark) : _buildBulkCardInput(isDark),
        ],
      ),
    );
  }

  Widget _buildInputModeButton(String mode, String label, bool isDark) {
    final isActive = _inputMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _inputMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1E88E5) : (isDark ? Colors.white10 : Colors.grey[100]),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? const Color(0xFF1E88E5) : (isDark ? Colors.white10 : Colors.grey[300]!),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : (isDark ? Colors.white60 : Colors.grey[700]),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========== CHE DO NHAP DUNG THE ==========
  Widget _buildSingleCardInput(bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Danh sách thẻ (${_cards.length})',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
            ),
            TextButton.icon(
              onPressed: _addNewCard,
              icon: const Icon(Icons.add_circle, color: Color(0xFF1E88E5), size: 20),
              label: const Text(
                'Thêm thẻ',
                style: TextStyle(color: Color(0xFF1E88E5), fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cards.length,
          itemBuilder: (context, index) {
            final card = _cards[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thẻ ${index + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => _removeCard(card['id']),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildLabel('Từ vựng *', isDark, small: true),
                  const SizedBox(height: 4),
                  _buildSmallTextField(card['wordController'], 'Nhập từ tiếng Nhật', isDark),
                  const SizedBox(height: 10),

                  _buildLabel('Nghĩa *', isDark, small: true),
                  const SizedBox(height: 4),
                  _buildSmallTextField(card['meaningController'], 'Nhập nghĩa', isDark),
                  const SizedBox(height: 10),

                  _buildLabel('Ví dụ', isDark, small: true),
                  const SizedBox(height: 4),
                  _buildSmallTextField(card['exampleController'], 'Nhập câu ví dụ', isDark, maxLines: 2),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ========== CHE DO NHAP NHIEU THE ==========
  Widget _buildBulkCardInput(bool isDark) {
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E88E5).withValues(alpha: 0.1) : Colors.blue[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF1E88E5), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mỗi dòng: từ vựng + nghĩa + ví dụ (cách nhau bằng ký tự phân cách)',
                  style: TextStyle(fontSize: 12, color: Color(0xFF1E88E5)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Ô nhập ký tự phân cách
        Text('Ký tự phân cách:', style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
        const SizedBox(height: 8),

        // Các nút chọn nhanh
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickDelimiters.map((delimiter) {
            final isSelected = _selectedDelimiter == delimiter['value'];
            return FilterChip(
              label: Text(delimiter['label']),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  _setQuickDelimiter(delimiter['value']);
                }
              },
              backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
              selectedColor: const Color(0xFF1E88E5).withValues(alpha: 0.2),
              checkmarkColor: const Color(0xFF1E88E5),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF1E88E5) : (isDark ? Colors.white70 : Colors.grey[700]),
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 8),

        // Ô nhập tùy chỉnh
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _delimiterController,
                maxLength: 3,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Nhập ký tự phân cách (VD: , ; | /)',
                  hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400], fontSize: 12),
                  counterText: '',
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _selectedDelimiter == '\t' ? 'Hiện tại: Tab' : 'Hiện tại: $_selectedDelimiter',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Text('Dữ liệu thẻ:', style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
        const SizedBox(height: 8),

        TextField(
          controller: _bulkController,
          maxLines: 8,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: _getExampleText(),
            hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.grey[400], fontSize: 12),
            filled: true,
            fillColor: isDark ? Colors.white10 : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _parseBulkText,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Tạo thẻ từ dữ liệu'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _clearBulk,
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white70 : Colors.grey[600],
                side: BorderSide(color: isDark ? Colors.white24 : Colors.grey[400]!),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Xóa'),
            ),
          ],
        ),

        if (_bulkPreview.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.green.withValues(alpha: 0.1) : Colors.green[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? Colors.green.withValues(alpha: 0.2) : Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Đã tạo thẻ thành công!',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _bulkPreview,
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getExampleText() {
    if (_selectedDelimiter == '\t') {
      return '食べる\tăn\t毎日ご飯を食べる\n飲む\tuống\t水を飲む\n行く\tđi\t学校へ行く';
    } else if (_selectedDelimiter == ',') {
      return '食べる,ăn,毎日ご飯を食べる\n飲む,uống,水を飲む\n行く,đi,学校へ行く';
    } else if (_selectedDelimiter == ';') {
      return '食べる;ăn;毎日ご飯を食べる\n飲む;uống;水を飲む\n行く;đi;学校へ行く';
    } else if (_selectedDelimiter == ' ') {
      return '食べる ăn 毎日ご飯を食べる\n飲む uống 水を飲む\n行く đi 学校へ行く';
    } else {
      return '食べる${_selectedDelimiter}ăn${_selectedDelimiter}毎日ご飯 को食べる\n飲む${_selectedDelimiter}uống${_selectedDelimiter}水を飲む\n行く${_selectedDelimiter}đi${_selectedDelimiter}学校へ行く';
    }
  }

  // ========== BUTTON TAO/SUA BO ==========
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitSet,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          widget.setId == null ? 'Tạo bộ thẻ' : 'Cập nhật bộ thẻ',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ========== HELPER WIDGETS ==========
  Widget _buildLabel(String text, bool isDark, {bool small = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: small ? 12 : 14,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white60 : Colors.grey[700],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool isDark,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.grey[400]),
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildSmallTextField(TextEditingController controller, String hint, bool isDark,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
