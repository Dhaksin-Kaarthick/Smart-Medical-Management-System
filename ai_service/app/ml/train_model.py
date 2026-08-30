"""
Training Script for Medicine Adherence Risk Classifier.
Uses Scikit-Learn Random Forest Classifier on labeled historical adherence features.
"""

import os
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score
import joblib

def generate_synthetic_training_data(n_samples=2000, random_seed=42):
    """
    Generates synthetic labeled historical adherence data for training.
    Features:
      - adherence_rate (float 0-100)
      - missed_doses (int 0-15)
      - late_doses (int 0-15)
      - total_scheduled (int 10-60)
      - missed_ratio (missed_doses / total_scheduled)
    Target:
      - 0: LOW Risk
      - 1: MEDIUM Risk
      - 2: HIGH Risk
    """
    np.random.seed(random_seed)
    
    adherence_rates = np.random.uniform(30.0, 100.0, n_samples)
    total_scheduled = np.random.randint(14, 60, n_samples)
    
    # Generate proportional missed and late doses
    missed_doses = []
    late_doses = []
    labels = []
    
    for rate, scheduled in zip(adherence_rates, total_scheduled):
        actual_missed = int(round((100.0 - rate) / 100.0 * scheduled))
        missed = max(0, min(actual_missed, scheduled))
        late = np.random.randint(0, max(1, scheduled // 6))
        
        missed_doses.append(missed)
        late_doses.append(late)
        
        # Ground truth risk classification
        if rate >= 85.0 and missed <= 1:
            labels.append(0) # LOW
        elif rate >= 70.0 or missed <= 3:
            labels.append(1) # MEDIUM
        else:
            labels.append(2) # HIGH

    df = pd.DataFrame({
        'adherence_rate': adherence_rates,
        'missed_doses': missed_doses,
        'late_doses': late_doses,
        'total_scheduled': total_scheduled,
        'missed_ratio': np.array(missed_doses) / np.array(total_scheduled),
        'label': labels
    })
    return df

def train_and_export():
    print("[ML] Generating adherence dataset...")
    df = generate_synthetic_training_data()
    
    X = df[['adherence_rate', 'missed_doses', 'late_doses', 'total_scheduled', 'missed_ratio']]
    y = df['label']
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    print("[ML] Training Random Forest Classifier...")
    model = RandomForestClassifier(n_estimators=100, max_depth=6, random_state=42)
    model.fit(X_train, y_train)
    
    y_pred = model.predict(X_test)
    acc = accuracy_score(y_test, y_pred)
    print(f"[ML] Model Accuracy: {acc * 100:.2f}%")
    print(classification_report(y_test, y_pred, target_names=['LOW', 'MEDIUM', 'HIGH']))
    
    model_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(model_dir, 'adherence_model.joblib')
    joblib.dump(model, output_path)
    print(f"[ML] Serialized model saved to {output_path}")

if __name__ == '__main__':
    train_and_export()
