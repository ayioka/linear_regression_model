# Air Quality PM2.5 Prediction API

A FastAPI-based REST API for predicting PM2.5 (fine particulate matter) air pollution levels using satellite and weather data. The project includes model retraining capabilities through background tasks.

## Project Files

### `main.py`
The main FastAPI application that runs the prediction server. It includes:
- RESTful endpoints for making predictions and retraining the model
- CORS middleware for cross-origin requests
- Background task handling for model retraining without blocking API responses
- Integration with the machine learning model and scaler

### `predictor.py`
Contains the core prediction logic. The `predict_pm25()` function:
- Loads the trained Random Forest model and StandardScaler from disk
- Preprocesses input features (handles categorical variables, missing values)
- Scales features and generates PM2.5 predictions
- Returns predictions for single or multiple data points

### `schema.py`
Pydantic data validation schemas that define:
- `AirQualityInput`: Validates input features for predictions (latitude, longitude, city, country, satellite measurements, etc.)
- `AirQualityRetrainInput`: Validates data for model retraining
- Field constraints and descriptions for each parameter

### `Train.csv`
Historical training data containing satellite measurements, weather data, and PM2.5 target values. Used for initial model training and updated during retraining operations.

### `Air_Pollution.ipynb`
Jupyter notebook for data exploration, analysis, and initial model training. Contains data preprocessing, EDA, and model development.

### `requirements.txt`
All Python package dependencies needed to run the project (FastAPI, scikit-learn, pandas, etc.)

## Setup Instructions

### 1. Create a Virtual Environment

#### On macOS/Linux:
```bash
python3 -m venv venv
source venv/bin/activate
```

#### On Windows:
```bash
python -m venv venv
venv\Scripts\activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

## Running the Application

Start the FastAPI server:

```bash
uvicorn main:app --reload
```

The API will be available at `http://localhost:8000`

### Access API Documentation
- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

## API Endpoints

### POST `/predict`
Make a prediction for PM2.5 levels given satellite and weather features.

**Request**: JSON object with air quality features  
**Response**: Predicted PM2.5 value

### POST `/retrain/upload`
Upload new training data to retrain the model in the background.

**Request**: CSV file containing features and `pm2_5` target column  
**Response**: Confirmation that retraining has started

## Model Files

The application uses two saved model files (generated during training):
- `best_air_quality_model.pkl` - Trained Random Forest Regressor
- `air_scaler.pkl` - StandardScaler for feature normalization

These files must exist in the project directory for predictions to work.
