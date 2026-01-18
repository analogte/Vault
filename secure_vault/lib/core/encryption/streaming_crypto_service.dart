import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/export.dart';
import 'package:uuid/uuid.dart';
import '../utils/logger.dart';

/// Service for streaming encryption/decryption of large files
/// Uses chunked processing to avoid memory issues with large files
class StreamingCryptoService {
  static const String _tag = 'StreamingCryptoService';

  /// Chunk size for processing (4MB)
  static const int chunkSize = 4 * 1024 * 1024;

  /// Threshold for using streaming encryption (50MB)
  static const int streamingThreshold = 50 * 1024 * 1024;

  /// Check if a file should use streaming encryption
  static bool shouldUseStreaming(int fileSize) {
    return fileSize > streamingThreshold;
  }

  /// Encrypt a large file using chunked streaming
  /// Returns path to encrypted file
  Future<StreamingEncryptResult> encryptFile({
    required String inputPath,
    required Uint8List key,
    Function(double progress)? onProgress,
  }) async {
    try {
      final inputFile = File(inputPath);
      final fileSize = await inputFile.length();
      final totalChunks = (fileSize / chunkSize).ceil();

      AppLogger.log(
        'Starting streaming encryption: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB, $totalChunks chunks',
        tag: _tag,
      );

      // Create output file
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/${const Uuid().v4()}.enc';
      final outputFile = File(outputPath);
      final outputSink = outputFile.openWrite();

      // Write header: file size (8 bytes) + chunk count (4 bytes)
      final header = ByteData(12);
      header.setInt64(0, fileSize);
      header.setInt32(8, totalChunks);
      outputSink.add(header.buffer.asUint8List());

      // Process each chunk
      final inputStream = inputFile.openRead();
      int chunkIndex = 0;
      List<int> buffer = [];

      await for (final data in inputStream) {
        buffer.addAll(data);

        // Process complete chunks
        while (buffer.length >= chunkSize) {
          final chunk = Uint8List.fromList(buffer.sublist(0, chunkSize));
          buffer = buffer.sublist(chunkSize);

          final encryptedChunk = await _encryptChunk(chunk, key, chunkIndex);
          outputSink.add(encryptedChunk);

          chunkIndex++;
          onProgress?.call(chunkIndex / totalChunks);
        }
      }

      // Process remaining data
      if (buffer.isNotEmpty) {
        final chunk = Uint8List.fromList(buffer);
        final encryptedChunk = await _encryptChunk(chunk, key, chunkIndex);
        outputSink.add(encryptedChunk);
        chunkIndex++;
      }

      await outputSink.close();

      AppLogger.log(
        'Streaming encryption complete: $chunkIndex chunks',
        tag: _tag,
      );

      return StreamingEncryptResult(
        encryptedFilePath: outputPath,
        originalSize: fileSize,
        chunkCount: chunkIndex,
        isChunked: true,
      );
    } catch (e) {
      AppLogger.error('Streaming encryption error', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Decrypt a chunked encrypted file
  /// Returns path to decrypted file
  Future<String> decryptFile({
    required String inputPath,
    required Uint8List key,
    required String outputFileName,
    Function(double progress)? onProgress,
  }) async {
    try {
      final inputFile = File(inputPath);
      final inputStream = inputFile.openRead();

      // Create output file
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/$outputFileName';
      final outputFile = File(outputPath);
      final outputSink = outputFile.openWrite();

      // Read header
      bool headerRead = false;
      int fileSize = 0;
      int totalChunks = 0;
      int chunkIndex = 0;
      List<int> buffer = [];

      // Size of each encrypted chunk: chunkSize + 12 (IV) + 16 (tag) + 4 (chunk length)
      const encryptedChunkOverhead = 12 + 16 + 4;

      await for (final data in inputStream) {
        buffer.addAll(data);

        // Read header first
        if (!headerRead && buffer.length >= 12) {
          final headerData = ByteData.view(Uint8List.fromList(buffer.sublist(0, 12)).buffer);
          fileSize = headerData.getInt64(0);
          totalChunks = headerData.getInt32(8);
          buffer = buffer.sublist(12);
          headerRead = true;

          AppLogger.log(
            'Decrypting file: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB, $totalChunks chunks',
            tag: _tag,
          );
        }

        if (!headerRead) continue;

        // Process encrypted chunks
        while (true) {
          // Check if we have enough data for chunk length
          if (buffer.length < 4) break;

          final chunkLengthData = ByteData.view(Uint8List.fromList(buffer.sublist(0, 4)).buffer);
          final encryptedChunkLength = chunkLengthData.getInt32(0);

          // Check if we have the full encrypted chunk
          if (buffer.length < 4 + encryptedChunkLength) break;

          final encryptedChunk = Uint8List.fromList(
            buffer.sublist(4, 4 + encryptedChunkLength),
          );
          buffer = buffer.sublist(4 + encryptedChunkLength);

          final decryptedChunk = await _decryptChunk(encryptedChunk, key, chunkIndex);
          outputSink.add(decryptedChunk);

          chunkIndex++;
          onProgress?.call(chunkIndex / totalChunks);
        }
      }

      await outputSink.close();

      AppLogger.log(
        'Streaming decryption complete: $chunkIndex chunks',
        tag: _tag,
      );

      return outputPath;
    } catch (e) {
      AppLogger.error('Streaming decryption error', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Encrypt a single chunk using AES-256-GCM
  Future<Uint8List> _encryptChunk(Uint8List chunk, Uint8List key, int chunkIndex) async {
    return compute(_encryptChunkIsolate, _ChunkData(chunk, key, chunkIndex));
  }

  /// Decrypt a single chunk using AES-256-GCM
  Future<Uint8List> _decryptChunk(Uint8List encryptedChunk, Uint8List key, int chunkIndex) async {
    return compute(_decryptChunkIsolate, _ChunkData(encryptedChunk, key, chunkIndex));
  }
}

/// Data class for chunk processing in isolate
class _ChunkData {
  final Uint8List data;
  final Uint8List key;
  final int chunkIndex;

  _ChunkData(this.data, this.key, this.chunkIndex);
}

/// Encrypt chunk in isolate
Uint8List _encryptChunkIsolate(_ChunkData data) {
  // Generate IV (12 bytes) based on chunk index for deterministic encryption
  final iv = Uint8List(12);
  final random = FortunaRandom();
  random.seed(KeyParameter(Uint8List.fromList([...data.key, data.chunkIndex])));
  for (int i = 0; i < 12; i++) {
    iv[i] = random.nextUint8();
  }

  // Initialize AES-GCM cipher
  final cipher = GCMBlockCipher(AESEngine());
  final params = AEADParameters(
    KeyParameter(data.key),
    128, // tag length in bits
    iv,
    Uint8List(0), // no additional authenticated data
  );
  cipher.init(true, params);

  // Encrypt
  final ciphertext = Uint8List(cipher.getOutputSize(data.data.length));
  final len = cipher.processBytes(data.data, 0, data.data.length, ciphertext, 0);
  cipher.doFinal(ciphertext, len);

  // Build output: chunk length (4 bytes) + IV (12 bytes) + ciphertext with tag
  final output = BytesBuilder();

  // Write total length
  final lengthData = ByteData(4);
  lengthData.setInt32(0, 12 + ciphertext.length);
  output.add(lengthData.buffer.asUint8List());

  // Write IV + ciphertext
  output.add(iv);
  output.add(ciphertext);

  return output.toBytes();
}

/// Decrypt chunk in isolate
Uint8List _decryptChunkIsolate(_ChunkData data) {
  // Extract IV (first 12 bytes)
  final iv = data.data.sublist(0, 12);
  final ciphertext = data.data.sublist(12);

  // Initialize AES-GCM cipher
  final cipher = GCMBlockCipher(AESEngine());
  final params = AEADParameters(
    KeyParameter(data.key),
    128, // tag length in bits
    iv,
    Uint8List(0), // no additional authenticated data
  );
  cipher.init(false, params);

  // Decrypt
  final plaintext = Uint8List(cipher.getOutputSize(ciphertext.length));
  final len = cipher.processBytes(ciphertext, 0, ciphertext.length, plaintext, 0);
  cipher.doFinal(plaintext, len);

  // Remove padding (GCM doesn't use padding, but output might have extra bytes)
  return Uint8List.fromList(plaintext.sublist(0, len + cipher.getOutputSize(0) - 16));
}

/// Result of streaming encryption
class StreamingEncryptResult {
  final String encryptedFilePath;
  final int originalSize;
  final int chunkCount;
  final bool isChunked;

  StreamingEncryptResult({
    required this.encryptedFilePath,
    required this.originalSize,
    required this.chunkCount,
    required this.isChunked,
  });
}
