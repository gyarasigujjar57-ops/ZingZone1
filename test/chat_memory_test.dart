import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zing_zone/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('chat history persists and is capped at fifty conversations', () async {
    for (var i = 0; i < 52; i++) {
      await ChatMemory.saveHistory('conversation $i');
    }
    final history = await ChatMemory.loadHistory();
    expect(history, hasLength(50));
    expect(history.first, 'conversation 51');
    expect(history.last, 'conversation 2');
  });

  test('drafts persist and can be deleted', () async {
    await ChatMemory.saveDraft('first draft');
    await ChatMemory.saveDraft('second draft');
    expect(await ChatMemory.loadDrafts(), ['second draft', 'first draft']);
    await ChatMemory.deleteDraftAt(0);
    expect(await ChatMemory.loadDrafts(), ['first draft']);
  });

  test('empty chat and draft text is ignored', () async {
    await ChatMemory.saveHistory('   ');
    await ChatMemory.saveDraft('');
    expect(await ChatMemory.loadHistory(), isEmpty);
    expect(await ChatMemory.loadDrafts(), isEmpty);
  });
}