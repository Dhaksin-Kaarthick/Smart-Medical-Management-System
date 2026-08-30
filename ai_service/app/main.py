from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from .schemas import AdherencePredictionRequest, AdherencePredictionResponse
from .ml.model_service import predictor

app = FastAPI(
    title="Smart Medical Management — AI Adherence Microservice",
    description="IoT-Enabled Medicine Reminder & AI Patient Adherence Risk Prediction API",
    version="1.0.0"
)

# Enable CORS for Flutter web / mobile clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def health_check():
    return {
        "status": "online",
        "service": "Smart Medical AI Risk Predictor",
        "version": "1.0.0"
    }


@app.post("/predict-adherence-risk", response_model=AdherencePredictionResponse)
def predict_adherence_risk(payload: AdherencePredictionRequest):
    try:
        result = predictor.predict(
            adherence_rate=payload.adherence_rate,
            missed_doses=payload.missed_doses,
            late_doses=payload.late_doses,
            total_scheduled=payload.total_scheduled
        )
        
        return AdherencePredictionResponse(
            patient_id=payload.patient_id,
            riskLevel=result['riskLevel'],
            riskScore=result['riskScore'],
            confidence=result['confidence'],
            explanation=result['explanation']
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
