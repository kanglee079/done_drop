import 'package:flutter_test/flutter_test.dart';

import 'package:done_drop/app/presentation/qr/qr_invite_parser.dart';

void main() {
  group('parseQrInvite', () {
    test('parses custom DoneDrop invite URI', () {
      final invite = parseQrInvite(
        'donedrop://add?uid=fcEMq1iGeLT41xi9Fl8fsJ1ZZnm2&code=ab12cd&name=Codex%20Buddy',
      );

      expect(invite, isNotNull);
      expect(invite!.uid, 'fcEMq1iGeLT41xi9Fl8fsJ1ZZnm2');
      expect(invite.code, 'AB12CD');
      expect(invite.name, 'Codex Buddy');
    });

    test('parses raw short code', () {
      final invite = parseQrInvite('ab-12 cd');

      expect(invite, isNotNull);
      expect(invite!.uid, isNull);
      expect(invite.code, 'AB12CD');
    });

    test('parses raw uid', () {
      final invite = parseQrInvite('1ewhcTJs6UTUoFXSEKihGmbj1Yn1');

      expect(invite, isNotNull);
      expect(invite!.uid, '1ewhcTJs6UTUoFXSEKihGmbj1Yn1');
      expect(invite.code, isNull);
    });

    test('rejects malformed payloads', () {
      expect(parseQrInvite(''), isNull);
      expect(parseQrInvite('not-a-valid-invite'), isNull);
      expect(parseQrInvite('donedrop://add?name=OnlyName'), isNull);
    });
  });
}
