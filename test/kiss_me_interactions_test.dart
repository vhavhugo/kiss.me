import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kiss_me/core/mock/mock_chat_repository.dart';
import 'package:kiss_me/core/util/location_service.dart';
import 'package:kiss_me/features/chat/domain/entities/chat_message.dart';
import 'package:kiss_me/features/chat/presentation/pages/conversation_page.dart';
import 'package:kiss_me/features/chat/presentation/providers/chat_provider.dart';
import 'package:kiss_me/features/auth/domain/entities/auth_user_entity.dart';
import 'package:kiss_me/features/auth/presentation/providers/auth_provider.dart';
import 'package:kiss_me/features/notifications/presentation/providers/notification_items_provider.dart';
import 'package:kiss_me/features/profile/domain/entities/profile_authenticity_entity.dart';
import 'package:kiss_me/features/profile/presentation/providers/verification_provider.dart';
import 'package:kiss_me/features/radar/domain/entities/interaction_entity.dart';
import 'package:kiss_me/features/radar/domain/entities/question_entity.dart';
import 'package:kiss_me/features/radar/domain/entities/user_entity.dart';
import 'package:kiss_me/features/radar/presentation/pages/kiss_me_page.dart';
import 'package:kiss_me/features/radar/presentation/pages/radar_page.dart';
import 'package:kiss_me/features/radar/presentation/providers/radar_provider.dart';
import 'package:kiss_me/features/radar/presentation/providers/interactions_provider.dart';
import 'package:kiss_me/features/radar/presentation/providers/radar_search_provider.dart';
import 'package:kiss_me/features/radar/presentation/widgets/action_button.dart';

UserEntity _user(String id) => UserEntity(
  id: id,
  name: id,
  photoUrl: '',
  distanceInMeters: 100,
  bio: '',
  icebreakers: [QuestionEntity(id: 'question', text: 'Qual seu sonho?')],
  authenticity: ProfileAuthenticityEntity(
    level: AuthenticityLevel.unverified,
    isAiGenerated: false,
    verificationMethod: '',
    lastVerifiedAt: DateTime(2026),
  ),
);

class _Auth extends AuthNotifier {
  @override
  AuthState build() => AuthState(
    status: AuthStatus.authenticated,
    isOnline: true,
    user: AuthUserEntity(
      id: 'me',
      email: 'me@example.com',
      isFirstLogin: false,
    ),
  );
}

class _Search extends RadarSearchNotifier {
  @override
  RadarSearchState build() => RadarSearchState(
    users: [_user('first'), _user('second')],
    currentRadiusKm: 0.5,
    isSearching: false,
  );

  @override
  void startSearch(String userId, double lat, double lng) {}
}

class _Interactions extends InteractionsNotifier {
  _Interactions({this.initial = const []});

  final List<InteractionRecord> initial;
  final sent = <InteractionEntity>[];

  @override
  List<InteractionRecord> build() => initial;

  @override
  Future<void> send({
    required String fromUserId,
    required UserEntity target,
    required ActionType type,
    String answer = '',
    InteractionSource source = InteractionSource.kissMe,
  }) async {
    sent.add(
      InteractionEntity(
        fromUserId: fromUserId,
        toUserId: target.id,
        type: type,
        answer: answer,
      ),
    );
    state = [
      InteractionRecord(
        toUserId: target.id,
        toUserName: target.name,
        toUserPhotoUrl: target.photoUrl,
        type: type,
        createdAt: DateTime.now(),
        source: source,
        answer: answer,
      ),
      ...state,
    ];
  }
}

Finder _button(ActionType type) => find.byWidgetPredicate(
  (widget) => widget is ActionButton && widget.type == type,
);

class _Location extends LocationService {
  @override
  Future<Position> getCurrentPosition() async => Position(
    longitude: 0,
    latitude: 0,
    timestamp: DateTime(2026),
    accuracy: 1,
    altitude: 0,
    altitudeAccuracy: 1,
    heading: 0,
    headingAccuracy: 1,
    speed: 0,
    speedAccuracy: 1,
  );
}

class _Verified extends VerificationNotifier {
  @override
  bool build() => true;
}

class _Chat extends ChatController {
  _Chat() : super(MockChatRepository());

  final messages = <ChatMessage>[];
  String? conversation;
  bool fail = false;

  @override
  Future<void> sendText(
    String conversationId,
    String senderId,
    String text,
  ) async {
    if (fail) throw StateError('Falha de rede');
    conversation = conversationId;
    messages.add(
      ChatMessage(
        id: 'test-message',
        senderId: senderId,
        type: ChatMessageType.text,
        content: text,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> markRead(String conversationId, String userId) async {}
}

Future<_Chat> _pumpNow(
  WidgetTester tester, {
  bool fail = false,
  List<InteractionRecord> initialInteractions = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final chat = _Chat()..fail = fail;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authProvider.overrideWith(_Auth.new),
        radarSearchProvider.overrideWith(_Search.new),
        interactionsProvider.overrideWith(
          () => _Interactions(initial: initialInteractions),
        ),
        locationServiceProvider.overrideWith((ref) => _Location()),
        verificationProvider.overrideWith(_Verified.new),
        chatControllerProvider.overrideWith((ref) => chat),
        chatMessagesProvider.overrideWith(
          (ref, id) => Stream.value(chat.messages),
        ),
      ],
      child: const MaterialApp(home: RadarPage()),
    ),
  );
  await tester.pumpAndSettle();
  return chat;
}

Future<_Interactions> _pumpPage(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final interactions = _Interactions();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authProvider.overrideWith(_Auth.new),
        radarSearchProvider.overrideWith(_Search.new),
        interactionsProvider.overrideWith(() => interactions),
        unreadNotificationsCountProvider.overrideWith((ref) => 0),
      ],
      child: const MaterialApp(home: KissMePage()),
    ),
  );
  await tester.pumpAndSettle();
  return interactions;
}

void main() {
  for (final source in InteractionSource.values) {
    test('${source.name} preserves its exact deadline after serialization', () {
      final createdAt = DateTime(2026, 10, 20, 10);
      final record = InteractionRecord(
        toUserId: 'first',
        toUserName: 'first',
        toUserPhotoUrl: '',
        type: ActionType.kiss,
        createdAt: createdAt,
        source: source,
      );
      final restored = InteractionRecord.fromJson(record.toJson());
      expect(restored.source, source);
      expect(
        restored.expiresAt.difference(createdAt),
        Duration(hours: source == InteractionSource.kissMeNow ? 1 : 24),
      );
    });

    testWidgets('${source.name} uses its own deadline when reopening chat', (
      tester,
    ) async {
      await _pumpNow(
        tester,
        initialInteractions: [
          InteractionRecord(
            toUserId: 'first',
            toUserName: 'first',
            toUserPhotoUrl: '',
            type: ActionType.kiss,
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            source: source,
          ),
        ],
      );
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .push(
            MaterialPageRoute<void>(
              builder: (_) => const ConversationPage(
                peerId: 'first',
                peerName: 'first',
                peerPhotoUrl: '',
              ),
            ),
          );
      await tester.pumpAndSettle();
      if (source == InteractionSource.kissMeNow) {
        expect(find.text('Conversa encerrada'), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
      } else {
        expect(find.text('Conversa encerrada'), findsNothing);
        expect(find.textContaining('21:59:'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      }
    });
  }

  test('legacy interactions retain the 24-hour deadline', () {
    final record = InteractionRecord.fromJson({
      'toUserId': 'first',
      'type': 'kiss',
      'createdAt': '2026-10-20T10:00:00.000',
    });
    expect(record.source, InteractionSource.kissMe);
    expect(record.expiresAt, DateTime(2026, 10, 21, 10));
  });

  const expectedMessages = {
    ActionType.kiss: '💋 Te enviei um beijo!',
    ActionType.hug: '🤗 Te enviei um abraço!',
    ActionType.handshake: '🤝 Te enviei um aperto de mão!',
    ActionType.walk: '🥂 Vamos sair juntos?',
  };
  for (final type in ActionType.values) {
    testWidgets('Kiss Me Now ${type.name} restarts an expired conversation', (
      tester,
    ) async {
      await _pumpNow(
        tester,
        initialInteractions: [
          InteractionRecord(
            toUserId: 'first',
            toUserName: 'first',
            toUserPhotoUrl: '',
            type: ActionType.walk,
            createdAt: DateTime.now().subtract(const Duration(hours: 25)),
          ),
        ],
      );
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const ConversationPage(
            peerId: 'first',
            peerName: 'first',
            peerPhotoUrl: '',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Conversa encerrada'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      navigator.pop();
      await tester.pumpAndSettle();

      await tester.ensureVisible(_button(type));
      await tester.tap(_button(type));
      await tester.pumpAndSettle();

      expect(find.byType(ConversationPage), findsOneWidget);
      expect(find.text('Conversa encerrada'), findsNothing);
      expect(
        find.textContaining('O tempo desta conversa acabou'),
        findsNothing,
      );
      expect(find.textContaining('00:59:'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text(expectedMessages[type]!), findsOneWidget);

      navigator.pop();
      await tester.pumpAndSettle();
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const ConversationPage(
            peerId: 'first',
            peerName: 'first',
            peerPhotoUrl: '',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Conversa encerrada'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Kiss Me Now ${type.name} opens chat with sent message', (
      tester,
    ) async {
      final chat = await _pumpNow(tester);
      await tester.ensureVisible(_button(type));
      await tester.tap(_button(type));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(ConversationPage), findsOneWidget);
      expect(
        tester.widget<ConversationPage>(find.byType(ConversationPage)).peerId,
        'first',
      );
      expect(chat.conversation, conversationIdFor('me', 'first'));
      expect(chat.messages, hasLength(1));
      expect(chat.messages.single.senderId, 'me');
      expect(find.text(expectedMessages[type]!), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Kiss Me Now reports chat send failure without navigating', (
    tester,
  ) async {
    final chat = await _pumpNow(tester, fail: true);
    await tester.ensureVisible(_button(ActionType.kiss));
    await tester.tap(_button(ActionType.kiss));
    await tester.pumpAndSettle();

    expect(chat.messages, isEmpty);
    expect(find.byType(ConversationPage), findsNothing);
    expect(
      find.textContaining('Não foi possível enviar a mensagem:'),
      findsOneWidget,
    );
    expect(find.text('first'), findsWidgets);
  });

  for (final type in ActionType.values) {
    testWidgets('${type.name} sends directly, confirms and advances', (
      tester,
    ) async {
      final interactions = await _pumpPage(tester);

      await tester.tap(_button(type));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(find.byType(BottomSheet), findsNothing);
      expect(interactions.sent, hasLength(1));
      expect(interactions.sent.single.toUserId, 'first');
      expect(interactions.sent.single.type, type);
      expect(interactions.sent.single.answer, isEmpty);
      expect(find.text('${type.label} enviado para first!'), findsOneWidget);
      expect(
        tester.widget<PageView>(find.byType(PageView)).controller!.page,
        1,
      );

      await tester.tap(_button(type));
      await tester.pumpAndSettle();

      expect(interactions.sent, hasLength(2));
      expect(interactions.sent.last.toUserId, 'second');
      expect(
        tester.widget<PageView>(find.byType(PageView)).controller!.page,
        1,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('repeated taps do not send twice while advancing', (
    tester,
  ) async {
    final interactions = await _pumpPage(tester);

    await tester.tap(_button(ActionType.kiss));
    await tester.tap(_button(ActionType.hug));
    await tester.pumpAndSettle();

    expect(interactions.sent, hasLength(1));
    expect(interactions.sent.single.type, ActionType.kiss);
    expect(tester.widget<PageView>(find.byType(PageView)).controller!.page, 1);
  });
}
