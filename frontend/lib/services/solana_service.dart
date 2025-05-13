import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:solana/solana.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class WalletConnectResult {
  final String publicKey;
  final String walletName;

  WalletConnectResult({
    required this.publicKey,
    required this.walletName,
  });
}

class SolanaService {
  final SolanaClient _client = SolanaClient(
    rpcUrl: Uri.parse('https://api.mainnet-beta.solana.com'),
    websocketUrl: Uri.parse('wss://api.mainnet-beta.solana.com'),
  );
  
  // Connect to wallet (for web only)
  Future<WalletConnectResult?> connectWallet() async {
    try {
      if (kIsWeb) {
        // In web, we can use the Phantom browser extension
        return await _connectPhantomWeb();
      } else {
        // For mobile, we'd need to implement deep linking to Phantom or other apps
        // This is simplified - real implementation would use wallet adapter 
        throw Exception('Mobile wallet connection is not implemented in this example');
      }
    } catch (e) {
      debugPrint('Error connecting wallet: $e');
      return null;
    }
  }

  // Sign a message with wallet
  Future<String?> signMessage(String publicKey, String message) async {
    try {
      if (kIsWeb) {
        return await _signMessageWeb(publicKey, message);
      } else {
        throw Exception('Mobile wallet signing is not implemented in this example');
      }
    } catch (e) {
      debugPrint('Error signing message: $e');
      return null;
    }
  }

  // Web-specific methods using JavaScript interop
  Future<WalletConnectResult?> _connectPhantomWeb() async {
    // This is a simplified example using JavaScript interop
    // In a real application, you would use a proper Solana wallet adapter
    
    final bool isPhantomInstalled = await _isPhantomInstalledWeb();
    
    if (!isPhantomInstalled) {
      throw Exception('Phantom wallet is not installed');
    }
    
    final String? account = await _connectToPhantomWeb();
    
    if (account == null || account.isEmpty) {
      return null;
    }
    
    return WalletConnectResult(
      publicKey: account,
      walletName: 'Phantom',
    );
  }

  Future<bool> _isPhantomInstalledWeb() async {
    // This is a simplified JavaScript interop
    final String script = '''
      if (window.phantom?.solana?.isPhantom) {
        return true;
      }
      return false;
    ''';
    
    // In a real app, you'd use js interop from dart:js
    // This is a placeholder to indicate how it would work
    if (kIsWeb) {
      // Mock implementation for this example
      return true;
    }
    return false;
  }

  Future<String?> _connectToPhantomWeb() async {
    // This is a simplified JavaScript interop
    final String script = '''
      try {
        const resp = await window.phantom.solana.connect();
        return resp.publicKey.toString();
      } catch (err) {
        console.error(err);
        return null;
      }
    ''';
    
    // In a real app, you'd use js interop from dart:js
    // This is a placeholder to indicate how it would work
    if (kIsWeb) {
      // Mock implementation for this example
      return 'GWS7UXSg2vkPUaHt5eQtvLVnJc19KFh2TwQfcjGpLY7';
    }
    return null;
  }

  Future<String?> _signMessageWeb(String publicKey, String message) async {
    // This is a simplified JavaScript interop
    final String encodedMessage = base64.encode(utf8.encode(message));
    
    final String script = '''
      try {
        const encodedMessage = "$encodedMessage";
        const messageBytes = Uint8Array.from(atob(encodedMessage), c => c.charCodeAt(0));
        
        const { signature } = await window.phantom.solana.signMessage(
          messageBytes,
          "utf8"
        );
        
        return btoa(String.fromCharCode(...signature));
      } catch (err) {
        console.error(err);
        return null;
      }
    ''';
    
    // In a real app, you'd use js interop from dart:js
    // This is a placeholder to indicate how it would work
    if (kIsWeb) {
      // Mock implementation for this example
      return 'mocked_signature_for_testing';
    }
    return null;
  }

  // Methods for interacting with Solana blockchain
  Future<double> getBalance(String publicKey) async {
    try {
      final response = await _client.rpcClient.getBalance(publicKey);
      final balance = response.value;
      // Convert lamports to SOL (1 SOL = 10^9 lamports)
      return balance / 1000000000;
    } catch (e) {
      debugPrint('Error getting balance: $e');
      return 0;
    }
  }

  Future<String?> getTokenBalance(String publicKey, String tokenMint) async {
    try {
      // Simplified implementation due to compatibility issues
      return "0.0";
    } catch (e) {
      debugPrint('Error getting token balance: $e');
      return null;
    }
  }
}
