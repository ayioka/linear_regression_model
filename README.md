## Description

Air pollution is a critical public health challenge, with PM2.5 particles among the most harmful pollutants due to their impact on respiratory health.
This project builds a multivariate linear regression pipeline to predict PM2.5 concentration from environmental and location-based features.
Multiple regression models are trained, compared, and evaluated to balance interpretability with predictive performance.
The best-performing model is saved for downstream use in an API and Flutter application.

## API

- **Base URL:** https://ayioka-pm25.hf.space
- **Swagger Documentation:** https://ayioka-pm25.hf.space/docs

## Running the Mobile App

### Prerequisites
- Flutter SDK installed ([Download](https://flutter.dev/docs/get-started/install))
- Android emulator/device or iOS simulator/device

### Steps
1. Navigate to the Flutter app directory:
   ```bash
   cd "summative/Flutter APP"
   ```
2. Get dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```
