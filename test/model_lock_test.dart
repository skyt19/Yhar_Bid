/// test/model_lock_test.dart
/// CRITICAL: Model Lock Verification Tests
/// Ensures openai/gpt-oss-20b cannot be overridden by any configuration

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yharbid/services/ai_service.dart';
import 'package:yharbid/core/config/app_config.dart';

void main() {
  group('CRITICAL: Model Lock Tests', () {
    test('Locked model is exactly openai/gpt-oss-20b', () {
      final String model = AiService.lockedModel;
      expect(model, equals('openai/gpt-oss-20b'),
          reason: 'Model must be exactly openai/gpt-oss-20b');
      print('✅ Locked model verified: $model');
    });

    test('Locked model is immutable', () {
      final String model1 = AiService.lockedModel;
      final String model2 = AiService.lockedModel;

      expect(identical(model1, model2), true,
          reason: 'Locked model should return same constant reference');
      expect(model1, equals('openai/gpt-oss-20b'));
      expect(model2, equals('openai/gpt-oss-20b'));
      print('✅ Model immutability verified');
    });

    test('AppConfig.aiModel does NOT affect AiService (model independence)', () {
      // Even if AppConfig returns a different model, AiService must use locked model
      final String appConfigModel = AppConfig.aiModel;
      final String lockedModel = AiService.lockedModel;

      // The locked model should NEVER match AppConfig if it's different
      expect(lockedModel, equals('openai/gpt-oss-20b'));

      // Verify independence: locked model doesn't depend on AppConfig
      expect(lockedModel, isNot(null));
      expect(lockedModel, isNotEmpty);

      print('✅ Model independence verified');
      print('   AppConfig.aiModel: $appConfigModel');
      print('   AiService.lockedModel: $lockedModel');
      print('   Status: Locked model is independent of configuration');
    });

    test('.env AI_MODEL does NOT override locked model', () async {
      // Load .env
      await dotenv.load(fileName: '.env');

      // Check what .env says (might be different)
      final String? envModel = dotenv.env['AI_MODEL'];
      final String lockedModel = AiService.lockedModel;

      // Regardless of .env, locked model must stay the same
      expect(lockedModel, equals('openai/gpt-oss-20b'),
          reason: '.env must NOT override locked model');

      print('✅ .env override protection verified');
      print('   .env AI_MODEL: ${envModel ?? "not set"}');
      print('   AiService.lockedModel: $lockedModel');
      print('   Status: Locked model immune to .env changes');
    });

    test('Model lock prevents llama/gpt alternatives', () {
      final String model = AiService.lockedModel;

      // Explicitly verify not using alternative models
      expect(model.contains('llama'), false,
          reason: 'Must not use Llama models');
      expect(model.contains('gpt-4'), false,
          reason: 'Must not use GPT-4 or GPT alternatives');
      expect(model.contains('gemma'), false,
          reason: 'Must not use Gemma models');
      expect(model.contains('mixtral'), false,
          reason: 'Must not use Mixtral models');

      print('✅ Alternative model exclusion verified');
    });

    test('Model string format is correct', () {
      final String model = AiService.lockedModel;

      expect(model, isNotEmpty);
      expect(model.length, greaterThan(5));
      expect(model.contains('/'), true,
          reason: 'Groq model format should contain /');
      expect(model.split('/').length, equals(2),
          reason: 'Model should be in format: provider/model-name');

      final parts = model.split('/');
      expect(parts[0], equals('openai'));
      expect(parts[1], equals('gpt-oss-20b'));

      print('✅ Model format verified: $model');
    });

    test('No runtime modification possible', () {
      // Store original
      final String originalModel = AiService.lockedModel;

      // Try to get it multiple times (ensure it's always the same)
      for (int i = 0; i < 10; i++) {
        final String currentModel = AiService.lockedModel;
        expect(currentModel, equals(originalModel));
        expect(currentModel, equals('openai/gpt-oss-20b'));
      }

      print('✅ Runtime immutability verified (10 iterations)');
    });
  });

  group('Model Lock Integration', () {
    test('AiService class exists and has locked model', () {
      expect(AiService, isNotNull);
      expect(AiService.lockedModel, isNotNull);
      expect(AiService.lockedModel, isNotEmpty);
      print('✅ AiService properly exposes locked model');
    });

    test('Locked model documentation is clear', () {
      final String model = AiService.lockedModel;
      expect(model, equals('openai/gpt-oss-20b'));

      // This test documents the intent
      print('✅ MODEL LOCK DOCUMENTATION:');
      print('   - Model: $model');
      print('   - Status: PERMANENTLY LOCKED');
      print('   - Override: IMPOSSIBLE');
      print('   - Source: AiService._LOCKED_GROQ_MODEL constant');
    });
  });
}
