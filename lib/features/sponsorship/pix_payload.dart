/// Gera o "Pix copia e cola" (BR Code estático) para uma chave Pix.
/// O app não processa o pagamento: o apoiador paga no app do próprio banco.
String buildPixPayload({
  required String key,
  required String name,
  required String city,
  double? amount,
}) {
  String f(String id, String value) =>
      '$id${value.length.toString().padLeft(2, '0')}$value';

  final account = f('00', 'br.gov.bcb.pix') + f('01', key.trim());
  final body = StringBuffer()
    ..write(f('00', '01'))
    ..write(f('01', '11'))
    ..write(f('26', account))
    ..write(f('52', '0000'))
    ..write(f('53', '986'));
  if (amount != null && amount > 0) {
    body.write(f('54', amount.toStringAsFixed(2)));
  }
  body
    ..write(f('58', 'BR'))
    ..write(f('59', _clean(name, 25, 'KISS ME')))
    ..write(f('60', _clean(city, 15, 'BRASIL')))
    ..write(f('62', f('05', '***')))
    ..write('6304');
  final text = body.toString();
  return text + _crc16(text);
}

String _clean(String v, int max, String fallback) {
  const from = 'ÁÀÂÃÄáàâãäÉÈÊËéèêëÍÌÎÏíìîïÓÒÔÕÖóòôõöÚÙÛÜúùûüÇçÑñ';
  const to = 'AAAAAaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUUuuuuCcNn';
  var out = v;
  for (var i = 0; i < from.length; i++) {
    out = out.replaceAll(from[i], to[i]);
  }
  out = out.replaceAll(RegExp(r'[^A-Za-z0-9 ]'), '').trim().toUpperCase();
  if (out.isEmpty) return fallback;
  return out.length > max ? out.substring(0, max).trim() : out;
}

String _crc16(String data) {
  var crc = 0xFFFF;
  for (final unit in data.codeUnits) {
    crc ^= unit << 8;
    for (var i = 0; i < 8; i++) {
      crc = (crc & 0x8000) != 0 ? ((crc << 1) ^ 0x1021) : (crc << 1);
      crc &= 0xFFFF;
    }
  }
  return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
}
