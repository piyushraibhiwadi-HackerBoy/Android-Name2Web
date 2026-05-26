import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/company_result.dart';
import '../models/blacklist_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  
  factory DatabaseService() => _instance;
  DatabaseService._internal();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'company_scraper.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE company_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company TEXT NOT NULL,
        websites TEXT,
        facebook TEXT,
        linkedin TEXT,
        emails TEXT,
        createdAt TEXT NOT NULL,
        isProcessed INTEGER DEFAULT 0
      )
    ''');
    
    await db.execute('''
      CREATE TABLE blacklist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        domain TEXT NOT NULL UNIQUE,
        addedAt TEXT NOT NULL
      )
    ''');
  }
  
  // Company Results Operations
  Future<int> insertCompanyResult(CompanyResult result) async {
    final db = await database;
    return await db.insert('company_results', result.toMap());
  }
  
  Future<List<CompanyResult>> getAllCompanyResults() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('company_results');
    return List.generate(maps.length, (i) => CompanyResult.fromMap(maps[i]));
  }
  
  Future<CompanyResult?> getCompanyResult(String company) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'company_results',
      where: 'company = ?',
      whereArgs: [company],
    );
    if (maps.isEmpty) return null;
    return CompanyResult.fromMap(maps.first);
  }
  
  Future<int> updateCompanyResult(CompanyResult result) async {
    final db = await database;
    return await db.update(
      'company_results',
      result.toMap(),
      where: 'company = ?',
      whereArgs: [result.company],
    );
  }
  
  Future<int> deleteCompanyResult(String company) async {
    final db = await database;
    return await db.delete(
      'company_results',
      where: 'company = ?',
      whereArgs: [company],
    );
  }
  
  Future<int> clearAllCompanyResults() async {
    final db = await database;
    return await db.delete('company_results');
  }
  
  // Blacklist Operations
  Future<int> insertBlacklistItem(BlacklistItem item) async {
    final db = await database;
    return await db.insert('blacklist', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<List<BlacklistItem>> getAllBlacklistItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('blacklist');
    return List.generate(maps.length, (i) => BlacklistItem.fromMap(maps[i]));
  }
  
  Future<Set<String>> getBlacklistDomains() async {
    final items = await getAllBlacklistItems();
    return items.map((item) => item.domain).toSet();
  }
  
  Future<int> deleteBlacklistItem(String domain) async {
    final db = await database;
    return await db.delete(
      'blacklist',
      where: 'domain = ?',
      whereArgs: [domain],
    );
  }
  
  Future<int> clearBlacklist() async {
    final db = await database;
    return await db.delete('blacklist');
  }
  
  Future<void> initializeDefaultBlacklist() async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM blacklist'));
    
    if (count == 0) {
      final defaultDomains = {
        'wikipedia.org', 'youtube.com', 'crunchbase.com', 'bloomberg.com',
        'dnb.com', 'zoominfo.com', 'opencorporates.com', 'yelp.com',
        'bbb.org', 'manta.com', 'chamber.com', 'yellowpages.com',
        'bizjournals.com', 'hoovers.com', 'spoke.com', 'zoom-info.com',
        'companieshouse.gov.uk', 'sec.gov', 'glassdoor.com', 'facebook.com',
        'linkedin.com', 'twitter.com', 'instagram.com', 'pinterest.com',
        'tiktok.com', 'reddit.com', 'quora.com', 'duckduckgo.com',
        'google.com', 'bing.com', 'yahoo.com', 'amazon.com', 'ebay.com',
      };
      
      final batch = db.batch();
      for (final domain in defaultDomains) {
        batch.insert('blacklist', BlacklistItem(domain: domain).toMap());
      }
      await batch.commit(noResult: true);
    }
  }
  
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
