import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["status"] == "online"

def test_predict_low_risk():
    payload = {
        "patient_id": "pat_001",
        "adherence_rate": 95.0,
        "missed_doses": 0,
        "late_doses": 1,
        "total_scheduled": 30,
        "recent_trend_days": 14
    }
    response = client.post("/predict-adherence-risk", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["riskLevel"] == "LOW"
    assert data["riskScore"] < 0.3
    assert data["confidence"] > 0.8
    assert "stable" in data["explanation"].lower()

def test_predict_high_risk():
    payload = {
        "patient_id": "pat_002",
        "adherence_rate": 55.0,
        "missed_doses": 8,
        "late_doses": 3,
        "total_scheduled": 30,
        "recent_trend_days": 14
    }
    response = client.post("/predict-adherence-risk", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["riskLevel"] == "HIGH"
    assert data["riskScore"] > 0.6
    assert "elevated" in data["explanation"].lower()
