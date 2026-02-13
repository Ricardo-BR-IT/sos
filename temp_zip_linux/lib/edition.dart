enum SosEdition { mini, standard, server }

class EditionConfig {
  static const String _rawEdition =
      String.fromEnvironment('EDITION', defaultValue: 'standard');

  static SosEdition get current {
    switch (_rawEdition.toLowerCase()) {
      case 'mini':
        return SosEdition.mini;
      case 'server':
        return SosEdition.server;
      default:
        return SosEdition.standard;
    }
  }

  static String get label => current.name;
}

