/// Environment types for the BabylAI SDK
enum BabylAIEnvironment {
  production,
  development;

  String get value {
    switch (this) {
      case BabylAIEnvironment.production:
        return 'production';
      case BabylAIEnvironment.development:
        return 'development';
    }
  }

  String get displayName {
    switch (this) {
      case BabylAIEnvironment.production:
        return 'Production';
      case BabylAIEnvironment.development:
        return 'Development';
    }
  }
}

/// Configuration for the BabylAI SDK environment
///
/// This is a simplified configuration that only exposes environment type and logging.
/// Base URLs and timeouts are managed internally by the native SDKs.
class EnvironmentConfig {
  /// The environment type (production or development)
  final BabylAIEnvironment environment;

  /// Whether to enable SDK logging (default: false for production, true for development)
  final bool enableLogging;

  const EnvironmentConfig({
    required this.environment,
    required this.enableLogging,
  });

  /// Factory constructor for production configuration
  factory EnvironmentConfig.production({bool enableLogging = false}) {
    return EnvironmentConfig(
      environment: BabylAIEnvironment.production,
      enableLogging: enableLogging,
    );
  }

  /// Factory constructor for development configuration
  factory EnvironmentConfig.development({bool enableLogging = true}) {
    return EnvironmentConfig(
      environment: BabylAIEnvironment.development,
      enableLogging: enableLogging,
    );
  }

  /// Convert to map for method channel
  Map<String, dynamic> toMap() {
    return {'environment': environment.value, 'enableLogging': enableLogging};
  }

  /// Indicates whether in testing/development mode
  bool get isTestingMode => environment == BabylAIEnvironment.development;

  /// Indicates whether in production mode
  bool get isProduction => environment == BabylAIEnvironment.production;

  @override
  String toString() {
    return 'EnvironmentConfig(environment: $environment, enableLogging: $enableLogging)';
  }
}
