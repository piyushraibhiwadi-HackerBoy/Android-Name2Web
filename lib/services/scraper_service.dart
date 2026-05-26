import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import '../models/company_result.dart';
import '../models/blacklist_item.dart';

class ScraperService {
  static const String _duckDuckGoUrl = 'https://html.duckduckgo.com/html/';
  static const int _requestTimeout = 30;
  
  final Set<String> _blacklist;
  final bool _extractEmails;
  final int _delaySeconds;
  final Function(String)? _onLog;

  ScraperService({
    Set<String>? blacklist,
    bool extractEmails = true,
    int delaySeconds = 2,
    Function(String)? onLog,
  })  : _blacklist = blacklist ?? {},
        _extractEmails = extractEmails,
        _delaySeconds = delaySeconds,
        _onLog = onLog;

  Future<CompanyResult> searchCompany(String company) async {
    _log('🔍 Searching for: $company');
    
    final result = CompanyResult(company: company);
    
    try {
      final searchQuery = Uri.encodeComponent('$company official website');
      final searchUrl = '$_duckDuckGoUrl?q=$searchQuery';
      
      final response = await http.get(
        Uri.parse(searchUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        },
      ).timeout(Duration(seconds: _requestTimeout));
      
      if (response.statusCode != 200) {
        _log('⚠ Failed to fetch search results: ${response.statusCode}');
        return result;
      }
      
      final document = parser.parse(response.body);
      final websites = <String>[];
      final seenDomains = <String>{};
      String facebook = '';
      String linkedin = '';
      final emails = <String>{};
      
      // Extract links from search results
      final resultLinks = document.querySelectorAll('a.result__a');
      
      for (final link in resultLinks) {
        final href = _cleanUrl(link.attributes['href'] ?? '');
        if (href.isEmpty || !href.startsWith('http')) continue;
        
        final hrefLower = href.toLowerCase();
        
        // Extract Facebook
        if (hrefLower.contains('facebook.com') && facebook.isEmpty) {
          if (hrefLower.contains('/pages/') || 
              hrefLower.contains('/profile') ||
              hrefLower.contains('facebook.com/') && !hrefLower.contains('login')) {
            facebook = href;
            continue;
          }
        }
        
        // Extract LinkedIn
        if (hrefLower.contains('linkedin.com') && linkedin.isEmpty) {
          if (hrefLower.contains('/company/') || 
              hrefLower.contains('/in/') ||
              hrefLower.contains('/school/')) {
            linkedin = href;
            continue;
          }
        }
        
        // Extract websites (not blacklisted)
        if (!_isBlacklisted(href)) {
          final domain = _extractDomain(href);
          if (domain.isNotEmpty && !seenDomains.contains(domain) && websites.length < 3) {
            websites.add(href);
            seenDomains.add(domain);
          }
        }
      }
      
      // Extract emails from search snippets
      if (_extractEmails) {
        final snippets = document.querySelectorAll('a.result__snippet');
        for (final snippet in snippets) {
          final email = _extractEmailFromText(snippet.text);
          if (email.isNotEmpty) {
            emails.add(email);
          }
        }
        
        // Extract emails from full page text
        if (emails.isEmpty) {
          final email = _extractEmailFromText(document.body?.text ?? '');
          if (email.isNotEmpty) {
            emails.add(email);
          }
        }
        
        // If no emails found, visit the first website
        if (emails.isEmpty && websites.isNotEmpty) {
          _log('🌐 Visiting website: ${websites[0]}');
          final websiteEmails = await _extractEmailsFromWebsite(websites[0]);
          emails.addAll(websiteEmails);
        }
      }
      
      // Update result
      return result.copyWith(
        websites: websites,
        facebook: facebook,
        linkedin: linkedin,
        emails: emails.toList(),
        isProcessed: true,
      );
      
    } catch (e) {
      _log('❌ Error searching for $company: $e');
      return result;
    }
  }
  
  Future<Set<String>> _extractEmailsFromWebsite(String url) async {
    final emails = <String>{};
    
    try {
      await Future.delayed(Duration(seconds: _delaySeconds));
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36',
        },
      ).timeout(Duration(seconds: _requestTimeout));
      
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final email = _extractEmailFromText(document.body?.text ?? '');
        if (email.isNotEmpty) {
          emails.add(email);
        }
        
        // Also check mailto links
        final mailtoLinks = document.querySelectorAll('a[href^="mailto:"]');
        for (final link in mailtoLinks) {
          final href = link.attributes['href'] ?? '';
          if (href.startsWith('mailto:')) {
            final email = href.replaceFirst('mailto:', '').split('?')[0].trim();
            if (email.isNotEmpty && _isValidEmail(email)) {
              emails.add(email);
            }
          }
        }
      }
    } catch (e) {
      _log('⚠ Error extracting emails from $url: $e');
    }
    
    return emails;
  }
  
  String _cleanUrl(String url) {
    if (url.contains('uddg=')) {
      final match = RegExp(r'uddg=([^&]+)').firstMatch(url);
      if (match != null) {
        return Uri.decodeComponent(match.group(1) ?? '');
      }
    }
    return url;
  }
  
  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.toLowerCase().replaceFirst('www.', '');
    } catch (e) {
      return '';
    }
  }
  
  bool _isBlacklisted(String url) {
    final domain = _extractDomain(url);
    for (final blacklisted in _blacklist) {
      if (domain.contains(blacklisted.toLowerCase())) {
        return true;
      }
    }
    return false;
  }
  
  String _extractEmailFromText(String text) {
    final emailPattern = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    final matches = emailPattern.allMatches(text);
    
    final invalid = ['example', 'test', 'sample', 'email', 'domain', 'yoursite', 
                   'company', 'website', 'sentry', 'webpack', 'wixpress', 'png', 'jpg', 'gif'];
    
    for (final match in matches) {
      final email = match.group(0) ?? '';
      if (!invalid.any((word) => email.toLowerCase().contains(word))) {
        if (email.length < 50 && email.contains('@') && email.contains('.')) {
          return email;
        }
      }
    }
    return '';
  }
  
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
  
  void _log(String message) {
    _onLog?.call(message);
  }
  
  void updateBlacklist(Set<String> newBlacklist) {
    _blacklist.clear();
    _blacklist.addAll(newBlacklist);
  }
}
