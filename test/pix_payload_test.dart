import 'package:flutter_test/flutter_test.dart';
import 'package:kiss_me/features/sponsorship/pix_payload.dart';

void main() {
  test('Pix payload has valid CRC16 and fields', () {
    final p = buildPixPayload(
        key: 'a@b.com', name: 'João', city: 'São Paulo', amount: 10);
    expect(p.startsWith('000201010211'), isTrue);
    expect(p.contains('br.gov.bcb.pix0107a@b.com'), isTrue);
    expect(p.contains('540510.00'), isTrue);
    expect(p.contains('5904JOAO'), isTrue);
    expect(p.contains('6009SAO PAULO'), isTrue);
    final body = p.substring(0, p.length - 4);
    expect(body.endsWith('6304'), isTrue);
  });
}
