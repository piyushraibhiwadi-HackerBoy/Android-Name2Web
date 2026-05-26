import 'dart:convert';
import 'package:csv/csv.dart';
import '../models/company_result.dart';

class ExportService {
  static Future<List<int>> exportToCSV(List<CompanyResult> results) async {
    final List<List<String>> rows = [];
    
    // Header
    rows.add([
      'Company',
      'Website 1',
      'Website 2',
      'Website 3',
      'Facebook',
      'LinkedIn',
      'Emails',
      'Scraped Date',
    ]);
    
    // Data rows
    for (final result in results) {
      rows.add([
        result.company,
        result.websites.isNotEmpty ? result.websites[0] : '',
        result.websites.length > 1 ? result.websites[1] : '',
        result.websites.length > 2 ? result.websites[2] : '',
        result.facebook,
        result.linkedin,
        result.emails.join('; '),
        result.createdAt.toIso8601String(),
      ]);
    }
    
    final csvData = const ListToCsvConverter().convert(rows);
    return utf8.encode(csvData);
  }
  
  static Future<List<int>> exportToJSON(List<CompanyResult> results) async {
    final List<Map<String, dynamic>> jsonData = [];
    
    for (final result in results) {
      jsonData.add({
        'company': result.company,
        'websites': result.websites,
        'facebook': result.facebook,
        'linkedin': result.linkedin,
        'emails': result.emails,
        'scrapedDate': result.createdAt.toIso8601String(),
      });
    }
    
    final jsonString = jsonEncode(jsonData);
    return utf8.encode(jsonString);
  }
}
