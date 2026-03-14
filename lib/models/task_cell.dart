/// 任务单元格模型
class TaskCell {
  final int id;
  final int rowIndex;
  final int colIndex;
  final String content;
  final String color;
  final DateTime updatedAt;

  TaskCell({
    required this.id,
    required this.rowIndex,
    required this.colIndex,
    this.content = '',
    this.color = '',
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rowIndex': rowIndex,
      'colIndex': colIndex,
      'content': content,
      'color': color,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TaskCell.fromMap(Map<String, dynamic> map) {
    return TaskCell(
      id: map['id'] as int,
      rowIndex: map['rowIndex'] as int,
      colIndex: map['colIndex'] as int,
      content: map['content'] as String? ?? '',
      color: map['color'] as String? ?? '',
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  TaskCell copyWith({
    int? id,
    int? rowIndex,
    int? colIndex,
    String? content,
    String? color,
    DateTime? updatedAt,
  }) {
    return TaskCell(
      id: id ?? this.id,
      rowIndex: rowIndex ?? this.rowIndex,
      colIndex: colIndex ?? this.colIndex,
      content: content ?? this.content,
      color: color ?? this.color,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
