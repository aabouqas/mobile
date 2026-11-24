import 'dart:developer';

import 'package:advanced_diary_app/diary.dart';
import 'package:advanced_diary_app/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient supabase = Supabase.instance.client;
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://fkvwigxbitnqtptlkhfo.supabase.co',
      publishableKey: 'sb_publishable_yEb1zqDBSkzbU8_9FeSQgQ_myLqUzQP',
    );
  }

  static Future<List<Diary>> getUserDiaries() async {
    try {
      if (supabase.auth.currentUser == null) {
        throw Exception('User is not logged in');
      }
      final response = await supabase
          .from('notes')
          .select('*')
          .eq('usermail', supabase.auth.currentUser!.email!)
          .order('updated_at', ascending: false)
          .order('created_at', ascending: false);

      log("DEBUG: ${response.toString()}");

      return response.map((e) => Diary.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<Map<FeelingType, int>?> getFeelingRates() async {
    try {
      if (supabase.auth.currentUser == null) {
        throw Exception('User is not logged in');
      }

      final data = await supabase.rpc('get_feeling_percentages');

      return {
        for (final row in data)
          FeelingType.fromIndex(row['icon']): (row['percentage'] as num)
              .toInt(),
      };
    } catch (e) {
      log("DEBUG: ${e.toString()}");
      return null;
    }
  }

  static Future<bool> logout() async {
    try {
      await supabase.auth.signOut();
      return true;
    } catch (e) {
      log("DEBUG: ${e.toString()}");
      return false;
    }
  }

  static Future<bool> insertDiary(Diary diary) async {
    log("DEBUG: inserting diary ${diary.title} ${diary.text}");
    try {
      await supabase.from('notes').insert({
        ...diary.toMap(),
        'usermail': supabase.auth.currentUser!.email,
      });
      return true;
    } catch (e) {
      log("DEBUG: ${e.toString()}");
      return false;
    }
  }

  static Future<bool> updateDiary(Diary diary) async {
    log("DEBUG: updating diary ${diary.title} ${diary.text}");
    try {
      await supabase.from('notes').update(diary.toMap()).eq('id', diary.id!);
      return true;
    } catch (e) {
      log("DEBUG: ${e.toString()}");
      return false;
    }
  }

  static Future<void> deleteDiary({int? id}) async {
    try {
      await supabase.from('notes').delete().eq('id', id!);
    } catch (e) {
      log("DEBUG: ${e.toString()}");
    }
  }
}
