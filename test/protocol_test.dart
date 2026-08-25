import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:octo_note/core/sync/protocol.dart';

void main() {
  group('FrameCodec', () {
    test('编码-解码往返', () {
      final codec = FrameCodec();
      final msg = SyncMessage.hello(deviceId: 'dev-a', deviceName: '手机', cursors: {
        'accounts': 1000,
        'courses': 2000,
      });

      final frame = codec.encode(msg);
      final decoded = codec.decoder().push(frame);

      expect(decoded, hasLength(1));
      expect(decoded.first.type, 'hello');
      expect(decoded.first.deviceId, 'dev-a');
      expect(decoded.first.deviceName, '手机');
      expect(decoded.first.cursors, {'accounts': 1000, 'courses': 2000});
    });

    test('粘包：一包三条消息', () {
      final codec = FrameCodec();
      final decoder = codec.decoder();
      final bytes = BytesBuilder();
      for (var i = 0; i < 3; i++) {
        bytes.add(codec.encode(SyncMessage.data(
          deviceId: 'dev-a',
          table: 'accounts',
          rows: [
            {'uuid': 'u$i', 'amount': i, 'updatedAt': 100 + i}
          ],
        )));
      }

      final msgs = decoder.push(bytes.toBytes());
      expect(msgs, hasLength(3));
      expect(msgs.map((m) => m.rows.first['uuid']), ['u0', 'u1', 'u2']);
    });

    test('半包：逐字节喂入', () {
      final codec = FrameCodec();
      final decoder = codec.decoder();
      final frame = codec.encode(SyncMessage.end('dev-a'));

      final all = <SyncMessage>[];
      for (final b in frame) {
        all.addAll(decoder.push(Uint8List.fromList([b])));
      }
      expect(all, hasLength(1));
      expect(all.first.type, 'end');
      expect(all.first.deviceId, 'dev-a');
    });

    test('data 消息行内容往返', () {
      final codec = FrameCodec();
      final row = {
        'uuid': 'row-1',
        'amount': 12.5,
        'type': 'expense',
        'category': '餐饮',
        'note': null,
        'occurredAt': 1700000000000,
        'updatedAt': 1700000000000,
        'deviceId': 'dev-a',
        'isDeleted': false,
      };
      final msg = SyncMessage.data(
          deviceId: 'dev-a', table: 'accounts', rows: [row]);

      final decoded = codec.decoder().push(codec.encode(msg));
      expect(decoded.first.rows.first, row);
    });

    test('超大帧抛 ProtocolException', () {
      final codec = FrameCodec();
      final decoder = codec.decoder();
      final header = ByteData(4)..setUint32(0, 100 * 1024 * 1024, Endian.big);

      expect(() => decoder.push(header.buffer.asUint8List()),
          throwsA(isA<ProtocolException>()));
    });
  });
}
