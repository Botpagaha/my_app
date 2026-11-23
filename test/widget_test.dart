import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_app/main.dart';
import 'package:my_app/services/storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('Berdua App smoke test', (WidgetTester tester) async {
    final storageService = StorageService();
    await storageService.init();

    await tester.pumpWidget(BerduaApp(storageService: storageService));
    await tester.pumpAndSettle();

    // Verify romantic title / header presence
    expect(find.text('Hai, Miftah & Cinta ❤️'), findsOneWidget);
    expect(find.text('Target Indah Terdekat'), findsOneWidget);
  });
}
