import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Helper functions for file system operations (mobile/desktop only)
class VaultServiceIO {
  static Future<String> createVaultDirectory(String vaultId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final vaultDir = Directory(path.join(appDir.path, 'vaults', vaultId));
      await vaultDir.create(recursive: true);
      
      // Create vault structure
      final dDir = Directory(path.join(vaultDir.path, 'd'));
      await dDir.create(recursive: true);
      
      return vaultDir.path;
    } catch (e) {
      // Fallback to temp directory
      final tempDir = Directory.systemTemp;
      final vaultDir = Directory(path.join(tempDir.path, 'secure_vault', 'vaults', vaultId));
      await vaultDir.create(recursive: true);
      
      final dDir = Directory(path.join(vaultDir.path, 'd'));
      await dDir.create(recursive: true);
      
      return vaultDir.path;
    }
  }
  
  static Future<void> deleteVaultDirectory(String vaultPath) async {
    final vaultDir = Directory(vaultPath);
    if (await vaultDir.exists()) {
      await vaultDir.delete(recursive: true);
    }
  }
}
