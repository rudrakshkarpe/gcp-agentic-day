import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/scheme.dart';
import '../services/api_service.dart';
import '../services/language_service.dart';

class GovernmentSchemesScreen extends StatefulWidget {
  final String selectedLanguage;
  
  const GovernmentSchemesScreen({Key? key, required this.selectedLanguage}) : super(key: key);
  
  @override
  _GovernmentSchemesScreenState createState() => _GovernmentSchemesScreenState();
}

class _GovernmentSchemesScreenState extends State<GovernmentSchemesScreen> {
  List<Scheme> schemes = [];
  bool isLoading = true;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSchemes();
  }

  Future<void> _loadSchemes() async {
    try {
      // For now, load dummy data. Later we'll connect to backend
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      
      setState(() {
        schemes = _getDummySchemes();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.selectedLanguage == 'kn' 
                ? 'ಯೋಜನೆಗಳನ್ನು ಲೋಡ್ ಮಾಡುವಲ್ಲಿ ದೋಷ'
                : 'Error loading schemes'
          ),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  List<Scheme> _getDummySchemes() {
    return [
      Scheme(
        id: '1',
        name: widget.selectedLanguage == 'kn' 
            ? 'PM ಕಿಸಾನ್ ಸಮ್ಮಾನ್ ನಿಧಿ'
            : 'PM Kisan Samman Nidhi',
        description: widget.selectedLanguage == 'kn'
            ? 'ವರ್ಷಕ್ಕೆ ₹6000 ನೇರ ಹಣ ವರ್ಗಾವಣೆ'
            : 'Direct cash transfer of ₹6000 per year',
        eligibility: widget.selectedLanguage == 'kn'
            ? '2 ಹೆಕ್ಟೇರ್ ವರೆಗೆ ಭೂಮಿ ಹೊಂದಿರುವ ರೈತರು'
            : 'Farmers with land holding up to 2 hectares',
        benefits: '₹6000/year',
        category: 'Financial Support',
        isActive: true,
      ),
      Scheme(
        id: '2',
        name: widget.selectedLanguage == 'kn' 
            ? 'ಕಿಸಾನ್ ಕ್ರೆಡಿಟ್ ಕಾರ್ಡ್'
            : 'Kisan Credit Card',
        description: widget.selectedLanguage == 'kn'
            ? 'ಕಡಿಮೆ ಬಡ್ಡಿದರದಲ್ಲಿ ಕೃಷಿ ಸಾಲ'
            : 'Agricultural loan at low interest rates',
        eligibility: widget.selectedLanguage == 'kn'
            ? 'ಎಲ್ಲಾ ರೈತರು'
            : 'All farmers',
        benefits: widget.selectedLanguage == 'kn'
            ? '4% ವಿ.ದ. ಬಡ್ಡಿದರ'
            : '4% p.a. interest rate',
        category: 'Credit',
        isActive: true,
      ),
      Scheme(
        id: '3',
        name: widget.selectedLanguage == 'kn' 
            ? 'ಪ್ರಧಾನ ಮಂತ್ರಿ ಫಸಲ್ ಬೀಮಾ ಯೋಜನೆ'
            : 'Pradhan Mantri Fasal Bima Yojana',
        description: widget.selectedLanguage == 'kn'
            ? 'ಬೆಳೆ ವಿಮೆ ಯೋಜನೆ'
            : 'Crop insurance scheme',
        eligibility: widget.selectedLanguage == 'kn'
            ? 'ಎಲ್ಲಾ ರೈತರು'
            : 'All farmers',
        benefits: widget.selectedLanguage == 'kn'
            ? 'ಬೆಳೆ ನಷ್ಟಕ್ಕೆ ಪರಿಹಾರ'
            : 'Compensation for crop loss',
        category: 'Insurance',
        isActive: true,
      ),
      Scheme(
        id: '4',
        name: widget.selectedLanguage == 'kn' 
            ? 'ರಾಷ್ಟ್ರೀಯ ಕೃಷಿ ಮಾರುಕಟ್ಟೆ'
            : 'National Agriculture Market (e-NAM)',
        description: widget.selectedLanguage == 'kn'
            ? 'ಆನ್‌ಲೈನ್ ಕೃಷಿ ಮಾರುಕಟ್ಟೆ'
            : 'Online agriculture marketplace',
        eligibility: widget.selectedLanguage == 'kn'
            ? 'ಎಲ್ಲಾ ರೈತರು'
            : 'All farmers',
        benefits: widget.selectedLanguage == 'kn'
            ? 'ಉತ್ತಮ ಬೆಲೆ ಪಡೆಯಿರಿ'
            : 'Get better prices',
        category: 'Marketing',
        isActive: true,
      ),
      Scheme(
        id: '5',
        name: widget.selectedLanguage == 'kn' 
            ? 'ಸಾವಯವ ಕೃಷಿ ಪ್ರೋತ್ಸಾಹ ಯೋಜನೆ'
            : 'Organic Farming Promotion Scheme',
        description: widget.selectedLanguage == 'kn'
            ? 'ಸಾವಯವ ಕೃಷಿಗೆ ಸಹಾಯಧನ'
            : 'Subsidy for organic farming',
        eligibility: widget.selectedLanguage == 'kn'
            ? 'ಸಾವಯವ ಕೃಷಿ ಮಾಡುವ ರೈತರು'
            : 'Farmers practicing organic farming',
        benefits: widget.selectedLanguage == 'kn'
            ? '50% ಸಹಾಯಧನ'
            : '50% subsidy',
        category: 'Subsidy',
        isActive: true,
      ),
    ];
  }

  List<Scheme> get filteredSchemes {
    if (searchQuery.isEmpty) return schemes;
    return schemes.where((scheme) => 
      scheme.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
      scheme.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
      scheme.category.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        final currentLanguage = languageService.selectedLanguage;
        
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: Text(
              currentLanguage == 'kn' ? 'ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು' : 'Government Schemes',
              style: currentLanguage == 'kn'
                  ? AppTheme.kannadaHeading.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                    )
                  : TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
            ),
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: currentLanguage == 'kn' 
                    ? 'ಯೋಜನೆಗಳನ್ನು ಹುಡುಕಿ...'
                    : 'Search schemes...',
                prefixIcon: Icon(Icons.search, color: AppTheme.primaryGreen),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryGreen),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          
          // Content
          Expanded(
            child: isLoading 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                        ),
                        SizedBox(height: 16),
                        Text(
                          currentLanguage == 'kn'
                              ? 'ಯೋಜನೆಗಳನ್ನು ಲೋಡ್ ಮಾಡಲಾಗುತ್ತಿದೆ...'
                              : 'Loading schemes...',
                          style: AppTheme.kannadaBody.copyWith(
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  )
                : filteredSchemes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: AppTheme.secondaryText,
                            ),
                            SizedBox(height: 16),
                            Text(
                              currentLanguage == 'kn'
                                  ? 'ಯಾವುದೇ ಯೋಜನೆಗಳು ಕಂಡುಬಂದಿಲ್ಲ'
                                  : 'No schemes found',
                              style: AppTheme.kannadaBody.copyWith(
                                color: AppTheme.secondaryText,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: filteredSchemes.length,
                        itemBuilder: (context, index) {
                          final scheme = filteredSchemes[index];
                          return _buildSchemeCard(scheme);
                        },
                      ),
          ),
        ],
      ),
        );
      },
    );
  }

  Widget _buildSchemeCard(Scheme scheme) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showSchemeDetails(scheme),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(scheme.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      scheme.category,
                      style: TextStyle(
                        color: _getCategoryColor(scheme.category),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: scheme.isActive ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    scheme.isActive 
                        ? (widget.selectedLanguage == 'kn' ? 'ಸಕ್ರಿಯ' : 'Active')
                        : (widget.selectedLanguage == 'kn' ? 'ನಿಷ್ಕ್ರಿಯ' : 'Inactive'),
                    style: TextStyle(
                      color: scheme.isActive ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              Text(
                scheme.name,
                style: widget.selectedLanguage == 'kn'
                    ? AppTheme.kannadaHeading.copyWith(
                        fontSize: 18,
                        color: AppTheme.primaryGreen,
                      )
                    : TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
              ),
              
              SizedBox(height: 8),
              
              Text(
                scheme.description,
                style: widget.selectedLanguage == 'kn'
                    ? AppTheme.kannadaBody.copyWith(
                        color: AppTheme.secondaryText,
                      )
                    : TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 14,
                      ),
              ),
              
              SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: AppTheme.accentOrange,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    scheme.benefits,
                    style: TextStyle(
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.secondaryText,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'financial support':
      case 'financial':
        return AppTheme.accentOrange;
      case 'credit':
        return AppTheme.accentBlue;
      case 'insurance':
        return AppTheme.accentPurple;
      case 'marketing':
        return Colors.teal;
      case 'subsidy':
        return Colors.indigo;
      default:
        return AppTheme.primaryGreen;
    }
  }

  void _showSchemeDetails(Scheme scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                
                Text(
                  scheme.name,
                  style: widget.selectedLanguage == 'kn'
                      ? AppTheme.kannadaHeading.copyWith(
                          fontSize: 24,
                          color: AppTheme.primaryGreen,
                        )
                      : TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                ),
                
                SizedBox(height: 16),
                
                _buildDetailRow(
                  widget.selectedLanguage == 'kn' ? 'ವಿವರ' : 'Description',
                  scheme.description,
                ),
                
                _buildDetailRow(
                  widget.selectedLanguage == 'kn' ? 'ಅರ್ಹತೆ' : 'Eligibility',
                  scheme.eligibility,
                ),
                
                _buildDetailRow(
                  widget.selectedLanguage == 'kn' ? 'ಪ್ರಯೋಜನಗಳು' : 'Benefits',
                  scheme.benefits,
                ),
                
                _buildDetailRow(
                  widget.selectedLanguage == 'kn' ? 'ವರ್ಗ' : 'Category',
                  scheme.category,
                ),
                
                SizedBox(height: 24),
                
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applyForScheme(scheme);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.selectedLanguage == 'kn' 
                          ? 'ಅರ್ಜಿ ಸಲ್ಲಿಸಿ'
                          : 'Apply Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: widget.selectedLanguage == 'kn'
                ? AppTheme.kannadaSubheading.copyWith(
                    color: AppTheme.primaryGreen,
                  )
                : TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                  ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: widget.selectedLanguage == 'kn'
                ? AppTheme.kannadaBody
                : TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _applyForScheme(Scheme scheme) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.selectedLanguage == 'kn'
              ? '${scheme.name} ಗಾಗಿ ಅರ್ಜಿ ಪ್ರಕ್ರಿಯೆ ಪ್ರಾರಂಭವಾಗಿದೆ'
              : 'Application process started for ${scheme.name}',
        ),
        backgroundColor: AppTheme.primaryGreen,
        action: SnackBarAction(
          label: widget.selectedLanguage == 'kn' ? 'ವೀಕ್ಷಿಸಿ' : 'View',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Navigate to application form
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
