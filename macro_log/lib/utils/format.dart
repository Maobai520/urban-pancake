/// 通用格式化工具（不依赖 intl，避免本地化数据初始化）

const _weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];

/// yyyy-MM-dd（数据库按天归档的 key）
String dateKeyOf(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

/// 10月21日 星期三
String fmtDate(DateTime d) => '${d.month}月${d.day}日 ${_weekdays[d.weekday - 1]}';

/// 1234 -> 1,234
String fmtInt(int n) {
  final negative = n < 0;
  final digits = n.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return negative ? '-$buffer' : buffer.toString();
}

String _two(int n) => n.toString().padLeft(2, '0');
