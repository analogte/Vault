/// Stub file for web platform (no file system access)
class VaultServiceIO {
  static Future<String> createVaultDirectory(String vaultId) async {
    // On web, return virtual path
    return 'vaults/$vaultId';
  }
  
  static Future<void> deleteVaultDirectory(String vaultPath) async {
    // On web, nothing to delete (virtual path)
  }
}
