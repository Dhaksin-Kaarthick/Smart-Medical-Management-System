import os
import joblib
import numpy as np

class AdherenceRiskPredictor:
    def __init__(self):
        self.model = None
        self.risk_labels = ['LOW', 'MEDIUM', 'HIGH']
        self._load_or_train_model()

    def _load_or_train_model(self):
        model_path = os.path.join(os.path.dirname(__file__), 'adherence_model.joblib')
        if os.path.exists(model_path):
            self.model = joblib.load(model_path)
        else:
            # Train and save on the fly if artifact not found
            from .train_model import train_and_export
            train_and_export()
            self.model = joblib.load(model_path)

    def predict(self, adherence_rate: float, missed_doses: int, late_doses: int, total_scheduled: int):
        import pandas as pd
        missed_ratio = missed_doses / max(1, total_scheduled)
        features = pd.DataFrame([{
            'adherence_rate': adherence_rate,
            'missed_doses': missed_doses,
            'late_doses': late_doses,
            'total_scheduled': total_scheduled,
            'missed_ratio': missed_ratio
        }])
        
        # Probabilities for [LOW, MEDIUM, HIGH]
        probs = self.model.predict_proba(features)[0]
        pred_class = int(np.argmax(probs))
        risk_level = self.risk_labels[pred_class]
        confidence = float(probs[pred_class])
        
        # Calculate continuous risk score (0.0 to 1.0)
        risk_score = float((probs[1] * 0.5) + (probs[2] * 1.0))
        
        # Generate explainable summary
        explanation = self._generate_explanation(risk_level, adherence_rate, missed_doses, late_doses)
        
        return {
            'riskLevel': risk_level,
            'riskScore': round(risk_score, 2),
            'confidence': round(confidence, 2),
            'explanation': explanation
        }

    def _generate_explanation(self, risk_level: str, adherence_rate: float, missed_doses: int, late_doses: int) -> str:
        if risk_level == 'HIGH':
            return (
                f"Adherence risk is elevated ({adherence_rate:.1f}%) due to {missed_doses} missed doses "
                f"over the evaluation window. Caregiver intervention recommended."
            )
        elif risk_level == 'MEDIUM':
            return (
                f"Adherence is moderate ({adherence_rate:.1f}%) with {missed_doses} missed and {late_doses} late doses. "
                "Monitor for persistent delay patterns."
            )
        else:
            return (
                f"Medication adherence has remained stable at {adherence_rate:.1f}% "
                f"with consistent timing across scheduled doses."
            )

# Singleton predictor instance
predictor = AdherenceRiskPredictor()
