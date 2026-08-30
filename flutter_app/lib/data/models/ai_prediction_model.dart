/// AI Adherence-Risk Prediction entity generated from ML Microservice.
class AiPredictionModel {
  final String predictionId;
  final String patientId;
  final String riskLevel; // 'LOW', 'MEDIUM', 'HIGH'
  final double riskScore; // 0.0 - 1.0
  final double confidence; // 0.0 - 1.0
  final String explanation;
  final DateTime generatedAt;

  const AiPredictionModel({
    required this.predictionId,
    required this.patientId,
    required this.riskLevel,
    required this.riskScore,
    required this.confidence,
    required this.explanation,
    required this.generatedAt,
  });

  bool get isLowRisk => riskLevel.toUpperCase() == 'LOW';
  bool get isMediumRisk => riskLevel.toUpperCase() == 'MEDIUM';
  bool get isHighRisk => riskLevel.toUpperCase() == 'HIGH';

  Map<String, dynamic> toMap() {
    return {
      'predictionId': predictionId,
      'patientId': patientId,
      'riskLevel': riskLevel,
      'riskScore': riskScore,
      'confidence': confidence,
      'explanation': explanation,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory AiPredictionModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return AiPredictionModel(
      predictionId: documentId ?? map['predictionId'] as String? ?? '',
      patientId: map['patientId'] as String? ?? '',
      riskLevel: map['riskLevel'] as String? ?? 'LOW',
      riskScore: (map['riskScore'] as num?)?.toDouble() ?? 0.1,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.9,
      explanation: map['explanation'] as String? ??
          'Medication adherence has remained stable over the past 14 days.',
      generatedAt: map['generatedAt'] != null
          ? DateTime.tryParse(map['generatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  AiPredictionModel copyWith({
    String? predictionId,
    String? patientId,
    String? riskLevel,
    double? riskScore,
    double? confidence,
    String? explanation,
    DateTime? generatedAt,
  }) {
    return AiPredictionModel(
      predictionId: predictionId ?? this.predictionId,
      patientId: patientId ?? this.patientId,
      riskLevel: riskLevel ?? this.riskLevel,
      riskScore: riskScore ?? this.riskScore,
      confidence: confidence ?? this.confidence,
      explanation: explanation ?? this.explanation,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}
