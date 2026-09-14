import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sahih_albukhari/core/arabic/arabic_normalizer.dart';

void main() {
  group('ArabicNormalizer', () {
    test('removes diacritics and tatweel', () {
      // From hadith [١] (Shamela 1284, page 153).
      expect(ArabicNormalizer.normalize('إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ'), 'انما الاعمال بالنيات');
      expect(ArabicNormalizer.normalize('حـــدثنا'), 'حدثنا');
    });

    test('unifies alef forms and alef maqsura', () {
      expect(ArabicNormalizer.normalize('أ إ آ ٱ'), 'ا ا ا ا');
      expect(ArabicNormalizer.normalize('حَتَّى'), 'حتي');
    });

    test('ta marbuta is only folded in broad mode', () {
      expect(ArabicNormalizer.normalize('حَلَاوَةِ'), 'حلاوة');
      expect(ArabicNormalizer.normalize('حَلَاوَةِ', broad: true), 'حلاوه');
    });

    test('converts Arabic-Indic digits and strips punctuation', () {
      expect(ArabicNormalizer.normalize('٩ - بَابُ حَلَاوَةِ الْإِيمَانِ'), '9 باب حلاوة الايمان');
      expect(ArabicNormalizer.normalize('رَسُولُ اللَّهِ ﷺ: "قال"'), 'رسول الله قال');
      expect(ArabicNormalizer.toWesternDigits('[٧٥٥٩]'), '[7559]');
      expect(ArabicNormalizer.toArabicDigits('7559'), '٧٥٥٩');
    });

    test('source index maps every normalized character back to the original', () {
      const original = 'وَقَوْلُ اللَّهِ';
      final n = ArabicNormalizer.normalizeWithMap(original);
      expect(n.text, 'وقول الله');
      expect(n.sourceIndex.length, n.text.length);
      for (var i = 0; i < n.text.length; i++) {
        if (n.text[i] == ' ') continue;
        expect(ArabicNormalizer.normalize(original[n.sourceIndex[i]]), n.text[i]);
      }
    });

    test('matches the importer (tool/import/normalization_vectors.json)', () {
      final file = File('tool/import/normalization_vectors.json');
      expect(file.existsSync(), isTrue, reason: 'run tool/import/build_database.py first');
      final vectors = (jsonDecode(file.readAsStringSync()) as List).cast<Map<String, dynamic>>();
      expect(vectors, isNotEmpty);
      for (final v in vectors) {
        final input = v['input'] as String;
        expect(ArabicNormalizer.normalize(input), v['normalized'], reason: input);
        expect(ArabicNormalizer.normalize(input, broad: true), v['broad'], reason: input);
      }
    });
  });
}
