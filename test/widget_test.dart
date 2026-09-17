// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kiss_me/main.dart';
import 'package:kiss_me/features/auth/domain/entities/auth_user_entity.dart';
import 'package:kiss_me/features/auth/presentation/providers/auth_provider.dart';
import 'package:kiss_me/features/radar/presentation/providers/radar_search_provider.dart';

class _TestAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return AuthState(
      status: AuthStatus.authenticated,
      isOnline: false,
      user: AuthUserEntity(
        id: 'test-user',
        email: 'test@kissme.app',
        isFirstLogin: false,
      ),
    );
  }
}

class _TestRadarSearchNotifier extends RadarSearchNotifier {
  @override
  RadarSearchState build() {
    return RadarSearchState(
      users: const [],
      currentRadiusKm: 0.0,
      isSearching: false,
    );
  }
}

void main() {
  testWidgets('app starts on the Kiss Me home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_TestAuthNotifier.new),
          radarSearchProvider.overrideWith(_TestRadarSearchNotifier.new),
        ],
        child: KissMeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kiss Me'), findsWidgets);
    expect(find.text('Kiss Me Now'), findsWidgets);
    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);
  });
}
