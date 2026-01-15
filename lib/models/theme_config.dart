class ThemeConfig {
  final String? primaryColorHex;
  final String? secondaryColorHex;
  final String? primaryColorDarkHex;
  final String? secondaryColorDarkHex;
  final String? headerLogo;

  /// Custom logo symbol for small spaces like chat avatars.
  /// If null, falls back to headerLogo, then default.
  final String? logoSymbol;

  const ThemeConfig({
    this.primaryColorHex,
    this.secondaryColorHex,
    this.primaryColorDarkHex,
    this.secondaryColorDarkHex,
    this.headerLogo,
    this.logoSymbol,
  });

  Map<String, String> toMap() {
    final map = <String, String>{};
    if (primaryColorHex != null) map['primaryColorHex'] = primaryColorHex!;
    if (secondaryColorHex != null) {
      map['secondaryColorHex'] = secondaryColorHex!;
    }
    if (primaryColorDarkHex != null) {
      map['primaryColorDarkHex'] = primaryColorDarkHex!;
    }
    if (secondaryColorDarkHex != null) {
      map['secondaryColorDarkHex'] = secondaryColorDarkHex!;
    }
    if (headerLogo != null) map['headerLogo'] = headerLogo!;
    if (logoSymbol != null) map['logoSymbol'] = logoSymbol!;
    return map;
  }
}
