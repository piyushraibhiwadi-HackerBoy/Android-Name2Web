import '../models/blacklist_item.dart';
import '../services/database_service.dart';

class BlacklistService {
  final DatabaseService _databaseService = DatabaseService();
  
  Future<List<BlacklistItem>> getBlacklist() async {
    return await _databaseService.getAllBlacklistItems();
  }
  
  Future<Set<String>> getBlacklistDomains() async {
    return await _databaseService.getBlacklistDomains();
  }
  
  Future<void> addDomain(String domain) async {
    final item = BlacklistItem(domain: domain.toLowerCase().trim());
    await _databaseService.insertBlacklistItem(item);
  }
  
  Future<void> removeDomain(String domain) async {
    await _databaseService.deleteBlacklistItem(domain.toLowerCase());
  }
  
  Future<void> clearAll() async {
    await _databaseService.clearBlacklist();
  }
  
  Future<void> initializeDefault() async {
    await _databaseService.initializeDefaultBlacklist();
  }
}
