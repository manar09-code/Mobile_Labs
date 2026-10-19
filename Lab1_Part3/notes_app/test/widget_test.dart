import 'package:appwrite/models.dart' as models;
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/providers/auth_provider.dart';
import 'package:notes_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class _SignedOutAuthService extends AuthService {
  @override
  Future<models.User?> currentUser() async => null;
}

void main() {
  testWidgets('signed-out users are sent to the login screen', (tester) async {
    final auth = AuthProvider(_SignedOutAuthService());
    await auth.init();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: NotesApp(auth: auth),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
    expect(find.text("I don't have an account"), findsOneWidget);
  });
}
