// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  const sampleRate = 16000;
  const toneDurationSec = 1.5;
  const silenceDurationSec = 2.0;
  const totalDurationSec = toneDurationSec + silenceDurationSec;
  final totalSamples = (sampleRate * totalDurationSec).toInt();
  final toneSamples = (sampleRate * toneDurationSec).toInt();

  // Dual tone: 440 Hz + 480 Hz (Standard audible telecom ringback)
  const freq1 = 440.0;
  const freq2 = 480.0;

  final pcmData = Int16List(totalSamples);
  for (int i = 0; i < totalSamples; i++) {
    if (i < toneSamples) {
      final t = i / sampleRate;
      // Gentle ramp in and ramp out (50ms) to avoid click
      double envelope = 1.0;
      final rampSamples = (0.05 * sampleRate).toInt();
      if (i < rampSamples) {
        envelope = i / rampSamples;
      } else if (i > toneSamples - rampSamples) {
        envelope = (toneSamples - i) / rampSamples;
      }

      final s1 = sin(2 * pi * freq1 * t);
      final s2 = sin(2 * pi * freq2 * t);
      final sample = ((s1 + s2) * 0.35 * envelope * 32767).toInt();
      pcmData[i] = sample.clamp(-32768, 32767);
    } else {
      pcmData[i] = 0;
    }
  }

  // Create WAV header
  final byteData = ByteData(44 + pcmData.lengthInBytes);
  // RIFF chunk descriptor
  byteData.setUint32(0, 0x52494646, Endian.big); // "RIFF"
  byteData.setUint32(4, 36 + pcmData.lengthInBytes, Endian.little);
  byteData.setUint32(8, 0x57415645, Endian.big); // "WAVE"

  // "fmt " sub-chunk
  byteData.setUint32(12, 0x666d7420, Endian.big); // "fmt "
  byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
  byteData.setUint16(20, 1, Endian.little); // AudioFormat (1 for PCM)
  byteData.setUint16(22, 1, Endian.little); // NumChannels (1 mono)
  byteData.setUint32(24, sampleRate, Endian.little); // SampleRate
  byteData.setUint32(28, sampleRate * 2, Endian.little); // ByteRate (SampleRate * NumChannels * BitsPerSample/8)
  byteData.setUint16(32, 2, Endian.little); // BlockAlign (NumChannels * BitsPerSample/8)
  byteData.setUint16(34, 16, Endian.little); // BitsPerSample (16 bits)

  // "data" sub-chunk
  byteData.setUint32(36, 0x64617461, Endian.big); // "data"
  byteData.setUint32(40, pcmData.lengthInBytes, Endian.little);

  // Copy PCM data
  final bytes = byteData.buffer.asUint8List();
  bytes.setRange(44, bytes.length, pcmData.buffer.asUint8List());

  final targetDir = Directory('assets');
  if (!targetDir.existsSync()) {
    targetDir.createSync(recursive: true);
  }
  final targetFile = File('assets/ringback.wav');
  targetFile.writeAsBytesSync(bytes);
  print('Wrote ${bytes.length} bytes to ${targetFile.path}');
}
