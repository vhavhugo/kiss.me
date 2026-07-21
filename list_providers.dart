import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  print('--- OAuthProvider Names ---');
  // Usando reflexão simples/iteração manual para evitar crash de compilação FFI
  OAuthProvider.values.forEach((v) => print(v.name));
}
