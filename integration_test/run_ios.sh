#!/bin/bash
# Ensure the app is built in profile mode
flutter build ios --profile

# Run the integration tests
flutter test integration_test/app_test.dart -d ios 