import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/scraping_progress.dart';
import '../services/scraper_service.dart';
import '../services/database_service.dart';
import '../models/company_result.dart';
import 'results_screen.dart';
import 'blacklist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _companyController = TextEditingController();
  final ScrollController _logController = ScrollController();
  final List<String> _logs = [];
  
  ScrapingProgress _progress = ScrapingProgress(
    totalCompanies: 0,
    processedCompanies: 0,
    remainingCompanies: 0,
  );
  
  bool _isRunning = false;
  bool _isPaused = false;
  bool _extractEmails = true;
  int _delaySeconds = 2;
  Set<String> _blacklist = {};
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    final dbService = DatabaseService();
    await dbService.initializeDefaultBlacklist();
    _blacklist = await dbService.getBlacklistDomains();
    setState(() {});
  }
  
  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
    _logController.animateTo(
      _logController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
  
  Future<void> _startScraping() async {
    if (_companyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter company names')),
      );
      return;
    }
    
    final companies = _companyController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    
    if (companies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid company names found')),
      );
      return;
    }
    
    setState(() {
      _isRunning = true;
      _isPaused = false;
      _progress = ScrapingProgress(
        totalCompanies: companies.length,
        processedCompanies: 0,
        remainingCompanies: companies.length,
        isRunning: true,
      );
      _logs.clear();
    });
    
    _addLog('🚀 Starting scraping for ${companies.length} companies');
    
    final dbService = DatabaseService();
    final scraperService = ScraperService(
      blacklist: _blacklist,
      extractEmails: _extractEmails,
      delaySeconds: _delaySeconds,
      onLog: _addLog,
    );
    
    for (int i = 0; i < companies.length; i++) {
      if (!_isRunning) break;
      
      while (_isPaused) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!_isRunning) break;
      }
      
      if (!_isRunning) break;
      
      final company = companies[i];
      setState(() {
        _progress = _progress.copyWith(
          currentCompany: company,
          processedCompanies: i,
          remainingCompanies: companies.length - i,
        );
      });
      
      final result = await scraperService.searchCompany(company);
      
      final existingResult = await dbService.getCompanyResult(company);
      if (existingResult != null) {
        await dbService.updateCompanyResult(result);
      } else {
        await dbService.insertCompanyResult(result);
      }
      
      setState(() {
        _progress = _progress.copyWith(
          processedCompanies: i + 1,
          remainingCompanies: companies.length - (i + 1),
        );
      });
      
      _addLog('✓ Completed: $company (${result.emails.length} emails found)');
    }
    
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _progress = _progress.copyWith(
        isRunning: false,
        currentCompany: '',
      );
    });
    
    _addLog('🎉 Scraping completed!');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scraping completed!')),
      );
    }
  }
  
  void _pauseScraping() {
    setState(() {
      _isPaused = !_isPaused;
      _progress = _progress.copyWith(isPaused: _isPaused);
    });
    _addLog(_isPaused ? '⏸ Scraping paused' : '▶ Scraping resumed');
  }
  
  void _stopScraping() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _progress = _progress.copyWith(
        isRunning: false,
        isPaused: false,
        currentCompany: '',
      );
    });
    _addLog('⏹ Scraping stopped');
  }
  
  void _clearAll() async {
    final dbService = DatabaseService();
    await dbService.clearAllCompanyResults();
    setState(() {
      _companyController.clear();
      _logs.clear();
      _progress = ScrapingProgress(
        totalCompanies: 0,
        processedCompanies: 0,
        remainingCompanies: 0,
      );
    });
    _addLog('🗑 All data cleared');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Email Scraper'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ResultsScreen()),
              );
            },
            tooltip: 'View Results',
          ),
          IconButton(
            icon: const Icon(Icons.block),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BlacklistScreen()),
              ).then((_) => _initializeData());
            },
            tooltip: 'Manage Blacklist',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Company Names',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _companyController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Enter company names, one per line...\n\nExample:\nApple Inc\nMicrosoft Corporation\nGoogle LLC',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Stats Section
            Row(
              children: [
                _buildStatCard('Total', '${_progress.totalCompanies}', Colors.blue),
                const SizedBox(width: 8),
                _buildStatCard('Processed', '${_progress.processedCompanies}', Colors.green),
                const SizedBox(width: 8),
                _buildStatCard('Remaining', '${_progress.remainingCompanies}', Colors.orange),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Settings Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Extract Emails:'),
                        const SizedBox(width: 8),
                        Switch(
                          value: _extractEmails,
                          onChanged: (value) {
                            setState(() {
                              _extractEmails = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Delay (seconds):'),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 60,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            controller: TextEditingController(
                              text: '$_delaySeconds',
                            )..selection = TextSelection.fromPosition(
                                TextPosition(offset: '$_delaySeconds'.length),
                              ),
                            onChanged: (value) {
                              final delay = int.tryParse(value);
                              if (delay != null && delay > 0) {
                                setState(() {
                                  _delaySeconds = delay;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Control Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRunning ? null : _startScraping,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('▶ START'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRunning ? _pauseScraping : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_isPaused ? '▶ RESUME' : '⏸ PAUSE'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRunning ? _stopScraping : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('⏹ STOP'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('🗑 CLEAR ALL'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress Bar
            if (_progress.totalCompanies > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: _progress.progressPercentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _progress.isPaused ? Colors.orange : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_progress.processedCompanies} / ${_progress.totalCompanies} (${(_progress.progressPercentage * 100).toStringAsFixed(1)}%)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_progress.currentCompany.isNotEmpty)
                    Text(
                      'Current: ${_progress.currentCompany}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Log Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live Log',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        controller: _logController,
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            child: Text(
                              _logs[index],
                              style: const TextStyle(
                                color: Colors.green,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _companyController.dispose();
    _logController.dispose();
    super.dispose();
  }
}
