import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PM25PredictorApp());
}

class PM25PredictorApp extends StatelessWidget {
  const PM25PredictorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0D9488),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PM25 Predictor',
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.spaceGroteskTextTheme(baseTheme.textTheme),
      ),
      home: const PredictorPage(),
    );
  }
}

class FieldSpec {
  const FieldSpec({
    required this.key,
    required this.label,
    this.min,
    this.max,
    this.integer = false,
    this.text = false,
  });

  final String key;
  final String label;
  final double? min;
  final double? max;
  final bool integer;
  final bool text;
}

class PredictorPage extends StatefulWidget {
  const PredictorPage({super.key});

  @override
  State<PredictorPage> createState() => _PredictorPageState();
}

class _PredictorPageState extends State<PredictorPage> {
  static const String _apiBaseUrl = 'https://ayioka-pm25.hf.space';

  static const List<FieldSpec> _specs = [
    FieldSpec(key: 'site_latitude', label: 'site_latitude', min: -4.4655, max: 7.6009),
    FieldSpec(key: 'site_longitude', label: 'site_longitude', min: -0.1698, max: 40.2855),
    FieldSpec(key: 'city', label: 'city', text: true),
    FieldSpec(key: 'country', label: 'country', text: true),
    FieldSpec(key: 'hour', label: 'hour', min: 9, max: 14, integer: true),
    FieldSpec(key: 'sulphurdioxide_so2_column_number_density', label: 'sulphurdioxide_so2_column_number_density', min: -0.0013, max: 0.0023),
    FieldSpec(key: 'sulphurdioxide_so2_column_number_density_amf', label: 'sulphurdioxide_so2_column_number_density_amf', min: 0.1686, max: 1.7378),
    FieldSpec(key: 'sulphurdioxide_so2_slant_column_number_density', label: 'sulphurdioxide_so2_slant_column_number_density', min: -0.0009, max: 0.0013),
    FieldSpec(key: 'sulphurdioxide_cloud_fraction', label: 'sulphurdioxide_cloud_fraction', min: -0.03, max: 0.3298),
    FieldSpec(key: 'sulphurdioxide_sensor_azimuth_angle', label: 'sulphurdioxide_sensor_azimuth_angle', min: -126.2139, max: 95.8227),
    FieldSpec(key: 'sulphurdioxide_sensor_zenith_angle', label: 'sulphurdioxide_sensor_zenith_angle', min: -6.4287, max: 72.8407),
    FieldSpec(key: 'sulphurdioxide_solar_azimuth_angle', label: 'sulphurdioxide_solar_azimuth_angle', min: -179.4196, max: -7.9628),
    FieldSpec(key: 'sulphurdioxide_solar_zenith_angle', label: 'sulphurdioxide_solar_zenith_angle', min: 8.0004, max: 48.8753),
    FieldSpec(key: 'sulphurdioxide_so2_column_number_density_15km', label: 'sulphurdioxide_so2_column_number_density_15km', min: -0.0004, max: 0.0005),
    FieldSpec(key: 'month', label: 'month', min: -0.1, max: 13.1),
    FieldSpec(key: 'carbonmonoxide_co_column_number_density', label: 'carbonmonoxide_co_column_number_density', min: 0.0098, max: 0.0953),
    FieldSpec(key: 'carbonmonoxide_h2o_column_number_density', label: 'carbonmonoxide_h2o_column_number_density', min: -422.4101, max: 12475.0118),
    FieldSpec(key: 'carbonmonoxide_cloud_height', label: 'carbonmonoxide_cloud_height', min: -498.7943, max: 5498.7372),
    FieldSpec(key: 'carbonmonoxide_sensor_altitude', label: 'carbonmonoxide_sensor_altitude', min: 828302.2586, max: 830979.655),
    FieldSpec(key: 'carbonmonoxide_sensor_azimuth_angle', label: 'carbonmonoxide_sensor_azimuth_angle', min: -115.2459, max: 89.8888),
    FieldSpec(key: 'carbonmonoxide_sensor_zenith_angle', label: 'carbonmonoxide_sensor_zenith_angle', min: -5.2996, max: 71.8208),
    FieldSpec(key: 'carbonmonoxide_solar_azimuth_angle', label: 'carbonmonoxide_solar_azimuth_angle', min: -179.2452, max: -8.1741),
    FieldSpec(key: 'carbonmonoxide_solar_zenith_angle', label: 'carbonmonoxide_solar_zenith_angle', min: 6.9191, max: 49.019),
    FieldSpec(key: 'nitrogendioxide_no2_column_number_density', label: 'nitrogendioxide_no2_column_number_density', min: -0.0, max: 0.0003),
    FieldSpec(key: 'nitrogendioxide_tropospheric_no2_column_number_density', label: 'nitrogendioxide_tropospheric_no2_column_number_density', min: -0.0001, max: 0.0003),
    FieldSpec(key: 'nitrogendioxide_stratospheric_no2_column_number_density', label: 'nitrogendioxide_stratospheric_no2_column_number_density', min: 0.0, max: 0.0),
    FieldSpec(key: 'nitrogendioxide_no2_slant_column_number_density', label: 'nitrogendioxide_no2_slant_column_number_density', min: 0.0, max: 0.0004),
    FieldSpec(key: 'nitrogendioxide_tropopause_pressure', label: 'nitrogendioxide_tropopause_pressure', min: 6922.4172, max: 11595.8333),
    FieldSpec(key: 'nitrogendioxide_absorbing_aerosol_index', label: 'nitrogendioxide_absorbing_aerosol_index', min: -2.9092, max: 2.7141),
    FieldSpec(key: 'nitrogendioxide_cloud_fraction', label: 'nitrogendioxide_cloud_fraction', min: -0.047, max: 0.5174),
    FieldSpec(key: 'nitrogendioxide_sensor_altitude', label: 'nitrogendioxide_sensor_altitude', min: 828307.4673, max: 831054.753),
    FieldSpec(key: 'nitrogendioxide_sensor_azimuth_angle', label: 'nitrogendioxide_sensor_azimuth_angle', min: -126.2139, max: 95.8227),
    FieldSpec(key: 'nitrogendioxide_sensor_zenith_angle', label: 'nitrogendioxide_sensor_zenith_angle', min: -6.4287, max: 72.8407),
    FieldSpec(key: 'nitrogendioxide_solar_azimuth_angle', label: 'nitrogendioxide_solar_azimuth_angle', min: -179.4196, max: -7.9628),
    FieldSpec(key: 'nitrogendioxide_solar_zenith_angle', label: 'nitrogendioxide_solar_zenith_angle', min: 9.7844, max: 48.7131),
    FieldSpec(key: 'formaldehyde_tropospheric_hcho_column_number_density', label: 'formaldehyde_tropospheric_hcho_column_number_density', min: -0.0007, max: 0.0024),
    FieldSpec(key: 'formaldehyde_tropospheric_hcho_column_number_density_amf', label: 'formaldehyde_tropospheric_hcho_column_number_density_amf', min: 0.2261, max: 2.4666),
    FieldSpec(key: 'formaldehyde_hcho_slant_column_number_density', label: 'formaldehyde_hcho_slant_column_number_density', min: -0.0006, max: 0.0012),
    FieldSpec(key: 'formaldehyde_cloud_fraction', label: 'formaldehyde_cloud_fraction', min: -0.0542, max: 0.5963),
    FieldSpec(key: 'formaldehyde_solar_zenith_angle', label: 'formaldehyde_solar_zenith_angle', min: 6.792, max: 49.0149),
    FieldSpec(key: 'formaldehyde_solar_azimuth_angle', label: 'formaldehyde_solar_azimuth_angle', min: -179.4196, max: -7.9628),
    FieldSpec(key: 'formaldehyde_sensor_zenith_angle', label: 'formaldehyde_sensor_zenith_angle', min: -6.4287, max: 72.8407),
    FieldSpec(key: 'formaldehyde_sensor_azimuth_angle', label: 'formaldehyde_sensor_azimuth_angle', min: -126.2139, max: 95.8227),
    FieldSpec(key: 'uvaerosolindex_absorbing_aerosol_index', label: 'uvaerosolindex_absorbing_aerosol_index', min: -3.1988, max: 2.7404),
    FieldSpec(key: 'uvaerosolindex_sensor_altitude', label: 'uvaerosolindex_sensor_altitude', min: 828288.5062, max: 831244.9313),
    FieldSpec(key: 'uvaerosolindex_sensor_azimuth_angle', label: 'uvaerosolindex_sensor_azimuth_angle', min: -126.2139, max: 95.8227),
    FieldSpec(key: 'uvaerosolindex_sensor_zenith_angle', label: 'uvaerosolindex_sensor_zenith_angle', min: -6.4506, max: 73.0816),
    FieldSpec(key: 'uvaerosolindex_solar_azimuth_angle', label: 'uvaerosolindex_solar_azimuth_angle', min: -179.4196, max: -7.9628),
    FieldSpec(key: 'uvaerosolindex_solar_zenith_angle', label: 'uvaerosolindex_solar_zenith_angle', min: 5.6117, max: 49.1222),
    FieldSpec(key: 'ozone_o3_column_number_density', label: 'ozone_o3_column_number_density', min: 0.1013, max: 0.1313),
    FieldSpec(key: 'ozone_o3_column_number_density_amf', label: 'ozone_o3_column_number_density_amf', min: 1.8575, max: 3.8121),
    FieldSpec(key: 'ozone_o3_slant_column_number_density', label: 'ozone_o3_slant_column_number_density', min: 0.2009, max: 0.4631),
    FieldSpec(key: 'ozone_o3_effective_temperature', label: 'ozone_o3_effective_temperature', min: 205.5457, max: 246.046),
    FieldSpec(key: 'ozone_cloud_fraction', label: 'ozone_cloud_fraction', min: -0.1, max: 1.1),
    FieldSpec(key: 'ozone_sensor_azimuth_angle', label: 'ozone_sensor_azimuth_angle', min: -126.2139, max: 95.8227),
    FieldSpec(key: 'ozone_sensor_zenith_angle', label: 'ozone_sensor_zenith_angle', min: -6.4291, max: 72.8453),
    FieldSpec(key: 'ozone_solar_azimuth_angle', label: 'ozone_solar_azimuth_angle', min: -179.4196, max: -7.9628),
    FieldSpec(key: 'ozone_solar_zenith_angle', label: 'ozone_solar_zenith_angle', min: 6.7989, max: 49.0143),
    FieldSpec(key: 'uvaerosollayerheight_aerosol_height', label: 'uvaerosollayerheight_aerosol_height', min: -57.9864, max: 6746.4886),
    FieldSpec(key: 'uvaerosollayerheight_aerosol_pressure', label: 'uvaerosollayerheight_aerosol_pressure', min: 41409.9389, max: 100146.7186),
    FieldSpec(key: 'uvaerosollayerheight_aerosol_optical_depth', label: 'uvaerosollayerheight_aerosol_optical_depth', min: -0.4734, max: 6.8079),
    FieldSpec(key: 'uvaerosollayerheight_sensor_zenith_angle', label: 'uvaerosollayerheight_sensor_zenith_angle', min: -5.3272, max: 72.656),
    FieldSpec(key: 'uvaerosollayerheight_sensor_azimuth_angle', label: 'uvaerosollayerheight_sensor_azimuth_angle', min: -121.2718, max: 95.234),
    FieldSpec(key: 'uvaerosollayerheight_solar_azimuth_angle', label: 'uvaerosollayerheight_solar_azimuth_angle', min: -164.3381, max: -26.0395),
    FieldSpec(key: 'uvaerosollayerheight_solar_zenith_angle', label: 'uvaerosollayerheight_solar_zenith_angle', min: 10.6703, max: 44.8002),
    FieldSpec(key: 'cloud_cloud_fraction', label: 'cloud_cloud_fraction', min: -0.1, max: 1.1),
    FieldSpec(key: 'cloud_cloud_top_pressure', label: 'cloud_cloud_top_pressure', min: 306.9146, max: 104253.8458),
    FieldSpec(key: 'cloud_cloud_top_height', label: 'cloud_cloud_top_height', min: -1155.2518, max: 18964.3077),
    FieldSpec(key: 'cloud_cloud_base_pressure', label: 'cloud_cloud_base_pressure', min: 1736.3776, max: 109924.9327),
    FieldSpec(key: 'cloud_cloud_base_height', label: 'cloud_cloud_base_height', min: -1618.0521, max: 17915.4714),
    FieldSpec(key: 'cloud_cloud_optical_depth', label: 'cloud_cloud_optical_depth', min: -23.3957, max: 274.8542),
    FieldSpec(key: 'cloud_surface_albedo', label: 'cloud_surface_albedo', min: 0.0578, max: 0.4507),
    FieldSpec(key: 'cloud_sensor_azimuth_angle', label: 'cloud_sensor_azimuth_angle', min: -120.7087, max: 95.3222),
    FieldSpec(key: 'cloud_sensor_zenith_angle', label: 'cloud_sensor_zenith_angle', min: -3.3273, max: 72.563),
    FieldSpec(key: 'cloud_solar_azimuth_angle', label: 'cloud_solar_azimuth_angle', min: -172.7396, max: -8.5702),
    FieldSpec(key: 'cloud_solar_zenith_angle', label: 'cloud_solar_zenith_angle', min: 6.7968, max: 49.0145),
  ];

  final Map<String, TextEditingController> _controllers = {
    for (final item in _specs) item.key: TextEditingController(),
  };

  String _result = 'Prediction output will appear here.';
  bool _isError = false;
  bool _loading = false;

  Map<String, List<FieldSpec>> get _groupedSpecs {
    final groups = <String, List<FieldSpec>>{};
    for (final item in _specs) {
      final segment = item.key.contains('_')
          ? item.key.split('_').first
          : 'general';
      final title = switch (segment) {
        'city' || 'country' || 'hour' || 'month' || 'site' => 'General',
        _ => _capitalize(segment),
      };
      groups.putIfAbsent(title, () => []).add(item);
    }

    return groups;
  }

  @override
  void dispose() {
    for (final entry in _controllers.values) {
      entry.dispose();
    }
    super.dispose();
  }

  Future<void> _predict() async {
    final payload = <String, dynamic>{};
    final issues = <String>[];

    for (final spec in _specs) {
      final raw = _controllers[spec.key]!.text.trim();
      if (raw.isEmpty) {
        issues.add('Missing ${spec.label}');
        continue;
      }

      if (spec.text) {
        payload[spec.key] = raw;
        continue;
      }

      final parsed = double.tryParse(raw);
      if (parsed == null) {
        issues.add('${spec.label} must be a number');
        continue;
      }

      if (spec.min != null && parsed < spec.min!) {
        issues.add('${spec.label} is below min (${spec.min})');
      }
      if (spec.max != null && parsed > spec.max!) {
        issues.add('${spec.label} is above max (${spec.max})');
      }

      payload[spec.key] = spec.integer ? parsed.round() : parsed;
    }

    if (issues.isNotEmpty) {
      setState(() {
        _isError = true;
        _result = issues.take(8).join('\n');
      });
      return;
    }

    setState(() {
      _loading = true;
      _isError = false;
      _result = 'Predicting PM2.5...';
    });

    final endpoint = '${_apiBaseUrl.replaceAll(RegExp(r'/$'), '')}/predict';
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final value = decoded['predicted_pm2_5'];
        setState(() {
          _isError = false;
          _result = 'Predicted PM2.5: $value';
        });
      } else {
        final detail = decoded is Map<String, dynamic>
            ? decoded['detail']?.toString() ?? 'Unknown error'
            : 'Unknown error';
        setState(() {
          _isError = true;
          _result = detail;
        });
      }
    } catch (error) {
      setState(() {
        _isError = true;
        _result = 'Request failed: $error';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _populateWithSampleData() {
    for (final spec in _specs) {
      final controller = _controllers[spec.key]!;
      if (spec.text) {
        if (spec.key == 'city') {
          controller.text = 'Nairobi';
        } else if (spec.key == 'country') {
          controller.text = 'Kenya';
        }
        continue;
      }

      if (spec.min == null || spec.max == null) {
        controller.text = '1';
        continue;
      }

      final midpoint = (spec.min! + spec.max!) / 2;
      if (spec.integer) {
        controller.text = midpoint.round().toString();
      } else {
        controller.text = _cleanDouble(midpoint);
      }
    }

    setState(() {
      _isError = false;
      _result = 'Sample values loaded. You can edit any field before predicting.';
    });
  }

  static String _cleanDouble(double value) {
    final asText = value.toStringAsFixed(6);
    return asText.contains('.')
        ? asText.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')
        : asText;
  }

  static String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupedSpecs;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE9FAF7), Color(0xFFEDF2FF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1024),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PM25 Predictor',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fill in all features then request a PM2.5 prediction.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...groups.entries.map(
                      (entry) => Card(
                        child: ExpansionTile(
                          initiallyExpanded: entry.key == 'General',
                          title: Text('${entry.key} (${entry.value.length})'),
                          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final wide = constraints.maxWidth > 760;
                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: entry.value.map((field) {
                                    final width = wide
                                        ? (constraints.maxWidth - 12) / 2
                                        : constraints.maxWidth;
                                    return SizedBox(
                                      width: width,
                                      child: TextField(
                                        controller: _controllers[field.key],
                                        keyboardType: field.text
                                            ? TextInputType.text
                                            : const TextInputType.numberWithOptions(
                                                decimal: true,
                                                signed: true,
                                              ),
                                        decoration: InputDecoration(
                                          labelText: field.label,
                                          helperText: field.text
                                              ? 'Required'
                                              : 'Range: ${field.min} to ${field.max}',
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: _loading ? null : _predict,
                          icon: _loading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.analytics_outlined),
                          label: const Text('Predict'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _loading ? null : _populateWithSampleData,
                          icon: const Icon(Icons.auto_fix_high_outlined),
                          label: const Text('Populate with sample data'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: _isError
                          ? const Color(0xFFFFE7E7)
                          : const Color(0xFFE6F8EF),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _result,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
