import pandas as pd
import numpy as np
import joblib

def predict_pm25(input_data, model_path='best_air_quality_model.pkl', scaler_path='air_scaler.pkl'):
    """
    Takes a DataFrame of air quality/satellite features and returns PM2.5 predictions.
    Supports single or multiple rows.
    """
    # Load the saved model and scaler
    try:
        model = joblib.load(model_path)
        scaler = joblib.load(scaler_path)
    except FileNotFoundError:
        return "Error: Model or Scaler file not found. Ensure they are in the exact same folder."

    # Make a copy to avoid altering the original data
    df = input_data.copy()

    # Drop identifier columns if the user accidentally included them in the input
    columns_to_drop = ['id', 'site_id', 'date', 'pm2_5']
    df = df.drop(columns=[col for col in columns_to_drop if col in df.columns], errors='ignore')

    # Preprocessing: Handle Categorical Data ('city', 'country')
    categorical_cols = df.select_dtypes(include=['object']).columns
    for col in categorical_cols:
        df[col] = df[col].astype('category').cat.codes

    # Preprocessing: Handle Missing Values
    # Satellite data frequently has NaNs due to cloud cover.
    # We fill missing values with 0.
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    df[numeric_cols] = df[numeric_cols].fillna(0)

    # Scale the features using the loaded StandardScaler
    try:
        X_scaled = scaler.transform(df)
    except ValueError as e:
        return f"Feature mismatch error. Ensure your input data matches the training columns. Details: {e}"

    # Generate Predictions
    predictions = model.predict(X_scaled)
    
    return predictions


# EXAMPLE USAGE

if __name__ == "__main__":
    
    print("Loading sample data for testing...")
    
    try:
        # Load just the first 3 rows of the original dataset to simulate "new" data
        sample_data = pd.read_csv('Train.csv', nrows=3)
        
        # We drop the actual target (pm2_5) to simulate a real prediction scenario
        # where we don't know the answer yet.
        real_answers = sample_data['pm2_5'].tolist()
        simulated_new_data = sample_data.drop(columns=['pm2_5'])
        
        # Run the prediction
        predicted_values = predict_pm25(simulated_new_data)
        
        # Display the results
        print("\n--- Prediction Results ---")
        for i, (pred, actual) in enumerate(zip(predicted_values, real_answers)):
            print(f"Record {i+1}:")
            print(f"  Predicted PM2.5 : {pred:.2f} µg/m³")
            print(f"  Actual PM2.5    : {actual:.2f} µg/m³\n")
            
    except FileNotFoundError:
        print("Could not find 'Train.csv' to run the test. Please ensure the file is present.")