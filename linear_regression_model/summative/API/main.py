from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd
from fastapi import BackgroundTasks, UploadFile, File
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler
import os
import logging as logger
import joblib


# Import the Pydantic model for input validation
from schema import AirQualityInput, AirQualityRetrainInput

# Import the prediction logic from the file you provided
from predictor import predict_pm25

# Initialize the FastAPI app
app = FastAPI(
    title="Air Quality PM2.5 Prediction API",
    description="API for predicting PM2.5 levels using satellite and weather data.",
    version="1.0.0"
)

# Add CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],  # Allows all HTTP methods (POST, GET, OPTIONS, etc.)
    allow_headers=["*"],  # Allows all headers
)

def retrain_model_task(new_data_df: pd.DataFrame):
    """
    Background task to merge new data, retrain the model, and save it.
    """
    logger.info("Starting background retraining process...")
    
    try:
        # Load the original historical data if it exists
        if os.path.exists('Train.csv'):
            historical_df = pd.read_csv('Train.csv')
            # Combine old and new data
            combined_df = pd.concat([historical_df, new_data_df], ignore_index=True)
        else:
            # If the old data is gone, just train on the new data
            combined_df = new_data_df

        # Save the new combined dataset for future retraining
        combined_df.to_csv('Train.csv', index=False)

        # Preprocess the combined data
        # Drop irrelevant columns
        cols_to_drop = ['id', 'site_id', 'date']
        clean_df = combined_df.drop(columns=[col for col in cols_to_drop if col in combined_df.columns], errors='ignore')

        # Handle Categoricals
        categorical_cols = clean_df.select_dtypes(include=['object']).columns
        for col in categorical_cols:
            clean_df[col] = clean_df[col].astype('category').cat.codes

        # Handle Missing Values
        numeric_cols = clean_df.select_dtypes(include=[np.number]).columns
        clean_df[numeric_cols] = clean_df[numeric_cols].fillna(clean_df[numeric_cols].median())

        # Split Features and Target
        X = clean_df.drop('pm2_5', axis=1)
        y = clean_df['pm2_5']

        # Standardize and Retrain
        new_scaler = StandardScaler()
        X_scaled = new_scaler.fit_transform(X)

        new_model = RandomForestRegressor(n_estimators=50, max_depth=10, random_state=42)
        new_model.fit(X_scaled, y)

        # Save the new assets to disk
        joblib.dump(new_model, 'best_air_quality_model.pkl')
        joblib.dump(new_scaler, 'air_scaler.pkl')

        # Update the models currently loaded in the FastAPI app's memory
        global model, scaler
        model = new_model
        scaler = new_scaler

        logger.info("Retraining successful! New model loaded into memory.")

    except Exception as e:
        logger.error(f"Retraining failed: {str(e)}")


# Define the POST Endpoint
@app.post("/predict", summary="Get PM2.5 Prediction")
async def get_prediction(data: AirQualityInput):
    """
    Receives satellite and weather data, validates it, and returns a PM2.5 prediction.
    """
    try:
        # Convert the validated Pydantic object into a pandas DataFrame (1 row)
        input_dict = data.model_dump()
        input_df = pd.DataFrame([input_dict])

        # Call the logic from predictor.py
        prediction = predict_pm25(
            input_data=input_df, 
            model_path='best_air_quality_model.pkl', 
            scaler_path='air_scaler.pkl'
        )

        # The predictor might return an error string instead of an array if it fails
        if isinstance(prediction, str):
            raise HTTPException(status_code=400, detail=prediction)

        # Return the result as JSON
        return {
            "status": "success",
            "predicted_pm2_5": float(prediction[0])
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An unexpected error occurred: {str(e)}")



@app.post("/retrain/upload", summary="Retrain model via CSV upload")
async def retrain_via_upload(background_tasks: BackgroundTasks, file: UploadFile = File(...)):
    """
    Upload a CSV file containing new data (must include the 'pm2_5' target column).
    """
    if not file.filename.endswith('.csv'):
        raise HTTPException(status_code=400, detail="Only CSV files are supported.")

    try:
        # Read the uploaded CSV directly into a Pandas DataFrame
        new_data_df = pd.read_csv(file.file)
        
        # Verify the target column exists
        if 'pm2_5' not in new_data_df.columns:
             raise HTTPException(status_code=400, detail="Uploaded data must contain the 'pm2_5' target column for retraining.")

        # Pass the DataFrame to the background task
        background_tasks.add_task(retrain_model_task, new_data_df)

        return {"status": "success", "message": "File received. Model retraining started in the background."}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to process file: {str(e)}")


@app.post("/retrain/stream", summary="Retrain model via JSON payload")
async def retrain_via_stream(data: list[AirQualityRetrainInput], background_tasks: BackgroundTasks):
    """
    Stream a list of JSON records to trigger retraining. Each record must include the 'pm2_5' target field. 
    
    """
    try:
        # Convert the list of Pydantic models into a DataFrame
        records = [record.model_dump() for record in data]
        new_data_df = pd.DataFrame(records)

        # Pass the DataFrame to the background task
        background_tasks.add_task(retrain_model_task, new_data_df)

        return {"status": "success", "message": f"{len(records)} records received. Model retraining started in the background."}

    except Exception as e:
         raise HTTPException(status_code=500, detail=f"Failed to process stream: {str(e)}")
    

# Health check endpoint
@app.get("/", summary="API Health Check")
async def health_check():
    return {"status": "active", "message": "Air Quality API is running."}