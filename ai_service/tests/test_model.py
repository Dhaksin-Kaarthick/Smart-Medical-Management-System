from app.ml.model_service import predictor

def test_low_risk_prediction():
    result = predictor.predict(
        adherence_rate=95.0,
        missed_doses=0,
        late_doses=1,
        total_scheduled=30
    )
    assert result['riskLevel'] == 'LOW'
    assert result['riskScore'] <= 0.3
    assert result['confidence'] >= 0.8
    assert "stable" in result['explanation'].lower()

def test_high_risk_prediction():
    result = predictor.predict(
        adherence_rate=50.0,
        missed_doses=8,
        late_doses=2,
        total_scheduled=30
    )
    assert result['riskLevel'] == 'HIGH'
    assert result['riskScore'] >= 0.6
    assert "elevated" in result['explanation'].lower()

def test_medium_risk_prediction():
    result = predictor.predict(
        adherence_rate=76.0,
        missed_doses=3,
        late_doses=4,
        total_scheduled=30
    )
    assert result['riskLevel'] in ['MEDIUM', 'HIGH']

if __name__ == '__main__':
    test_low_risk_prediction()
    print("[PASS] test_low_risk_prediction")
    test_high_risk_prediction()
    print("[PASS] test_high_risk_prediction")
    test_medium_risk_prediction()
    print("[PASS] test_medium_risk_prediction")
    print("\nAll ML prediction test cases passed successfully!")
