class ChatResponse {
  final String response;
  final String? audioUrl;
  final List<String> toolsUsed;
  final String conversationId;
  final double? confidence;
  final DateTime timestamp;

  ChatResponse({
    required this.response,
    this.audioUrl,
    this.toolsUsed = const [],
    required this.conversationId,
    this.confidence,
    required this.timestamp,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      response: json['response'] ?? '',
      audioUrl: json['audio_url'],
      toolsUsed: json['tools_used'] != null 
          ? List<String>.from(json['tools_used'])
          : [],
      conversationId: json['conversation_id'] ?? '',
      confidence: json['confidence']?.toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}

class VoiceResponse {
  final String transcript;
  final String response;
  final String? audioUrl;
  final List<String> toolsUsed;
  final String conversationId;
  final double? confidence;

  VoiceResponse({
    required this.transcript,
    required this.response,
    this.audioUrl,
    this.toolsUsed = const [],
    required this.conversationId,
    this.confidence,
  });

  factory VoiceResponse.fromJson(Map<String, dynamic> json) {
    return VoiceResponse(
      transcript: json['transcript'] ?? '',
      response: json['response'] ?? '',
      audioUrl: json['audio_url'],
      toolsUsed: json['tools_used'] != null 
          ? List<String>.from(json['tools_used'])
          : [],
      conversationId: json['conversation_id'] ?? '',
      confidence: json['confidence']?.toDouble(),
    );
  }
}

class ImageDiagnosisResponse {
  final String diagnosis;
  final String? diseaseName;
  final String? severity;
  final List<String> treatment;
  final List<String> organicRemedies;
  final List<String> chemicalTreatment;
  final List<String> prevention;
  final double confidence;
  final String? audioUrl;

  ImageDiagnosisResponse({
    required this.diagnosis,
    this.diseaseName,
    this.severity,
    this.treatment = const [],
    this.organicRemedies = const [],
    this.chemicalTreatment = const [],
    this.prevention = const [],
    required this.confidence,
    this.audioUrl,
  });

  factory ImageDiagnosisResponse.fromJson(Map<String, dynamic> json) {
    return ImageDiagnosisResponse(
      diagnosis: json['diagnosis'] ?? '',
      diseaseName: json['disease_name'],
      severity: json['severity'],
      treatment: json['treatment'] != null 
          ? List<String>.from(json['treatment'])
          : [],
      organicRemedies: json['organic_remedies'] != null 
          ? List<String>.from(json['organic_remedies'])
          : [],
      chemicalTreatment: json['chemical_treatment'] != null 
          ? List<String>.from(json['chemical_treatment'])
          : [],
      prevention: json['prevention'] != null 
          ? List<String>.from(json['prevention'])
          : [],
      confidence: json['confidence']?.toDouble() ?? 0.0,
      audioUrl: json['audio_url'],
    );
  }
}

class MarketPriceResponse {
  final String commodity;
  final double currentPrice;
  final String unit;
  final String market;
  final String trend;
  final double? lastWeekPrice;
  final String recommendation;
  final String? bestSellingTime;
  final String updatedAt;

  MarketPriceResponse({
    required this.commodity,
    required this.currentPrice,
    required this.unit,
    required this.market,
    required this.trend,
    this.lastWeekPrice,
    required this.recommendation,
    this.bestSellingTime,
    required this.updatedAt,
  });

  factory MarketPriceResponse.fromJson(Map<String, dynamic> json) {
    return MarketPriceResponse(
      commodity: json['commodity'] ?? '',
      currentPrice: json['current_price']?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      market: json['market'] ?? '',
      trend: json['trend'] ?? '',
      lastWeekPrice: json['last_week_price']?.toDouble(),
      recommendation: json['recommendation'] ?? '',
      bestSellingTime: json['best_selling_time'],
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class GovernmentSchemeResponse {
  final String schemeName;
  final String description;
  final List<String> eligibility;
  final List<String> benefits;
  final List<String> applicationProcess;
  final List<String> requiredDocuments;
  final String? contactInfo;
  final String? onlineLink;
  final String? deadline;

  GovernmentSchemeResponse({
    required this.schemeName,
    required this.description,
    this.eligibility = const [],
    this.benefits = const [],
    this.applicationProcess = const [],
    this.requiredDocuments = const [],
    this.contactInfo,
    this.onlineLink,
    this.deadline,
  });

  factory GovernmentSchemeResponse.fromJson(Map<String, dynamic> json) {
    return GovernmentSchemeResponse(
      schemeName: json['scheme_name'] ?? '',
      description: json['description'] ?? '',
      eligibility: json['eligibility'] != null 
          ? List<String>.from(json['eligibility'])
          : [],
      benefits: json['benefits'] != null 
          ? List<String>.from(json['benefits'])
          : [],
      applicationProcess: json['application_process'] != null 
          ? List<String>.from(json['application_process'])
          : [],
      requiredDocuments: json['required_documents'] != null 
          ? List<String>.from(json['required_documents'])
          : [],
      contactInfo: json['contact_info'],
      onlineLink: json['online_link'],
      deadline: json['deadline'],
    );
  }
}
