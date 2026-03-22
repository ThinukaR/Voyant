import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  //underscore to make them all private variables 
  //variables set to private here mostly for security reasons 
  final TextEditingController _codeController = TextEditingController();
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _currentCode; //business code will be stored here
  DateTime? _codeExpiresAt;
  int _redemptions = 0; //amount of redemptions
  int _maxRedemptions = 10;
  int _refreshCount = 0;
  int _maxRefreshes = 10;
  int _dailyRedemptions = 0;
  int _totalRedemptions = 0;

//loading data from firestore 
  @override
  void initState() {
    super.initState();
    _loadPartnerData();
  } 


//disposing controller to stop memory leaks 
  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadPartnerData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return; //exits out if user is not logged

      final doc = await _firestore.collection('business_partner_data').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _currentCode = data['currentCode'] ?? '';
          _codeExpiresAt = (data['codeExpiresAt'] as Timestamp?)?.toDate();
          _redemptions = data['redemptions'] ?? 0;
          _maxRedemptions = data['maxRedemptionsPerCode'] ?? 10;
          _refreshCount = data['refreshCount'] ?? 0;
          _maxRefreshes = data['refreshLimitPerHour'] ?? 10;
          _dailyRedemptions = data['dailyRedemptions'] ?? 0;
          _totalRedemptions = data['totalRedemptions'] ?? 0;
        });
      }
    } catch (e) {
      showError('Failed to load data from firebase: $e');
    }
  }

  Future<void> _initializeDashboard() async {
    setState(() => _isLoading = true);
    try {
      final result = await _functions.httpsCallable('initBusinessPartnerDashboard').call();
      if (result.data['success']) { //if backend is sucessfully called 
        await _loadPartnerData();
        showSuccess('Dashboard initialized successfully!');
      }
    } catch (e) {
      showError('Initialization failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshCode() async {
    setState(() => _isLoading = true);
    try {
      final result = await _functions.httpsCallable('refreshBusinessPartnerCode').call();
      if (result.data['success']) {
        await _loadPartnerData();
        showSuccess('Code refreshed successfully!');
      }
    } catch (e) {
      showError('Refresh failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _redeemCode() async {
    if (_codeController.text.length != 6) {
      showError('Please enter a 6 digit code');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _functions.httpsCallable('redeemQuestCode').call({
        'code': _codeController.text,
      });
      if (result.data['success']) {
        showSuccess('Code redeemed');
        _codeController.clear();
        await _loadPartnerData();
      }
    } catch (e) {
      showError('Code failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

//red snackbar for errors
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red), 
    );
  }

//green snackbar for success 
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  bool get _isCodeExpired {
    if (_codeExpiresAt == null) return true;
    return DateTime.now().isAfter(_codeExpiresAt!);
  }

  String get _timeRemaining {
    if (_codeExpiresAt == null) return 'Expired';
    final difference = _codeExpiresAt!.difference(DateTime.now());
    if (difference.isNegative) return 'Expired';
    final minutes = difference.inMinutes;
    final seconds = difference.inSeconds % 60;
    return '$minutes min $seconds sec';
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Business Integration'),
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage your codes',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (_currentCode == null || _currentCode!.isEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Initialize your dashboard to start generating codes.',
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _initializeDashboard,
                              child: const Text('Initialize Dashboard'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_currentCode != null && _currentCode!.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Code',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _isCodeExpired
                                  ? Colors.grey[100]
                                  : Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isCodeExpired
                                    ? Colors.grey
                                    : Colors.blue,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _currentCode!,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4,
                                    color: _isCodeExpired
                                        ? Colors.grey
                                        : Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isCodeExpired
                                      ? 'Expired'
                                      : 'Expires in $_timeRemaining',
                                  style: TextStyle(
                                    color: _isCodeExpired
                                        ? Colors.grey
                                        : Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _refreshCount < _maxRefreshes
                                  ? _refreshCode
                                  : null,
                              child: Text(
                                _refreshCount >= _maxRefreshes
                                    ? 'Refresh Limit Reached'
                                    : 'Refresh Code',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Statistics',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Redemptions',
                                  '$_redemptions/$_maxRedemptions',
                                  Icons.people,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Refreshes',
                                  '$_refreshCount/$_maxRefreshes',
                                  Icons.refresh,
                                  Colors.blue,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Daily',
                                  '$_dailyRedemptions',
                                  Icons.today,
                                  Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Total',
                                  '$_totalRedemptions',
                                  Icons.assessment,
                                  Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Redeem Code',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: const InputDecoration(
                              labelText: 'Enter 6-digit code',
                              hintText: '123456',
                              border: OutlineInputBorder(),
                              counterText: '',
                            ),
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _codeController.text.length == 6 &&
                                      !_isLoading
                                  ? _redeemCode
                                  : null,
                              child: const Text('Redeem Code'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
  );
}

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
