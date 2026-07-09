// lib/vocab/create_set_screen.dart
import 'package:flutter/material.dart';

class CreateSetScreen extends StatefulWidget {
  const CreateSetScreen({super.key});

  @override
  State<CreateSetScreen> createState() => _CreateSetScreenState();
}

class _CreateSetScreenState extends State<CreateSetScreen> {
  // Thông tin bộ thẻ
  final TextEditingController _setNameController = TextEditingController();
  final TextEditingController _setDescriptionController = TextEditingController();
  bool _isPublic = true;

  // Chế độ nhập thẻ: 'single' hoặc 'bulk'
  String _inputMode = 'single';

  // Dữ liệu cho chế độ nhập từng thẻ
  List<Map<String, dynamic>> _cards = [];

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

  @override
  void initState() {
    super.initState();
    _addNewCard();
    _delimiterController.addListener(_onDelimiterChanged);
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
      _showSnackBar('Bo phai co it nhat mot the', Colors.orange);
      return;
    }

    final cardToRemove = _cards.firstWhere((card) => card['id'] == id);
    cardToRemove['wordController']?.dispose();
    cardToRemove['meaningController']?.dispose();
    cardToRemove['exampleController']?.dispose();

    setState(() {
      _cards.removeWhere((card) => card['id'] == id);
    });
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
      _showSnackBar('Vui long nhap du lieu', Colors.orange);
      return;
    }

    String delimiter = _selectedDelimiter;
    if (delimiter.isEmpty) {
      delimiter = '\t';
    }

    // Xu ly ky tu dac biet trong regex
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
      _showSnackBar('Khong tim thay du lieu hop le. Kiem tra lai ky tu phan cach!', Colors.red);
      return;
    }

    // Xoa cac card cu va them card moi tu bulk
    for (var card in _cards) {
      card['wordController']?.dispose();
      card['meaningController']?.dispose();
      card['exampleController']?.dispose();
    }

    setState(() {
      _cards.clear();
      for (var card in parsedCards) {
        _cards.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'wordController': TextEditingController(text: card['word']),
          'meaningController': TextEditingController(text: card['meaning']),
          'exampleController': TextEditingController(text: card['example']),
        });
      }
    });

    _showSnackBar('Da them ${parsedCards.length} the tu vung!', Colors.green);

    // Tao preview
    String preview = '';
    for (var i = 0; i < parsedCards.length && i < 5; i++) {
      preview += '${i + 1}. ${parsedCards[i]['word']} -> ${parsedCards[i]['meaning']}\n';
    }
    if (parsedCards.length > 5) {
      preview += '... va ${parsedCards.length - 5} the khac';
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

  // ========== TAO BO THE ==========
  void _createSet() {
    if (_setNameController.text.trim().isEmpty) {
      _showSnackBar('Vui long nhap ten bo', Colors.red);
      return;
    }

    final invalidCards = _cards.where((card) =>
    card['wordController'].text.trim().isEmpty ||
        card['meaningController'].text.trim().isEmpty);

    if (invalidCards.isNotEmpty) {
      _showSnackBar('Tat ca the phai co tu va nghia', Colors.red);
      return;
    }

    // Lay du lieu cac the
    final List<Map<String, String>> cardData = [];
    for (var card in _cards) {
      cardData.add({
        'word': card['wordController'].text.trim(),
        'meaning': card['meaningController'].text.trim(),
        'example': card['exampleController'].text.trim(),
      });
    }

    debugPrint('=== TAO BO THE ===');
    debugPrint('Ten bo: ${_setNameController.text}');
    debugPrint('Mo ta: ${_setDescriptionController.text}');
    debugPrint('Che do: ${_isPublic ? "Public" : "Private"}');
    debugPrint('So luong the: ${cardData.length}');

    _showSnackBar('Da tao bo "${_setNameController.text}" thanh cong!', Colors.green);

    // Reset form
    _setNameController.clear();
    _setDescriptionController.clear();
    setState(() {
      _isPublic = true;
      for (var card in _cards) {
        card['wordController']?.dispose();
        card['meaningController']?.dispose();
        card['exampleController']?.dispose();
      }
      _cards = [];
      _addNewCard();
      _bulkController.clear();
      _bulkPreview = '';
    });
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Tao bo the',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSetInfoForm(),
            const SizedBox(height: 24),
            _buildCardInputSection(),
            const SizedBox(height: 24),
            _buildCreateButton(),
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tao bo the moi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tao bo the de hoc tu vung hieu qua hon',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSetInfoForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thong tin bo the',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildLabel('Ten bo *'),
          const SizedBox(height: 8),
          _buildTextField(_setNameController, 'VD: Tu vung JLPT N5'),
          const SizedBox(height: 16),

          _buildLabel('Mo ta bo'),
          const SizedBox(height: 8),
          _buildTextField(_setDescriptionController, 'Mo ta ngan gon ve bo the',
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
                    _isPublic ? 'Cong khai (Public)' : 'Rieng tu (Private)',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _isPublic,
                onChanged: (value) => setState(() => _isPublic = value),
                activeColor: const Color(0xFF1E88E5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Them the vao bo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Tab chọn chế độ nhập
          Row(
            children: [
              _buildInputModeButton('single', 'Theo tung the'),
              const SizedBox(width: 12),
              _buildInputModeButton('bulk', 'Nhap nhieu the 1 luc'),
            ],
          ),
          const SizedBox(height: 20),

          // Nội dung theo chế độ
          _inputMode == 'single' ? _buildSingleCardInput() : _buildBulkCardInput(),
        ],
      ),
    );
  }

  Widget _buildInputModeButton(String mode, String label) {
    final isActive = _inputMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _inputMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1E88E5) : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? const Color(0xFF1E88E5) : Colors.grey[300]!,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[700],
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
  Widget _buildSingleCardInput() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Danh sach the (${_cards.length})',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            TextButton.icon(
              onPressed: _addNewCard,
              icon: const Icon(Icons.add_circle, color: Color(0xFF1E88E5), size: 20),
              label: const Text(
                'Them the',
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
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'The ${index + 1}',
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

                  _buildLabel('Tu vung *', small: true),
                  const SizedBox(height: 4),
                  _buildSmallTextField(card['wordController'], 'Nhap tu tieng Nhat'),
                  const SizedBox(height: 10),

                  _buildLabel('Nghia *', small: true),
                  const SizedBox(height: 4),
                  _buildSmallTextField(card['meaningController'], 'Nhap nghia'),
                  const SizedBox(height: 10),

                  _buildLabel('Vi du', small: true),
                  const SizedBox(height: 4),
                  _buildSmallTextField(card['exampleController'], 'Nhap cau vi du', maxLines: 2),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ========== CHE DO NHAP NHIEU THE ==========
  Widget _buildBulkCardInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF1E88E5), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Moi dong: tu vung + nghia + vi du (cach nhau bang ky tu phan cach)',
                  style: TextStyle(fontSize: 12, color: Color(0xFF1E88E5)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Ô nhập ký tự phân cách
        const Text('Ky tu phan cach:', style: TextStyle(fontWeight: FontWeight.w500)),
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
              backgroundColor: Colors.grey[100],
              selectedColor: const Color(0xFF1E88E5).withOpacity(0.2),
              checkmarkColor: const Color(0xFF1E88E5),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF1E88E5) : Colors.grey[700],
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
                decoration: InputDecoration(
                  hintText: 'Nhap ky tu phan cach (VD: , ; | /)',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _selectedDelimiter == '\t' ? 'Hien tai: Tab' : 'Hien tai: $_selectedDelimiter',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        const Text('Du lieu the:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),

        TextField(
          controller: _bulkController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: _getExampleText(),
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
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
                child: const Text('Tao the tu du lieu'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _clearBulk,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Xoa'),
            ),
          ],
        ),

        if (_bulkPreview.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Da tao the thanh cong!',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _bulkPreview,
                  style: const TextStyle(fontSize: 12),
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
      return '食べる${_selectedDelimiter}ăn${_selectedDelimiter}毎日ご飯を食べる\n飲む${_selectedDelimiter}uống${_selectedDelimiter}水を飲む\n行く${_selectedDelimiter}đi${_selectedDelimiter}学校へ行く';
    }
  }

  // ========== BUTTON TAO BO ==========
  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _createSet,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Tao bo the',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ========== HELPER WIDGETS ==========
  Widget _buildLabel(String text, {bool small = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: small ? 12 : 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildSmallTextField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}