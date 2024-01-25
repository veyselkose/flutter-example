import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:example_project/blog_settings_view.dart';
// import 'package:example_project/entry_screen.dart';
import 'package:example_project/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _configureAmplify() async {
  try {
    final api = AmplifyAPI(modelProvider: ModelProvider.instance);

    final auth = AmplifyAuthCognito();

    await Amplify.addPlugins([api, auth]);
    await Amplify.configure(amplifyconfig);

    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
          path: '/blog-settings',
          builder: (context, state) => const BlogSettingsView()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp.router(
        theme: ThemeData(
          useMaterial3: true,
          // colorSchemeSeed: const Color(0xFF03C00D),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF03C00D),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          // colorSchemeSeed: const Color(0xFF03C00D),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF03C00D),
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.light,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        builder: Authenticator.builder(),
      ),
    );
  }
}
