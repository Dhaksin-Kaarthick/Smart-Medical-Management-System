from pydantic import BaseModel, Field
from typing import Optional


class AdherencePredictionRequest(BaseModel):
    patient_id: str = Field(..., description="Unique Patient Identifier")
    adherence_rate: float = Field(..., ge=0.0, le=100.0, description="Overall compliance percentage")
    missed_doses: int = Field(..., ge=0, description="Count of missed doses in the analysis window")
    late_doses: int = Field(0, ge=0, description="Count of doses taken >30min late")
    total_scheduled: int = Field(..., gt=0, description="Total prescribed doses scheduled")
    recent_trend_days: Optional[int] = Field(14, description="Evaluation timeframe in days")


class AdherencePredictionResponse(BaseModel):
    patient_id: str
    riskLevel: str = Field(..., description="LOW, MEDIUM, or HIGH risk")
    riskScore: float = Field(..., ge=0.0, le=1.0, description="Calculated risk probability")
    confidence: float = Field(..., ge=0.0, le=1.0, description="Model prediction confidence score")
    explanation: str = Field(..., description="Explainable feature contribution summary")
    disclaimer: str = "AI-generated adherence insights are for monitoring purposes and are not medical advice."
