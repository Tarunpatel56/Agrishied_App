import 'package:flutter/material.dart';
import 'weather_view.dart';

// This file redirects to WeatherView for backward compatibility
class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WeatherView();
  }
}
