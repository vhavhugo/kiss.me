// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kiss_me/features/auth/presentation/providers/age_gate_provider.dart';

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

class _TestUnauthenticatedNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return AuthState(status: AuthStatus.unauthenticated);
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
  testWidgets('asks for age confirmation before opening the app', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith(_TestAuthNotifier.new)],
        child: KissMeApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Confirme sua idade'), findsOneWidget);
    expect(find.text('Ajustes'), findsNothing);
  });

  test('age is computed correctly', () {
    final now = DateTime(2026, 10, 18);
    expect(AgeGateNotifier.ageOf(DateTime(2008, 10, 18), now), 18);
    expect(AgeGateNotifier.ageOf(DateTime(2008, 10, 19), now), 17);
  });

  testWidgets('app starts on the Kiss Me home screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'age_gate_v1_test-user': 'adult'});
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

  testWidgets('login screen shows the logo and fits short screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(_TestUnauthenticatedNotifier.new),
        ],
        child: KissMeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Logo Kiss Me'), findsOneWidget);
    final logoFinder = find.byWidgetPredicate(
      (widget) => widget is Image && widget.semanticLabel == 'Logo Kiss Me',
    );
    expect(tester.widget<Image>(logoFinder).width, 208);
    expect(find.text('Entrar com Google'), findsOneWidget);
    expect(find.text('Entrar com Instagram'), findsOneWidget);
    expect(find.text('Entrar com TikTok'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
