import 'package:flutter/material.dart';
import 'package:voyant/widgets/animated_gradient_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  //underscore to make them all private variables 
  //variables set to private here mostly for security reasons 

  bool _isLoading = false;
  String? _currentCode; //business code will be stored here
  DateTime? _codeExpiresAt;
  int _redemptions = 0; //amount of redemptions
  int _maxRedemptions = 10;
  int _refreshCount = 0;
  int _maxRefreshes = 10;
  int _dailyRedemptions = 0;
  int _totalRedemptions = 0;

  //code expiration 
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

//loading data from local storage 
  @override
  void initState() {
    super.initState();
    _loadPartnerData();
  }

  Future<void> _loadPartnerData() async {
    try {

      //temporarily using local memory instead of firestore 
      final prefs = await SharedPreferences.getInstance();
      
      // Load data from local storage
      final currentCode = prefs.getString('currentCode') ?? '';
      final expiresAtMillis = prefs.getInt('codeExpiresAt');
      final redemptions = prefs.getInt('redemptions') ?? 0;
      final refreshCount = prefs.getInt('refreshCount') ?? 0;
      final dailyRedemptions = prefs.getInt('dailyRedemptions') ?? 0;
      final totalRedemptions = prefs.getInt('totalRedemptions') ?? 0;
      
      setState(() {
        _currentCode = currentCode;
        _codeExpiresAt = expiresAtMillis != null ? DateTime.fromMillisecondsSinceEpoch(expiresAtMillis) : null;
        _redemptions = redemptions;
        _maxRedemptions = 10;
        _refreshCount = refreshCount;
        _maxRefreshes = 10;
        _dailyRedemptions = dailyRedemptions;
        _totalRedemptions = totalRedemptions;
      });
      
      //it will auto initialize the dashboard if no pre existing code 
      if (_currentCode == null || _currentCode?.isEmpty == true) {
        // Generate initial code automatically
        final newCode = _generate6DigitCode();
        final expiresAt = DateTime.now().add(const Duration(hours: 24));
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentCode', newCode);
        await prefs.setInt('codeExpiresAt', expiresAt.millisecondsSinceEpoch);
        await prefs.setInt('redemptions', 0);
        await prefs.setInt('maxRedemptionsPerCode', 10);
        await prefs.setInt('refreshCount', 0);
        await prefs.setInt('refreshLimitPerHour', 10);
        await prefs.setInt('dailyRedemptions', 0);
        await prefs.setInt('totalRedemptions', 0);
        await prefs.setString('createdAt', DateTime.now().toIso8601String());
        
        setState(() {
          _currentCode = newCode;
          _codeExpiresAt = expiresAt;
          _redemptions = 0;
          _maxRedemptions = 10;
          _refreshCount = 0;
          _maxRefreshes = 10;
          _dailyRedemptions = 0;
          _totalRedemptions = 0;
        });
        
        showSuccess('Dashboard initialized successfully!');
      }
      
    } catch (e) {
      showError('Failed to load data: $e');
    }
  }



  //code generation 
  //this will be done by frontend for now 
  String _generate6DigitCode() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (random % 900000 + 100000).toString();
  }

  Future<void> _refreshCode() async {
    setState(() => _isLoading = true);
    try {
      //Checking refresh limit
      if (_refreshCount >= _maxRefreshes) {
        showError('Refresh limit reached. Please wait.');
        return;
      }
      
      //generating new code
      final newCode = _generate6DigitCode();
      final expiresAt = DateTime.now().add(const Duration(hours: 24));
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('currentCode', newCode);
      await prefs.setInt('codeExpiresAt', expiresAt.millisecondsSinceEpoch);
      await prefs.setInt('refreshCount', _refreshCount + 1);
      await prefs.setString('lastRefreshAt', DateTime.now().toIso8601String());
      
      await _loadPartnerData();
      showSuccess('Code refreshed successfully!');
      

    } catch (e) {
      showError('Refresh failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  //red snackbar for errorspups 
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red), 
    );
  }

//successs popups  
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Business Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6366F1).withOpacity(0.1),
                const Color(0xFF4A148C).withOpacity(0.1),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF6366F1).withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),
      body: AnimatedGradientBackground(
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //header card 
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.1),
                          const Color(0xFF4A148C).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                        width: 1,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        Row(
                          children: [
                            //icon for dasboard
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFF4A148C)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4A148C).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              
                              child: const Icon(
                                Icons.storefront,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            
                            const SizedBox(width: 20),
                            
                            //text in header
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Business Dashboard',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Manage your promotional codes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_currentCode != null && _currentCode?.isNotEmpty == true) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF6366F1).withOpacity(0.1),
                            const Color(0xFF4A148C).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Code',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF6366F1).withOpacity(0.05),
                                  const Color(0xFF4A148C).withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isCodeExpired
                                    ? Colors.grey.withOpacity(0.3)
                                    : const Color(0xFF6366F1).withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _currentCode ?? 'No Code',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4,
                                    color: _isCodeExpired
                                        ? Colors.grey
                                        : const Color(0xFF6366F1),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isCodeExpired
                                      ? 'Expired'
                                      : 'Expires in $_timeRemaining',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _refreshCount < _maxRefreshes
                                  ? _refreshCode
                                  : null,
                              child: Text(
                                _refreshCount >= _maxRefreshes
                                    ? 'Refresh Limit Reached'
                                    : 'Refresh Code',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.1),
                          const Color(0xFF4A148C).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Statistics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                                const Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Refreshes',
                                '$_refreshCount/$_maxRefreshes',
                                Icons.refresh,
                                const Color(0xFF6366F1),
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
                                const Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Total',
                                '$_totalRedemptions',
                                Icons.assessment,
                                const Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
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
