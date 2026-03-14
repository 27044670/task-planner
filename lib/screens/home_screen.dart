import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import '../models/task_cell.dart';
import '../database/database_helper.dart';
import '../widgets/color_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _rowCount = 50;
  final int _colCount = 14; // 1列任务名称 + 13列日期(约2周)
  
  late List<List<TaskCell>> _cells;
  String _selectedColor = 'red';
  bool _isLoading = true;
  
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initCells();
  }

  Future<void> _initCells() async {
    _cells = List.generate(
      _rowCount,
      (row) => List.generate(
        _colCount,
        (col) => TaskCell(
          id: 0,
          rowIndex: row,
          colIndex: col,
        ),
      ),
    );

    // 从数据库加载数据
    final savedCells = await DatabaseHelper.instance.getAllCells();
    for (var cell in savedCells) {
      if (cell.rowIndex < _rowCount && cell.colIndex < _colCount) {
        _cells[cell.rowIndex][cell.colIndex] = cell;
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  // 获取日期列表（只显示工作日）
  List<DateTime> _getWorkDays() {
    final List<DateTime> workDays = [];
    final today = DateTime.now();
    var current = today;
    
    while (workDays.length < _colCount - 1) {
      // 跳过周末 (6=周六, 7=周日)
      if (current.weekday != DateTime.saturday && 
          current.weekday != DateTime.sunday) {
        workDays.add(current);
      }
      current = current.add(const Duration(days: 1));
    }
    
    return workDays;
  }

  // 保存单元格
  Future<void> _saveCell(int row, int col) async {
    final cell = _cells[row][col];
    if (cell.content.isNotEmpty || cell.color.isNotEmpty) {
      await DatabaseHelper.instance.saveCell(cell);
    }
  }

  // 更新任务名称
  Future<void> _updateTaskName(int row, String value) async {
    setState(() {
      _cells[row][0] = _cells[row][0].copyWith(
        content: value,
        updatedAt: DateTime.now(),
      );
    });
    await _saveCell(row, 0);
  }

  // 切换单元格颜色
  Future<void> _toggleCellColor(int row, int col) async {
    setState(() {
      final currentColor = _cells[row][col].color;
      String newColor = '';
      
      if (currentColor.isEmpty) {
        newColor = _selectedColor;
      } else if (currentColor == _selectedColor) {
        // 再次点击相同颜色则清除
        newColor = '';
      } else {
        // 切换到新选择的颜色
        newColor = _selectedColor;
      }
      
      _cells[row][col] = _cells[row][col].copyWith(
        color: newColor,
        updatedAt: DateTime.now(),
      );
    });
    await _saveCell(row, col);
  }

  // 导出CSV
  Future<void> _exportToCSV() async {
    try {
      final workDays = _getWorkDays();
      final dateFormat = DateFormat('M/d');
      
      // 构建CSV数据
      final List<List<dynamic>> csvData = [];
      
      // 标题行
      final header = ['任务名称'];
      for (var day in workDays) {
        final weekday = _getWeekdayName(day.weekday);
        header.add('$weekday ${dateFormat.format(day)}');
      }
      csvData.add(header);
      
      // 数据行
      for (int row = 0; row < _rowCount; row++) {
        final rowData = <dynamic>[];
        rowData.add(_cells[row][0].content);
        for (int col = 1; col < _colCount; col++) {
          final cell = _cells[row][col];
          if (cell.color.isNotEmpty) {
            rowData.add('[${cell.color}] ${cell.content}');
          } else {
            rowData.add(cell.content);
          }
        }
        csvData.add(rowData);
      }
      
      final csv = const ListToCsvConverter().convert(csvData);
      
      // 分享文件
      await Share.share(
        csv!,
        subject: '任务规划表_${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('导出成功！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  // 清空所有数据
  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有数据吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.clearAll();
      await _initCells();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已清空所有数据')),
        );
      }
    }
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[weekday];
  }

  @override
  Widget build(BuildContext context) {
    final workDays = _getWorkDays();
    final dateFormat = DateFormat('M/d');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('任务规划表'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            tooltip: '选择颜色',
            onPressed: () async {
              final color = await showColorPicker(context, _selectedColor);
              if (color != null) {
                setState(() {
                  _selectedColor = color;
                });
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _exportToCSV();
              } else if (value == 'clear') {
                _clearAllData();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('导出CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red),
                    SizedBox(width: 8),
                    Text('清空数据', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 当前颜色提示
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey.shade200,
                  child: Row(
                    children: [
                      const Text('当前颜色: '),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _selectedColor.isEmpty 
                              ? Colors.transparent
                              : ColorPickerBottomSheet.getColorValue(_selectedColor),
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedColor.isEmpty ? '无' : _selectedColor,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '点击日期单元格填充颜色',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // 表格
                Expanded(
                  child: Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 80 + 70.0 * (_colCount - 1),
                        child: ListView.builder(
                          controller: _verticalScrollController,
                          itemCount: _rowCount + 1, // +1 for header
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // 标题行
                              return _buildHeaderRow(workDays, dateFormat);
                            }
                            return _buildDataRow(index - 1, workDays);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeaderRow(List<DateTime> workDays, DateFormat dateFormat) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade400, width: 2),
        ),
      ),
      child: Row(
        children: [
          // 任务名称列标题
          _buildHeaderCell('任务名称', width: 80),
          // 日期列标题
          ...workDays.map((day) {
            final weekday = _getWeekdayName(day.weekday);
            return _buildHeaderCell(
              '$weekday\n${dateFormat.format(day)}',
              width: 70,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(int row, List<DateTime> workDays) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: row % 2 == 0 ? Colors.white : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // 任务名称输入框
          _buildTaskNameCell(row),
          // 日期单元格
          ...List.generate(workDays.length, (col) {
            return _buildDateCell(row, col + 1);
          }),
        ],
      ),
    );
  }

  Widget _buildTaskNameCell(int row) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          right: BorderSide(color: Colors.grey.shade300, width: 2),
        ),
      ),
      child: TextField(
        controller: TextEditingController(text: _cells[row][0].content)
          ..selection = TextSelection.collapsed(
            offset: _cells[row][0].content.length,
          ),
        onChanged: (value) => _updateTaskName(row, value),
        style: const TextStyle(fontSize: 13),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          isDense: true,
        ),
        maxLines: 1,
      ),
    );
  }

  Widget _buildDateCell(int row, int col) {
    final cell = _cells[row][col];
    final hasColor = cell.color.isNotEmpty;
    final backgroundColor = hasColor
        ? ColorPickerBottomSheet.getColorValue(cell.color).withOpacity(0.3)
        : Colors.transparent;

    return GestureDetector(
      onTap: () => _toggleCellColor(row, col),
      child: Container(
        width: 70,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            right: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Center(
          child: hasColor
              ? Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: ColorPickerBottomSheet.getColorValue(cell.color),
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }
}
