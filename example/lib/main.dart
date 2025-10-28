import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:babylai_flutter/babylai_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:babylai_flutter/models/theme_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

late final String _englishScreenId;
late final String _arabicScreenId;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (error) {
    debugPrint('Falling back to .env.example: $error');
    await dotenv.load(fileName: '.env.example');
  }

  final apiKey = dotenv.env['API_KEY'];
  final tenantId = dotenv.env['TENANT_ID'];
  final defaultScreenId =
      (dotenv.env['SCREEN_ID'] ?? dotenv.env['ENGLISH_SCREEN_ID'])?.trim();
  final englishScreenId =
      (dotenv.env['ENGLISH_SCREEN_ID'] ?? defaultScreenId)?.trim();
  final arabicScreenId =
      (dotenv.env['ARABIC_SCREEN_ID'] ?? defaultScreenId)?.trim();

  if (apiKey == null || apiKey.isEmpty || tenantId == null || tenantId.isEmpty) {
    throw Exception(
      'Missing API_KEY or TENANT_ID in .env.\n'
      'Create example/.env based on example/.env.example and add your credentials.',
    );
  }

  if (englishScreenId == null || englishScreenId.isEmpty) {
    throw Exception(
      'Missing SCREEN_ID or ENGLISH_SCREEN_ID in .env.\n'
      'Create example/.env based on example/.env.example and add the screen identifier(s).',
    );
  }

  _englishScreenId = englishScreenId;
  _arabicScreenId = arabicScreenId == null || arabicScreenId.isEmpty
      ? _englishScreenId
      : arabicScreenId;

  Future<String> getAuthToken() async {
    // Example: Fetch token from your backend
    final response = await http.post(
      Uri.parse(
        'https://babylai-be.dev.kvm.creativeadvtech.ml/Auth/client/get-token',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'apiKey': apiKey, 'tenantId': tenantId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'] as String;
    }

    throw Exception('Failed to get token');
  }

  // Initialize BabylAI
  await BabylaiFlutter.initialize(
    environmentConfig: EnvironmentConfig.development(
      enableLogging:
          true, // Enable logging for debugging (set to false in production)
    ),
    locale: BabylAILocale.english,
    themeConfig: const ThemeConfig(
      primaryColorHex: '#F05A28',
      secondaryColorHex: '#283238',
      primaryColorDarkHex: '#F05A28',
      secondaryColorDarkHex: '#ffffff',
      headerLogo: 'meta', //Optional: Custom logo configuration:
      // - iOS: Add to Assets.xcassets as 'meta' OR use Flutter asset path 'assets/svgs/meta.svg'
      // - Android: Add meta.png to android/app/src/main/res/drawable/
      // See CUSTOM_LOGO.md for detailed setup instructions
    ),
    tokenCallback: () async {
      return getAuthToken();
    },
    onMessageReceived: (message) {
      debugPrint('📨 New message received: $message');
    },
    onError: (code, message, details) {
      debugPrint('❌ Error [$code]: $message - $details');
    },
  );

  runApp(const MyApp());
}

// no helpers needed; jsonDecode used in tokenCallback

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabylAI Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BabylAIDemo(),
    );
  }
}

class BabylAIDemo extends StatefulWidget {
  const BabylAIDemo({super.key});

  @override
  State<BabylAIDemo> createState() => _BabylAIDemoState();
}

class _BabylAIDemoState extends State<BabylAIDemo> {
  String _platformVersion = 'Unknown';
  BabylAILocale _currentLocale = BabylAILocale.english;
  BabylAITheme _currentTheme = BabylAITheme.light;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await BabylaiFlutter.getPlatformVersion() ?? 'Unknown';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _isInitialized = BabylaiFlutter.isInitialized;
    });

    // Get current locale
    if (_isInitialized) {
      _currentLocale = await BabylaiFlutter.getLocale();
      setState(() {});
    }
  }

  Future<void> _toggleTheme() async {
    final newTheme = _currentTheme == BabylAITheme.light
        ? BabylAITheme.dark
        : BabylAITheme.light;

    await BabylaiFlutter.updateTheme(newTheme);
    setState(() {
      _currentTheme = newTheme;
    });
  }

  Future<void> _toggleLocale() async {
    final newLocale = _currentLocale == BabylAILocale.english
        ? BabylAILocale.arabic
        : BabylAILocale.english;

    await BabylaiFlutter.updateLocale(newLocale);
    setState(() {
      _currentLocale = newLocale;
    });
  }

  Future<void> _launchChat() async {
    final screenId =
        _currentLocale == BabylAILocale.arabic ? _arabicScreenId : _englishScreenId;
    try {
      await BabylaiFlutter.launchChat(
        screenId: screenId,
        theme: _currentTheme,
        onMessageReceived: (message) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('New message: $message')));
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error launching chat: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('BabylAI Flutter Demo'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Platform',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(_platformVersion),
                      const SizedBox(height: 16),
                      Text(
                        'SDK Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isInitialized ? Icons.check_circle : Icons.error,
                            color: _isInitialized ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isInitialized ? 'Initialized' : 'Not Initialized',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Theme: ${_currentTheme.name}'),
                      Text('Locale: ${_currentLocale.name}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Main Actions
              ElevatedButton.icon(
                onPressed: _isInitialized ? _launchChat : null,
                icon: const Icon(Icons.chat),
                label: const Text('Launch BabylAI Chat'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
              ),
              const SizedBox(height: 16),

              // ElevatedButton.icon(
              //   onPressed: _isInitialized ? _launchActiveChat : null,
              //   icon: const Icon(Icons.chat_bubble),
              //   label: const Text('Launch Active Chat'),
              //   style: ElevatedButton.styleFrom(
              //     minimumSize: const Size(200, 50),
              //   ),
              // ),
              // const SizedBox(height: 32),

              // Settings
              Text('Settings', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _isInitialized ? _toggleTheme : null,
                icon: Icon(
                  _currentTheme == BabylAITheme.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                label: Text(
                  'Switch to ${_currentTheme == BabylAITheme.light ? 'Dark' : 'Light'} Theme',
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _isInitialized ? _toggleLocale : null,
                icon: const Icon(Icons.language),
                label: Text(
                  'Switch to ${_currentLocale == BabylAILocale.english ? 'Arabic' : 'English'}',
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
              ),
              const SizedBox(height: 32),

              // Reset Button
              OutlinedButton.icon(
                onPressed: _isInitialized
                    ? () async {
                        await BabylaiFlutter.reset();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('SDK Reset')),
                        );
                      }
                    : null,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset SDK'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
