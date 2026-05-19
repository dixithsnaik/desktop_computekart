/// Port of React's `helper.js` — time range utilities.
class Helpers {
  Helpers._();

  static String epochToReadable(dynamic epoch) {
    final cleanEpoch = int.tryParse(epoch.toString());
    if (cleanEpoch == null) return '-';
    final dt = DateTime.fromMillisecondsSinceEpoch(cleanEpoch * 1000);
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} ${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}';
  }

  static Map<String, String> getReadableTimeRange(String? range) {
    final normalized = normalizeTimeRange(range);
    final parts = normalized.split('|');
    return {
      'startReadable': epochToReadable(parts[0]),
      'endReadable': epochToReadable(parts[1]),
    };
  }

  static int readableToEpoch(String readable) {
    final date = DateTime.parse(readable);
    return date.millisecondsSinceEpoch ~/ 1000;
  }

  static bool isEpochFormat(String value) {
    final num = int.tryParse(value);
    if (num == null) return false;
    return num.toString().length >= 10;
  }

  static int _normalizeEpoch(String value) {
    var epoch = int.parse(value);
    if (epoch > 100000000000) {
      epoch = epoch ~/ 1000;
    }
    return epoch;
  }

  static String normalizeTimeRange(String? timeRangeString) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (timeRangeString == null || timeRangeString.isEmpty) {
      return '${now - 3600}|$now';
    }

    final parts = timeRangeString.split('|');
    if (parts.length != 2) {
      return '${now - 3600}|$now';
    }

    int startEpoch;
    int endEpoch;

    if (isEpochFormat(parts[0])) {
      startEpoch = _normalizeEpoch(parts[0]);
    } else {
      final minutes = int.tryParse(parts[0]) ?? 60;
      startEpoch = now - minutes * 60;
    }

    if (isEpochFormat(parts[1])) {
      endEpoch = _normalizeEpoch(parts[1]);
    } else {
      final minutes = int.tryParse(parts[1]) ?? 0;
      endEpoch = minutes == 0 ? now : now - minutes * 60;
    }

    if (startEpoch > endEpoch) {
      final temp = startEpoch;
      startEpoch = endEpoch;
      endEpoch = temp;
    }

    return '$startEpoch|$endEpoch';
  }

  static String getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
