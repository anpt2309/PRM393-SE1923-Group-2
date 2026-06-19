import 'package:flutter/material.dart';
import '../../data/models/exam.dart';
import '../../viewmodels/exam_list_viewmodel.dart';
import 'exam_detail_screen.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  // ViewModel quản lý toàn bộ logic & trạng thái
  final ExamListViewModel _viewModel = ExamListViewModel();

  // Styling Constants
  static const Color cobaltBlue = Color(0xFF0D47A1);
  static const Color energeticOrange = Color(0xFFFF9800);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);

  final List<String> _types = ['Tất cả', 'JLPT', 'Kanji', 'Ngữ pháp', 'Từ vựng'];
  final List<String> _jlptLevels = ['Tất cả', 'N5', 'N4', 'N3', 'N2', 'N1'];
  final List<String> _difficulties = ['Tất cả', 'Dễ', 'Trung bình', 'Khó'];

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.loadExams();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // Getters để các hàm build UI gọi dữ liệu qua ViewModel
  List<Exam> get _displayedExams => _viewModel.displayedExams;
  bool get _isLoading => _viewModel.isLoading;
  String? get _errorMessage => _viewModel.errorMessage;
  String get _selectedType => _viewModel.selectedType;
  String get _selectedJLPTLevel => _viewModel.selectedJLPTLevel;
  String get _selectedDifficulty => _viewModel.selectedDifficulty;
  String get _sortBy => _viewModel.sortBy;
  TextEditingController get _searchController => _viewModel.searchController;
  TextEditingController get _minPriceController => _viewModel.minPriceController;
  TextEditingController get _maxPriceController => _viewModel.maxPriceController;

  Future<void> _loadExams() => _viewModel.loadExams();

  void _resetFilters() => _viewModel.resetFilters();

  String _formatPrice(double price) {
    if (price == 0.0) return 'Miễn phí';
    final value = price.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = value.length - 1; i >= 0; i--) {
      buffer.write(value[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return '${buffer.toString().split('').reversed.join('')}đ';
  }

  // Open Bottom Sheet for Filter and Sort settings
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bộ lọc bài thi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: cobaltBlue,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _viewModel.minPriceController.clear();
                              _viewModel.maxPriceController.clear();
                              _viewModel.selectedJLPTLevel = 'Tất cả';
                              _viewModel.selectedDifficulty = 'Tất cả';
                              _viewModel.sortBy = 'price_low_high';
                            });
                            setState(() {}); // update main screen
                            _loadExams();
                          },
                          child: const Text(
                            'Đặt lại',
                            style: TextStyle(color: textLight),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),

                    // JLPT Level Filter (Cấp độ)
                    const Text(
                      'Cấp độ (JLPT Level)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _jlptLevels.map((level) {
                        final isSelected = _selectedJLPTLevel == level;
                        return ChoiceChip(
                          label: Text(level),
                          selected: isSelected,
                          selectedColor: cobaltBlue.withValues(alpha: 0.15),
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                            color: isSelected ? cobaltBlue : textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected ? cobaltBlue : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => _viewModel.selectedJLPTLevel = level);
                              _loadExams();
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Difficulty Filter (Độ khó: Dễ, Trung bình, Khó)
                    const Text(
                      'Độ khó',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _difficulties.map((diff) {
                        final isSelected = _selectedDifficulty == diff;
                        return ChoiceChip(
                          label: Text(diff),
                          selected: isSelected,
                          selectedColor: cobaltBlue.withValues(alpha: 0.15),
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                            color: isSelected ? cobaltBlue : textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected ? cobaltBlue : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => _viewModel.selectedDifficulty = diff);
                              _loadExams();
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Price Range Filter (Loại giá: thanh nhập từ A - B)
                    const Text(
                      'Khoảng giá (VNĐ)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextField(
                              controller: _minPriceController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14, color: textDark),
                              decoration: const InputDecoration(
                                hintText: 'Giá từ (A)',
                                hintStyle: TextStyle(color: textLight, fontSize: 13),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              onChanged: (value) {
                                setState(() {});
                                _loadExams();
                              },
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text('—', style: TextStyle(color: textLight)),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextField(
                              controller: _maxPriceController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 14, color: textDark),
                              decoration: const InputDecoration(
                                hintText: 'Giá đến (B)',
                                hintStyle: TextStyle(color: textLight, fontSize: 13),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              onChanged: (value) {
                                setState(() {});
                                _loadExams();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sorting Options (Duy nhất 2 mục: từ thấp đến cao và từ cao đến thấp)
                    const Text(
                      'Sắp xếp theo giá',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('Giá từ thấp đến cao', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            value: 'price_low_high',
                            groupValue: _sortBy,
                            activeColor: cobaltBlue,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            onChanged: (value) {
                              setModalState(() => _viewModel.sortBy = value!);
                              _loadExams();
                            },
                          ),
                          const Divider(height: 1, thickness: 1),
                          RadioListTile<String>(
                            title: const Text('Giá từ cao đến thấp', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            value: 'price_high_low',
                            groupValue: _sortBy,
                            activeColor: cobaltBlue,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            onChanged: (value) {
                              setModalState(() => _viewModel.sortBy = value!);
                              _loadExams();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: energeticOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Áp dụng bộ lọc',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pure white background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Đề thi & Luyện tập',
          style: TextStyle(
            color: cobaltBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: cobaltBlue),
            tooltip: 'Làm mới',
            onPressed: _resetFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar & Filter Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: textDark, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm tên bài thi...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: const Icon(Icons.search, color: textLight),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: textLight),
                                onPressed: () {
                                  _searchController.clear();
                                  _loadExams();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (val) => _loadExams(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Filter icon button
                Material(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _showFilterBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.filter_list, color: cobaltBlue),
                          if (_selectedJLPTLevel != 'Tất cả' ||
                              _selectedDifficulty != 'Tất cả' ||
                              _minPriceController.text.isNotEmpty ||
                              _maxPriceController.text.isNotEmpty)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: energeticOrange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Horizontal Type Filters (e.g. JLPT, Kanji, Ngữ pháp, Từ vựng)
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _types.length,
              itemBuilder: (context, index) {
                final type = _types[index];
                final isSelected = _selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    selectedColor: cobaltBlue,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : textLight,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? cobaltBlue : Colors.grey.shade300,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _viewModel.selectedType = type;
                        });
                        _loadExams();
                      }
                    },
                  ),
                );
              },
            ),
          ),

          // Active Filters Display Bar
          if (_selectedJLPTLevel != 'Tất cả' ||
              _selectedDifficulty != 'Tất cả' ||
              _minPriceController.text.isNotEmpty ||
              _maxPriceController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  const Text(
                    'Đang lọc: ',
                    style: TextStyle(fontSize: 12, color: textLight, fontStyle: FontStyle.italic),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_selectedJLPTLevel != 'Tất cả')
                            _buildFilterIndicator(_selectedJLPTLevel, () {
                              setState(() => _viewModel.selectedJLPTLevel = 'Tất cả');
                              _loadExams();
                            }),
                          if (_selectedDifficulty != 'Tất cả')
                            _buildFilterIndicator('Độ khó: $_selectedDifficulty', () {
                              setState(() => _viewModel.selectedDifficulty = 'Tất cả');
                              _loadExams();
                            }),
                          if (_minPriceController.text.isNotEmpty)
                            _buildFilterIndicator('Min: ${_minPriceController.text}đ', () {
                              setState(() => _minPriceController.clear());
                              _loadExams();
                            }),
                          if (_maxPriceController.text.isNotEmpty)
                            _buildFilterIndicator('Max: ${_maxPriceController.text}đ', () {
                              setState(() => _maxPriceController.clear());
                              _loadExams();
                            }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 3. Main List of Exams
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: cobaltBlue))
                : _errorMessage != null
                    ? _buildErrorState()
                    : _displayedExams.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _displayedExams.length,
                            itemBuilder: (context, index) {
                              final exam = _displayedExams[index];
                              return _buildExamCard(exam);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Không thể tải dữ liệu từ máy chủ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Vui lòng kiểm tra kết nối mạng hoặc trạng thái backend.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: textLight),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadExams,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Thử lại', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: cobaltBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterIndicator(String text, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(fontSize: 11, color: textDark)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 12, color: textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy bài thi phù hợp',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy thử thay đổi từ khoá hoặc xoá bớt các bộ lọc.',
            style: TextStyle(fontSize: 14, color: textLight),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: cobaltBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đặt lại bộ lọc'),
          )
        ],
      ),
    );
  }

  Widget _buildExamCard(Exam exam) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExamDetailScreen(exam: exam),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge line & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Level Badges & Type
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cobaltBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          exam.jlptLevel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: cobaltBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: energeticOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          exam.difficulty,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: energeticOrange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          exam.type,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Price tag
                  Text(
                    _formatPrice(exam.price),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: exam.isFree ? Colors.green.shade700 : energeticOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                exam.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 6),

              // Description (max lines 2)
              Text(
                exam.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: textLight,
                ),
              ),
              const SizedBox(height: 14),

              // Stats (Duration, Questions, Enrolled)
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: textLight),
                  const SizedBox(width: 4),
                  Text(
                    '${exam.durationMinutes} phút',
                    style: const TextStyle(fontSize: 12, color: textLight),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.help_outline, size: 14, color: textLight),
                  const SizedBox(width: 4),
                  Text(
                    '${exam.questionsCount} câu hỏi',
                    style: const TextStyle(fontSize: 12, color: textLight),
                  ),
                  const Spacer(),
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    exam.rating.toString(),
                    style: const TextStyle(fontSize: 12, color: textDark, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.people_outline, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 2),
                  Text(
                    exam.enrolledCount >= 1000
                        ? '${(exam.enrolledCount / 1000).toStringAsFixed(1)}k'
                        : '${exam.enrolledCount}',
                    style: const TextStyle(fontSize: 12, color: textLight),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
