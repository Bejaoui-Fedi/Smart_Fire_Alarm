import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Pour utiliser jsonEncode et jsonDecode

class ChatHistory {
  final String id;
  final String title;
  final DateTime date;
  final List<Map<String, String>> messages;

  ChatHistory({
    required this.id,
    required this.title,
    required this.date,
    required this.messages,
  });

  // Convertir un objet ChatHistory en Map pour la sauvegarde
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'messages': messages,
    };
  }

  // Convertir un Map en objet ChatHistory
  factory ChatHistory.fromJson(Map<String, dynamic> json) {
    return ChatHistory(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      messages: List<Map<String, String>>.from(json['messages']),
    );
  }
}

class ChatHistoryProvider with ChangeNotifier {
  final List<ChatHistory> _chatHistory = [];

  List<ChatHistory> get chatHistory => _chatHistory;

  // Charger l'historique depuis SharedPreferences
  Future<void> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('chatHistory') ?? [];

    _chatHistory.clear();
    _chatHistory.addAll(
      historyJson.map((json) => ChatHistory.fromJson(jsonDecode(json))),
    );

    notifyListeners();
  }

  // Ajouter une nouvelle conversation à l'historique
  Future<void> addChatHistory(ChatHistory chat) async {
    _chatHistory.add(chat);
    notifyListeners();

    // Sauvegarder dans SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _chatHistory.map((chat) => jsonEncode(chat.toJson())).toList();
    prefs.setStringList('chatHistory', historyJson);
  }

  // Supprimer une conversation de l'historique
  Future<void> removeChatHistory(String id) async {
    _chatHistory.removeWhere((chat) => chat.id == id);
    notifyListeners();

    // Mettre à jour SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _chatHistory.map((chat) => jsonEncode(chat.toJson())).toList();
    prefs.setStringList('chatHistory', historyJson);
  }

  // Effacer tout l'historique
  Future<void> clearChatHistory() async {
    _chatHistory.clear();
    notifyListeners();

    // Supprimer de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('chatHistory');
  }
}