import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/ai_prediction_model.dart';
import '../services/demo_data_service.dart';

/// Repository managing AI adherence-risk prediction calls and explanation models.
class AiRepository extends ChangeNotifier {
  AiPredictionModel _prediction = DemoDataService.demoAiPrediction;
  bool _isLoading = false;
  String? _errorMessage;

  AiPredictionModel get prediction => _prediction;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch adherence prediction from FastAPI microservice with fallback
  Future<void> fetchPrediction({
    required String patientId,
    required double adherenceRate,
    required int missedDoses,
    required int lateDoses,
    String? customApiUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final url = Uri.parse('${customApiUrl ?? AppConstants.defaultAiApiUrl}/predict-adherence-risk');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'patient_id': patientId,
              'adherence_rate': adherenceRate,
              'missed_doses': missedDoses,
              'late_doses': lateDoses,
              'total_scheduled': 42,
              'recent_trend_days': 14,
            }),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _prediction = AiPredictionModel(
          predictionId: 'pred_${DateTime.now().millisecondsSinceEpoch}',
          patientId: patientId,
          riskLevel: data['riskLevel'] as String? ?? 'LOW',
          riskScore: (data['riskScore'] as num?)?.toDouble() ?? 0.1,
          confidence: (data['confidence'] as num?)?.toDouble() ?? 0.9,
          explanation: data['explanation'] as String? ?? 'Adherence is stable.',
          generatedAt: DateTime.now(),
        );
      } else {
        _fallbackPrediction(adherenceRate, missedDoses);
      }
    } catch (_) {
      // Graceful offline fallback
      _fallbackPrediction(adherenceRate, missedDoses);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _fallbackPrediction(double adherenceRate, int missedDoses) {
    if (adherenceRate < 70 || missedDoses >= 3) {
      _prediction = AiPredictionModel(
        predictionId: 'pred_local_${DateTime.now().millisecondsSinceEpoch}',
        patientId: 'pat_001',
        riskLevel: 'HIGH',
        riskScore: 0.82,
        confidence: 0.89,
        explanation: 'Adherence risk is elevated due to repeated missed doses.',
        generatedAt: DateTime.now(),
      );
    } else if (adherenceRate < 85 || missedDoses >= 1) {
      _prediction = AiPredictionModel(
        predictionId: 'pred_local_${DateTime.now().millisecondsSinceEpoch}',
        patientId: 'pat_001',
        riskLevel: 'MEDIUM',
        riskScore: 0.45,
        confidence: 0.85,
        explanation: 'Adherence has decreased recently with occasional delays.',
        generatedAt: DateTime.now(),
      );
    } else {
      _prediction = DemoDataService.demoAiPrediction;
    }
  }
}
