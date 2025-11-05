# Changelog

All notable changes to this project will be documented in this file.

## 1.0.17 - 2025-11-05

- iOS: Fix error screen when getting token (localized error UI with retry/back; logs restored)

## 1.0.16 - 2025-11-04

- Update iOS SDK to version 1.0.41: Support iPad layout

## 1.0.15 - 2025-11-02

- Fix iOS podspec file name to match package name (`babylai.podspec`)
- Update podspec version to sync with package version
- iOS: CocoaPods integration now works correctly with pub.dev installation

## 1.0.14 - 2025-10-30

- Rename package to `babylai` on pub.dev
- Update README installation to use `babylai: ^1.0.14`
- Replace import paths to `package:babylai/babylai_flutter.dart`
- Add concrete LICENSE file (proprietary terms)
- Add initial CHANGELOG and metadata cleanup

## 1.0.13+5 - 2025-10-30

- Initial release on pub.dev
- Flutter plugin for BabylAI native Android and iOS SDKs
- Added BabylAI chat launch APIs: `launchChat`, `launchActiveChat`
- Initialization API with environment config, token callback, and callbacks for messages and errors
- Dynamic language switching at runtime (English LTR, Arabic RTL)
- Light/Dark theme support and runtime theme switching
- Advanced theme customization (primary/secondary colors for light and dark, custom header logo)
- Message receiving callback for custom notification handling
- Comprehensive error handling with standardized error codes
- Android: automatic dependency resolution via Maven Central and ProGuard rules
- iOS: Swift Package support, iOS 13+ minimum
- Documentation updates and complete usage examples


