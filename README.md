<p align="center">
  <img src="https://babylai.net/assets/logo-BdByHTQ3.svg" alt="BabylAI Logo" height="200"/>
</p>

# BabylAI Flutter

A Flutter plugin that provides seamless integration with BabylAI's native Android and iOS SDKs, enabling AI-powered chat functionality in your Flutter applications.

## Features

- 🚀 Easy integration with BabylAI chat
- 🌓 Support for light and dark themes
- 🎨 **Advanced Theme Customization** - Custom brand colors for light and dark themes
- 🖼️ **Custom Logo Support** - Replace header logo with your brand logo
- 🌍 **Dynamic Language Switching** - Runtime language change (English and Arabic with RTL)
- 📬 Message receiving callback for custom notification handling
- ⚠️ **Comprehensive Error Handling** - Global error callbacks for all SDK errors
- ⚡ Quick access to active chats
- 🏗️ Environment-based configuration (Production/Development with logging control)
- 🔒 Secure, predefined API endpoints
- 📱 Native performance on both iOS and Android

## Installation

### Option 1: Install from GitHub (Recommended)

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  babylai_flutter:
    git:
      url: https://github.com/AAU-IQ/BabylAI-Flutter.git
      ref: main  # or specify a version tag like v1.0.0
```

Then run:

```bash
flutter pub get
```

### Platform-Specific Setup

#### iOS Setup

> **📖 For detailed iOS setup instructions, see the [iOS Setup Guide](IOS_SETUP.md)**

Quick setup:

1. **Add BabylAI iOS SDK as a Swift Package**

   In Xcode:
   - Open `ios/Runner.xcworkspace`
   - File → Add Packages...
   - Enter the repository URL: `https://github.com/AAU-IQ/BabylAI-iOS.git`
   - Select the latest version
   - Add the `BabylAI` product to your Runner target

2. **Update minimum iOS version**

   Ensure your `ios/Podfile` has a minimum deployment target of iOS 13.0:

   ```ruby
   platform :ios, '13.0'
   ```

3. **Run pod install**

   ```bash
   cd ios
   pod install
   cd ..
   ```

For troubleshooting and advanced configuration, refer to the [complete iOS setup guide](IOS_SETUP.md).

#### Android Setup

✅ **No setup required!** The Android SDK is automatically downloaded from Maven Central.

**Only requirement:** Ensure your `android/app/build.gradle` has a minimum SDK version of 24:

```gradle
android {
    defaultConfig {
        minSdkVersion 24
        // ...
    }
}
```

The plugin automatically:
- Downloads the BabylAI Android SDK from Maven Central (`io.github.aau-iq:babylai-android-sdk`)
- Configures all necessary dependencies
- Applies ProGuard rules for release builds

## Usage

### 1. Initialize BabylAI with Environment Configuration

First, initialize BabylAI with the appropriate environment configuration and set up the token callback:

```dart
import 'package:flutter/material.dart';
import 'package:babylai_flutter/babylai_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize BabylAI with environment configuration and custom theming
  await BabylaiFlutter.initialize(
    environmentConfig: EnvironmentConfig.production(
      enableLogging: false, // Enable for debugging, disable in production
    ),
    locale: BabylAILocale.english, // or .arabic
    userInfo: {
      'userId': 'user_123',
      'name': 'John Doe',
      'email': 'john@example.com',
    },
    themeConfig: const ThemeConfig(
      primaryColorHex: '#4A6741',           // Elegant forest green for light theme
      secondaryColorHex: '#D4AF37',         // Sophisticated gold for light theme
      primaryColorDarkHex: '#81C784',       // Soft sage green for dark theme
      secondaryColorDarkHex: '#F9D71C',     // Warm amber for dark theme
      headerLogo: 'your_custom_logo',       // Optional: Your brand logo
    ),
    tokenCallback: () async {
      // Fetch and return your authentication token
      return await getAuthToken();
    },
    onMessageReceived: (message) {
      // Optional: Handle global incoming messages
      print('New message: $message');
    },
    onError: (code, message, details) {
      // Optional: Handle global errors
      print('❌ Error [$code]: $message - $details');
    },
  );

  runApp(const MyApp());
}

Future<String> getAuthToken() async {
  // Example: Fetch token from your backend
  final response = await http.post(
    Uri.parse('https://api.example.com/auth/token'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'apiKey': 'YOUR_API_KEY'}),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['token'] as String;
  }
  
  throw Exception('Failed to get token');
}
```

> ⚠️ **Important**: You must call `BabylaiFlutter.initialize()` before using any other BabylAI functionality. Failure to do so will result in authentication errors when trying to launch the chat interface.

### Environment Configuration

The plugin supports two environments with optional logging:

- **Production**: Uses production API endpoints, logging disabled by default
- **Development**: Uses development API endpoints, logging enabled by default

You can create environment configurations using factory methods:

```dart
// Production environment (logging disabled by default)
final productionConfig = EnvironmentConfig.production();

// Production environment with logging enabled (for debugging)
final productionConfigWithLogging = EnvironmentConfig.production(
  enableLogging: true,
);

// Development environment (logging enabled by default)
final developmentConfig = EnvironmentConfig.development();

// Development environment with logging disabled
final customDevConfig = EnvironmentConfig.development(
  enableLogging: false,
);
```

### Dynamic Language Switching

The BabylAI SDK supports dynamic language switching without requiring re-initialization. You can change the language at runtime and the SDK will update all text content and layout direction accordingly.

#### Setting Language Dynamically

```dart
// Switch to Arabic with RTL support
await BabylaiFlutter.updateLocale(BabylAILocale.arabic);

// Switch back to English with LTR support
await BabylaiFlutter.updateLocale(BabylAILocale.english);

// Get current locale
final currentLocale = await BabylaiFlutter.getLocale();
```

#### Example with UI Controls

```dart
class LanguageSwitcher extends StatefulWidget {
  @override
  _LanguageSwitcherState createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  bool _isArabic = false;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Arabic Language'),
      value: _isArabic,
      onChanged: (enabled) async {
        // Update SDK language dynamically
        await BabylaiFlutter.updateLocale(
          enabled ? BabylAILocale.arabic : BabylAILocale.english,
        );
        setState(() {
          _isArabic = enabled;
        });
      },
    );
  }
}
```

#### Language Features

- **English (BabylAILocale.english)**:
  - Left-to-right (LTR) layout direction
  - English text content and labels
  - Western number formatting

- **Arabic (BabylAILocale.arabic)**:
  - Right-to-left (RTL) layout direction
  - Arabic text content and labels
  - Arabic/Eastern number formatting
  - Proper RTL text alignment

#### Notes

- Language changes take effect immediately in active SDK views
- The locale setting persists across SDK sessions
- RTL layout automatically adjusts all UI components, icons, and navigation
- No re-initialization required when switching languages

### 2. Basic Implementation

Here's a simple example of how to integrate BabylAI in your Flutter app:

```dart
import 'package:flutter/material.dart';
import 'package:babylai_flutter/babylai_flutter.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BabylAI Chat')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await BabylaiFlutter.launchChat(
              onMessageReceived: (message) {
                // Handle new message notifications
                print('New message: $message');
              },
            );
          },
          child: const Text('Open BabylAI Chat'),
        ),
      ),
    );
  }
}
```

### 3. Advanced Implementation

For a more complete implementation with theme and language switching:

```dart
class BabylAIExample extends StatefulWidget {
  const BabylAIExample({super.key});

  @override
  State<BabylAIExample> createState() => _BabylAIExampleState();
}

class _BabylAIExampleState extends State<BabylAIExample> {
  BabylAITheme _currentTheme = BabylAITheme.light;
  BabylAILocale _currentLocale = BabylAILocale.english;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BabylAI Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await BabylaiFlutter.launchChat(
                  onMessageReceived: (message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('New message: $message')),
                    );
                  },
                );
              },
              child: const Text('Launch BabylAI Chat'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await BabylaiFlutter.launchActiveChat(
                  onMessageReceived: (message) {
                    // Handle messages for active chat
                    print('Active chat message: $message');
                  },
                );
              },
              child: const Text('Launch Active Chat'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final newTheme = _currentTheme == BabylAITheme.light
                    ? BabylAITheme.dark
                    : BabylAITheme.light;
                await BabylaiFlutter.updateTheme(newTheme);
                setState(() {
                  _currentTheme = newTheme;
                });
              },
              child: Text(
                'Switch to ${_currentTheme == BabylAITheme.light ? "Dark" : "Light"} Theme',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final newLocale = _currentLocale == BabylAILocale.english
                    ? BabylAILocale.arabic
                    : BabylAILocale.english;
                await BabylaiFlutter.updateLocale(newLocale);
                setState(() {
                  _currentLocale = newLocale;
                });
              },
              child: Text(
                'Switch to ${_currentLocale == BabylAILocale.english ? "Arabic" : "English"}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Customization

### Theme Configuration

The BabylAI SDK supports comprehensive theme customization with separate colors for light and dark modes:

```dart
await BabylaiFlutter.initialize(
  // ... other parameters
  themeConfig: const ThemeConfig(
    // Light theme colors
    primaryColorHex: '#4A6741',      // Main buttons, customer chat bubbles
    secondaryColorHex: '#D4AF37',    // Agent chat bubbles, secondary elements
    
    // Dark theme colors (optional, falls back to light theme colors if not provided)
    primaryColorDarkHex: '#81C784',   // Primary color for dark theme
    secondaryColorDarkHex: '#F9D71C', // Secondary color for dark theme
    
    // Custom logo (optional)
    headerLogo: 'company_logo',       // Your brand logo
  ),
);
```

**What gets customized:**
- **Primary Color**: Main buttons, customer chat bubbles, navigation bars, focus colors
- **Secondary Color**: Agent chat bubbles, secondary elements, accent colors
- **Container Colors**: Automatically generated lighter/darker variants for backgrounds
- **Header Logo**: Replaces the default BabylAI logo in the interface

### Custom Logo

You can customize the header logo displayed in the BabylAI chat interface:

**Platform-specific setup:**

- **iOS**: Add your logo to `ios/Runner/Assets.xcassets` as an image set named `company_logo`, OR use a Flutter asset path like `assets/images/logo.png`
- **Android**: Add your logo to `android/app/src/main/res/drawable/` as `company_logo.png` or `company_logo.xml` (SVG as vector drawable). Reference by name only: `company_logo`

## API Reference

### BabylaiFlutter Class

#### Methods

##### `initialize()`

Initialize the BabylAI SDK with configuration.

```dart
static Future<void> initialize({
  required EnvironmentConfig environmentConfig,
  required BabylAILocale locale,
  Map<String, dynamic> userInfo = const {},
  required Future<String> Function() tokenCallback,
  void Function(String message)? onMessageReceived,
  void Function(String code, String message, String details)? onError,
  ThemeConfig? themeConfig,
})
```

**Parameters:**
- `environmentConfig`: The environment configuration (use `EnvironmentConfig.production()` or `EnvironmentConfig.development()`)
- `locale`: The language locale (`.english` or `.arabic`)
- `userInfo`: Optional user information map
- `tokenCallback`: Async function that returns the authentication token
- `onMessageReceived`: Optional global callback for handling new messages
- `onError`: Optional global callback for handling errors
- `themeConfig`: Optional theme configuration for custom branding

##### `launchChat()`

Launch the BabylAI chat interface.

```dart
static Future<void> launchChat({
  void Function(String)? onMessageReceived,
})
```

**Parameters:**
- `onMessageReceived`: Optional callback for handling new messages

##### `launchActiveChat()`

Launch directly into the active chat.

```dart
static Future<void> launchActiveChat({
  void Function(String)? onMessageReceived,
})
```

**Parameters:**
- `onMessageReceived`: Optional callback for handling new messages

##### `updateTheme()`

Update the chat theme dynamically.

```dart
static Future<void> updateTheme(BabylAITheme theme)
```

**Parameters:**
- `theme`: The theme to apply (`.light` or `.dark`)

##### `updateLocale()`

Update the chat language dynamically without re-initialization.

```dart
static Future<void> updateLocale(BabylAILocale locale)
```

**Parameters:**
- `locale`: The locale to apply (`.english` or `.arabic`)

##### `getLocale()`

Get the currently selected SDK language.

```dart
static Future<BabylAILocale> getLocale()
```

**Returns:** The current locale setting

##### `reset()`

Reset SDK state: close active chat session, clear stored credentials.

```dart
static Future<void> reset()
```

### Classes and Enums

#### EnvironmentConfig

Environment configuration for the BabylAI SDK.

```dart
// Factory constructors
EnvironmentConfig.production({bool enableLogging = false})
EnvironmentConfig.development({bool enableLogging = true})
```

**Properties:**
- `environment`: The environment type (production or development)
- `enableLogging`: Whether to enable SDK logging

#### ThemeConfig

Theme configuration for custom branding.

```dart
const ThemeConfig({
  String? primaryColorHex,
  String? secondaryColorHex,
  String? primaryColorDarkHex,
  String? secondaryColorDarkHex,
  String? headerLogo,
})
```

#### BabylAIEnvironment

- `production`: Production environment
- `development`: Development environment

#### BabylAILocale

- `english`: English language with LTR layout
- `arabic`: Arabic language with RTL layout

#### BabylAITheme

- `light`: Light theme
- `dark`: Dark theme

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:babylai_flutter/babylai_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize BabylAI with full configuration
  await BabylaiFlutter.initialize(
    environmentConfig: EnvironmentConfig.production(
      enableLogging: true, // Enable for debugging
    ),
    locale: BabylAILocale.english,
    userInfo: {
      'userId': 'user_123',
      'name': 'John Doe',
      'email': 'john@example.com',
    },
    themeConfig: const ThemeConfig(
      primaryColorHex: '#4A6741',
      secondaryColorHex: '#D4AF37',
      primaryColorDarkHex: '#81C784',
      secondaryColorDarkHex: '#F9D71C',
      headerLogo: 'company_logo',
    ),
    tokenCallback: () async {
      // Fetch token from your backend
      final response = await http.post(
        Uri.parse('https://api.example.com/auth/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'apiKey': 'YOUR_API_KEY'}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'] as String;
      }
      
      return '';
    },
    onMessageReceived: (message) {
      print('📨 New message: $message');
    },
    onError: (code, message, details) {
      print('❌ Error [$code]: $message');
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabylAI Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BabylAITheme _theme = BabylAITheme.light;
  BabylAILocale _locale = BabylAILocale.english;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BabylAI Flutter Plugin')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await BabylaiFlutter.launchChat(
                  onMessageReceived: (message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('New message: $message')),
                    );
                  },
                );
              },
              child: const Text('Open Chat'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await BabylaiFlutter.launchActiveChat();
              },
              child: const Text('Open Active Chat'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final newTheme = _theme == BabylAITheme.light
                    ? BabylAITheme.dark
                    : BabylAITheme.light;
                await BabylaiFlutter.updateTheme(newTheme);
                setState(() {
                  _theme = newTheme;
                });
              },
              child: Text(
                'Switch to ${_theme == BabylAITheme.light ? "Dark" : "Light"} Theme',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final newLocale = _locale == BabylAILocale.english
                    ? BabylAILocale.arabic
                    : BabylAILocale.english;
                await BabylaiFlutter.updateLocale(newLocale);
                setState(() {
                  _locale = newLocale;
                });
              },
              child: Text(
                'Switch to ${_locale == BabylAILocale.english ? "Arabic" : "English"}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Token Callback

The token callback is essential for authentication with the BabylAI service. The callback should:

1. Make an API request to get a fresh token
2. Parse the response correctly (the token is at the root level with key "token")
3. Return the token as a string
4. Handle errors appropriately

Example token response structure:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 900
}
```

### Automatic Token Refresh

The plugin automatically handles token expiration by:

1. Detecting 401 (Unauthorized) or 403 (Forbidden) HTTP errors
2. Automatically calling your token callback to get a fresh token
3. Storing the new token for subsequent requests

This ensures that your users won't experience disruptions when their token expires during a session.

## Message Handling

The plugin provides a callback for handling new messages through the `onMessageReceived` parameter. You can implement your own notification system or message handling logic. Here's an example of how you might handle new messages:

```dart
await BabylaiFlutter.initialize(
  // ... other configuration
  onMessageReceived: (message) {
    // Implement your preferred notification system
    // For example, using local notifications package
    showCustomNotification(message);
  },
);
```

## Error Handling

The BabylAI SDK provides comprehensive error handling with categorized error codes, detailed descriptions, and recovery suggestions. All errors are mapped to standardized error instances with unique error codes for easy documentation and debugging.

### Setting Up Error Handling

```dart
await BabylaiFlutter.initialize(
  // ... other configuration
  onError: (code, message, details) {
    print('Error Code: $code');
    print('Description: $message');
    print('Details: $details');
    
    // Handle specific error types
    if (code.contains('BABYLAI_AUTH')) {
      // Authentication error - refresh token or re-authenticate
      handleAuthError();
    } else if (code.contains('BABYLAI_NET')) {
      // Network error - show retry option
      showNetworkError();
    } else if (code.contains('BABYLAI_CFG')) {
      // Configuration error - check initialization
      reinitializeSDK();
    }
  },
);
```

### Error Categories

#### Network Errors (1000-1999)
- **BABYLAI_NET_1001**: Connection timeout
- **BABYLAI_NET_1002**: Server unavailable
- **BABYLAI_NET_1003**: Invalid response
- **BABYLAI_NET_[statusCode]**: Request failed with specific HTTP status code

#### Authentication Errors (2000-2999)
- **BABYLAI_AUTH_2001**: Authentication failed
- **BABYLAI_AUTH_2002**: Token expired
- **BABYLAI_AUTH_2003**: Invalid token
- **BABYLAI_AUTH_2004**: Token refresh failed
- **BABYLAI_AUTH_2005**: Unauthorized access

#### Configuration Errors (3000-3999)
- **BABYLAI_CFG_3001**: SDK not initialized
- **BABYLAI_CFG_3002**: Invalid configuration
- **BABYLAI_CFG_3003**: Missing required parameter
- **BABYLAI_CFG_3004**: Invalid environment

#### Data Errors (4000-4999)
- **BABYLAI_DATA_4001**: Data parsing error
- **BABYLAI_DATA_4002**: Invalid data format
- **BABYLAI_DATA_4003**: Data not found
- **BABYLAI_DATA_4004**: Data corrupted

#### UI Errors (5000-5999)
- **BABYLAI_UI_5001**: View presentation failed
- **BABYLAI_UI_5002**: Theme configuration error
- **BABYLAI_UI_5003**: Localization error

### Best Practices

1. **Always set an error callback** to handle SDK errors gracefully
2. **Use error codes** for documentation and support
3. **Implement error code-based handling** for better user experience
4. **Log errors** for debugging and analytics
5. **Provide recovery suggestions** to users when possible
6. **Test error scenarios** to ensure proper error handling

## Troubleshooting

### iOS Issues

**Issue**: BabylAI Swift Package not found
- **Solution**: Manually add the BabylAI Swift Package in Xcode as described in the iOS Setup section

**Issue**: Minimum deployment target error
- **Solution**: Ensure your `ios/Podfile` has `platform :ios, '13.0'` or higher

**Issue**: Pod install fails
- **Solution**: Try `cd ios && pod deintegrate && pod install`

### Android Issues

**Issue**: Failed to resolve BabylAI Android SDK
- **Solution**: Check your internet connection and ensure the Maven repository is accessible
- **Alternative**: The plugin will fallback to JitPack automatically

**Issue**: Minimum SDK version error
- **Solution**: Set `minSdkVersion 24` in `android/app/build.gradle`

**Issue**: Release build crash with `ClassNotFoundException`
- **Solution**: The plugin includes ProGuard rules automatically. If you still experience issues, ensure your app's `proguard-rules.pro` includes:
  ```proguard
  -keep class io.ably.** { *; }
  -keep class org.msgpack.** { *; }
  -keep class org.java_websocket.** { *; }
  ```

**Issue**: Network permission error
- **Solution**: The plugin automatically adds INTERNET permission, but verify your app's manifest has:
  ```xml
  <uses-permission android:name="android.permission.INTERNET" />
  ```

### General Issues

**Issue**: Token authentication fails
- **Solution**: 
  1. Verify your token callback returns a valid JWT token
  2. Check that the token response structure matches: `{"token": "..."}`
  3. Enable logging to see network requests: `EnvironmentConfig.production(enableLogging: true)`

**Issue**: Messages not received
- **Solution**: Ensure `onMessageReceived` callback is properly set up during initialization or when launching chat

**Issue**: Language/theme changes not applied
- **Solution**: Call `updateLocale()` or `updateTheme()` after initialization

## Contributing

For issues or feature requests, please visit the [issue tracker](https://github.com/AAU-IQ/BabylAI-Flutter/issues).

## License

Copyright © 2025 BabylAI

This software is provided under a custom license agreement. Usage is permitted only with explicit authorization from BabylAI. This software may not be redistributed, modified, or used in derivative works without written permission from BabylAI.

All rights reserved.

## Support

For support, please contact: info@babylai.net

## Related Links

- [BabylAI Website](https://babylai.net)
- [BabylAI Flutter Plugin Repository](https://github.com/AAU-IQ/BabylAI-Flutter)
- [BabylAI Android SDK](https://github.com/AAU-IQ/BabylAI-Android)
- [BabylAI iOS SDK](https://github.com/AAU-IQ/BabylAI-iOS)
