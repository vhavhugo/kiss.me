import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserReport {
  final String reportedId;
  final String reason;
  final String details;
  final DateTime createdAt;

  const UserReport({
    required this.reportedId,
    required this.reason,
    required this.details,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'reportedId': reportedId,
        'reason': reason,
        'details': details,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// Pessoas bloqueadas por este aparelho. Nunca mais aparecem na mesa,
/// no Kiss Me nem nas conversas.
class BlockedUsersNotifier extends Notifier<Set<String>> {
  static const _blockedKey = 'blocked_users_v1';
  static const _reportsKey = 'user_reports_v1';

  @override
  Set<String> build() {
    _load();
    return const {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = {...state, ...(prefs.getStringList(_blockedKey) ?? const [])};
  }

  Future<void> block(String userId) async {
    state = {...state, userId};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_blockedKey, state.toList());
  }

  Future<void> unblock(String userId) async {
    state = {...state}..remove(userId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_blockedKey, state.toList());
  }

  Future<void> report(UserReport report) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_reportsKey) ?? <String>[];
    list.add(jsonEncode(report.toJson()));
    await prefs.setStringList(_reportsKey, list);
  }
}

final blockedUsersProvider =
    NotifierProvider<BlockedUsersNotifier, Set<String>>(
  BlockedUsersNotifier.new,
);
