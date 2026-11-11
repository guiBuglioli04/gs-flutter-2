import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de persistência local utilizando SharedPreferences
class StorageService {
  static const String _keyDontShowOnboarding = 'sp_dont_show_onboarding';
  static const String _keyFavorites = 'sp_favorite_protocols';
  static const String _keyOfflineSync = 'sp_offline_sync_enabled';

  /// Verifica se o usuário marcou para não exibir o onboarding novamente
  static Future<bool> shouldSkipOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyDontShowOnboarding) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Salva a preferência do usuário sobre o onboarding
  static Future<void> setDontShowOnboarding(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyDontShowOnboarding, value);
    } catch (_) {}
  }

  /// Limpa a preferência do onboarding (útil para testes da banca)
  static Future<void> resetOnboardingPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyDontShowOnboarding);
    } catch (_) {}
  }

  /// Obtém a lista de protocolos favoritos
  static Future<List<String>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_keyFavorites) ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Salva a lista de favoritos
  static Future<void> saveFavorites(List<String> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyFavorites, favorites);
    } catch (_) {}
  }

  /// Modo Offline-First
  static Future<bool> isOfflineMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyOfflineSync) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setOfflineMode(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyOfflineSync, value);
    } catch (_) {}
  }
}
