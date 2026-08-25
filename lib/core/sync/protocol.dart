import 'dart:convert';
import 'dart:typed_data';

/// 同步协议消息。
///
/// 会话流程：
///   连接建立 → 双方各发 [hello]（含 device_id/名称/各表游标）
///   → 各自按对方游标发送 [data]（分批的表变更行）
///   → 发完发 [end]；收到对方 end 且自己发完 → 会话结束
///   → 双方把对端的游标更新为本会话起始时刻（幂等，重连重跑无损）
class SyncMessage {
  final String type; // hello | data | end
  final String deviceId;
  final String deviceName;

  /// hello：各表游标 {表名: 上次同步时间戳ms}
  final Map<String, int> cursors;

  /// data：表名 + 变更行
  final String? table;
  final List<Map<String, dynamic>> rows;

  const SyncMessage({
    required this.type,
    this.deviceId = '',
    this.deviceName = '',
    this.cursors = const {},
    this.table,
    this.rows = const [],
  });

  factory SyncMessage.hello({
    required String deviceId,
    required String deviceName,
    required Map<String, int> cursors,
  }) =>
      SyncMessage(
        type: 'hello',
        deviceId: deviceId,
        deviceName: deviceName,
        cursors: cursors,
      );

  factory SyncMessage.data({
    required String deviceId,
    required String table,
    required List<Map<String, dynamic>> rows,
  }) =>
      SyncMessage(
          type: 'data', deviceId: deviceId, table: table, rows: rows);

  factory SyncMessage.end(String deviceId) =>
      SyncMessage(type: 'end', deviceId: deviceId);

  factory SyncMessage.fromJson(Json json) => SyncMessage(
        type: json['t'] as String,
        deviceId: json['d'] as String? ?? '',
        deviceName: json['n'] as String? ?? '',
        cursors:
            ((json['c'] as Map<String, dynamic>?) ?? {})
                .map((k, v) => MapEntry(k, (v as num).toInt())),
        table: json['tbl'] as String?,
        rows: ((json['r'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList(),
      );

  Json toJson() => {
        't': type,
        'd': deviceId,
        if (deviceName.isNotEmpty) 'n': deviceName,
        if (cursors.isNotEmpty) 'c': cursors,
        if (table != null) 'tbl': table,
        if (rows.isNotEmpty) 'r': rows,
      };
}

typedef Json = Map<String, dynamic>;

/// 帧编解码：4 字节大端长度 + UTF-8 JSON 载荷。
class FrameCodec {
  static const maxFrameSize = 8 * 1024 * 1024; // 8MB 上限，防异常流

  /// 消息 → 字节帧。
  Uint8List encode(SyncMessage msg) {
    final payload = utf8.encode(jsonEncode(msg.toJson()));
    final header = ByteData(4)..setUint32(0, payload.length, Endian.big);
    return Uint8List.fromList(
        [...header.buffer.asUint8List(), ...payload]);
  }

  /// 增量解码器：把字节流切成完整消息（跨包粘包/半包安全）。
  FrameDecoder decoder() => FrameDecoder();
}

class FrameDecoder {
  final _buffer = BytesBuilder(copy: false);
  int _pending = 0; // 当前帧还差的字节数；0 = 正在读头部

  /// 喂入字节，返回完整解出的消息（可能 0~N 条）。
  List<SyncMessage> push(Uint8List chunk) {
    _buffer.add(chunk);
    final bytes = _buffer.toBytes();
    final out = <SyncMessage>[];
    var pos = 0;

    while (true) {
      if (_pending == 0) {
        if (bytes.length - pos < 4) break;
        final len = ByteData.sublistView(bytes, pos, pos + 4)
            .getUint32(0, Endian.big);
        if (len > FrameCodec.maxFrameSize) {
          throw ProtocolException('frame too large: $len');
        }
        _pending = len;
        pos += 4;
      }
      if (bytes.length - pos < _pending) break;
      final payload = utf8.decode(bytes.sublist(pos, pos + _pending));
      pos += _pending;
      _pending = 0;
      out.add(SyncMessage.fromJson(
          jsonDecode(payload) as Map<String, dynamic>));
    }

    _buffer.clear();
    if (pos < bytes.length) _buffer.add(bytes.sublist(pos));
    return out;
  }
}

class ProtocolException implements Exception {
  final String message;
  ProtocolException(this.message);
  @override
  String toString() => 'ProtocolException: $message';
}
