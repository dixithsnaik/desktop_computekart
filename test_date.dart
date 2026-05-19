void main() {
  var str = "2026-05-18 16:48:00+00";
  var dt = DateTime.tryParse(str);
  print('Parsed: $dt');
}
