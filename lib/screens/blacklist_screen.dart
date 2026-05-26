import 'package:flutter/material.dart';
import '../services/blacklist_service.dart';
import '../models/blacklist_item.dart';

class BlacklistScreen extends StatefulWidget {
  const BlacklistScreen({super.key});

  @override
  State<BlacklistScreen> createState() => _BlacklistScreenState();
}

class _BlacklistScreenState extends State<BlacklistScreen> {
  final BlacklistService _blacklistService = BlacklistService();
  final TextEditingController _domainController = TextEditingController();
  final List<BlacklistItem> _blacklistItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlacklist();
  }

  Future<void> _loadBlacklist() async {
    setState(() => _isLoading = true);
    final items = await _blacklistService.getBlacklist();
    setState(() {
      _blacklistItems.clear();
      _blacklistItems.addAll(items);
      _isLoading = false;
    });
  }

  Future<void> _addDomain() async {
    final domain = _domainController.text.trim();
    if (domain.isEmpty) return;

    await _blacklistService.addDomain(domain);
    _domainController.clear();
    await _loadBlacklist();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $domain to blacklist')),
      );
    }
  }

  Future<void> _removeDomain(BlacklistItem item) async {
    await _blacklistService.removeDomain(item.domain);
    await _loadBlacklist();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed ${item.domain} from blacklist')),
      );
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Blacklist'),
        content: const Text('Are you sure you want to clear all blacklist items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _blacklistService.clearAll();
      await _loadBlacklist();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Blacklist cleared')),
        );
      }
    }
  }

  Future<void> _resetToDefault() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Default'),
        content: const Text('Reset blacklist to default domains?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _blacklistService.clearAll();
      await _blacklistService.initializeDefault();
      await _loadBlacklist();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Blacklist reset to default')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Domain Blacklist'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Add Domain Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _domainController,
                    decoration: InputDecoration(
                      hintText: 'Enter domain (e.g., example.com)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) => _addDomain(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addDomain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('ADD'),
                ),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetToDefault,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('RESET TO DEFAULT'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('CLEAR ALL'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Blacklist List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _blacklistItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.block, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No domains in blacklist',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _blacklistItems.length,
                        itemBuilder: (context, index) {
                          final item = _blacklistItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.block, color: Colors.red),
                              title: Text(item.domain),
                              subtitle: Text(
                                'Added: ${item.addedAt.toString().substring(0, 19)}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeDomain(item),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }
}
