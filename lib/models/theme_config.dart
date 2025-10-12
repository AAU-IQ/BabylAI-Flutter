class ThemeConfig {
  final String? primaryColorHex;
  final String? secondaryColorHex;
  final String? primaryColorDarkHex;
  final String? secondaryColorDarkHex;
  final String? headerLogo;

  const ThemeConfig({
    this.primaryColorHex,
    this.secondaryColorHex,
    this.primaryColorDarkHex,
    this.secondaryColorDarkHex,
    this.headerLogo,
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
    return map;
  }
}
