import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
 import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
// ignore: unused_import
import 'package:avatar_glow/avatar_glow.dart';
import 'dart:math'; // Pour la fonction max()
 
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ChatbotScreenState createState() => ChatbotScreenState();
}

class ChatbotScreenState extends State<ChatbotScreen> {
    final Map<String, dynamic> faq = {
  // ========== PRINCIPALES QUESTIONS ==========
  "Comment utiliser un extincteur ?": {
    "response": """**Étapes d'utilisation :**\n\n1. **Tirez la goupille** de sécurité\n2. **Visez la base** des flammes\n3. **Appuyez** sur la poignée\n4. **Balayez** de gauche à droite\n\n📹 [Vidéo démonstrative](https://youtu.be/n2UU1Dc4W44)""",
    "followUp": [
      "Quels types d'extincteurs existe-t-il ?",
      "Comment vérifier un extincteur ?",
      "Où placer les extincteurs ?"
    ],
    "keywords": ["utiliser", "extincteur", "mode d'emploi", "étapes"]
  },
  
  "Que faire en cas d'incendie ?": {
    "response": """**Procédure d'urgence :**\n\n1. 🚨 Alertez les secours (198)\n2. 🚪 Fermez les portes derrière vous\n3. 🚶 Évacuez calmement\n4. 🔥 Si bloqué :\n   - Restez près du sol\n   - Signalez votre position\n\n📞 **Numéros :** Pompiers: 198 | Ambulance: 190""",
    "followUp": [
      "Comment évacuer un bâtiment ?",
      "Que faire si pris dans la fumée ?",
      "Comment prévenir les incendies ?"
    ],
    "keywords": ["incendie", "urgence", "procédure", "feu"]
  },

  // ========== EXTINCTEURS ==========
  "Quels types d'extincteurs existe-t-il ?": {
    "response": """**Types principaux :**\n\n🧯 **Eau (A)** : Feux solides (bois, papier)\n🧯 **CO2 (B/C)** : Liquides & électriques\n🧯 **Poudre (ABC)** : Polyvalent mais salissant\n🧯 **Classe K** : Cuisines (graisses)\n\n🔍 [Guide complet](https://www.seton.fr/types-extincteurs)""",
    "followUp": [
      "Quel extincteur pour une maison ?",
      "Durée de vie des extincteurs ?",
      "Où acheter un extincteur ?"
    ],
    "keywords": ["types", "extincteurs", "classement", "catégories"]
  },

  "Comment vérifier un extincteur ?": {
    "response": """**Vérifications :**\n\n✅ Manomètre dans le vert\n✅ Goupille intacte\n✅ Pas de rouille/dégâts\n✅ Date de validité OK\n\n⏳ **Maintenance :**\n- Contrôle annuel obligatoire\n- Révision tous les 5 ans""",
    "followUp": [
      "Où faire réviser un extincteur ?",
      "Signes de dysfonctionnement ?",
      "Péremption extincteur ?"
    ],
    "keywords": ["vérifier", "contrôler", "état", "maintenance"]
  },

  "Où placer les extincteurs ?": {
    "response": """**Emplacements recommandés :**\n\n🏠 **Maison :**\n- Près de la cuisine\n- Près du tableau électrique\n- Dans le garage\n\n🏢 **Entreprise :**\n- Tous les 15 mètres\n- Près des sorties\n- Zones à risque\n\n📏 **Hauteur :** 1m à 1m50 du sol""",
    "followUp": [
      "Combien d'extincteurs faut-il ?",
      "Comment signaler un extincteur ?",
      "Règlementation emplacement ?"
    ],
    "keywords": ["placer", "position", "emplacement", "installation"]
  },

  // ========== PRÉVENTION ==========
  "Comment prévenir les incendies ?": {
    "response": """**Prévention :**\n\n🏠 **Maison :**\n- Pas de surcharge électrique\n- Surveillance cuisson\n- Détecteurs de fumée\n\n🏢 **Entreprise :**\n- Formations régulières\n- Issues dégagées\n- Plans d'évacuation\n\n📊 [Checklist PDF](https://www.prevention-incendie.gouv.fr/checklist)""",
    "followUp": [
      "Quels détecteurs installer ?",
      "Règlementation entreprise ?",
      "Exercice évacuation ?"
    ],
    "keywords": ["prévenir", "éviter", "risques", "prévention"]
  },

  // ========== URGENCES ==========
  "Que faire si pris dans la fumée ?": {
    "response": """**Conduite à tenir :**\n\n1. Rester près du sol\n2. Couvrir bouche/narines\n3. Avancer à 4 pattes\n4. Fermer les portes derrière soi\n\n⚠️ Ne jamais :\n- Prendre l'ascenseur\n- Retourner en arrière\n- Paniquer""",
    "followUp": [
      "Comment protéger ses voies respiratoires ?",
      "Signes intoxication fumée ?",
      "Techniques d'évacuation ?"
    ],
    "keywords": ["fumée", "intoxication", "respirer", "évacuation"]
  },

  "Comment évacuer un bâtiment ?": {
    "response": """**Procédure d'évacuation :**\n\n1. Garder son calme\n2. Suivre les sorties de secours\n3. Ne pas prendre d'ascenseur\n4. Se rendre au point de rassemblement\n5. Compter les personnes\n\n🚪 **Issues :** Toujours garder dégagées""",
    "followUp": [
      "Comment créer un plan d'évacuation ?",
      "Où sont les issues de secours ?",
      "Que faire si handicapé ?"
    ],
    "keywords": ["évacuer", "sortie", "bâtiment", "procédure"]
  },

  // ========== ÉQUIPEMENTS ==========
  "Quels détecteurs installer ?": {
    "response": """**Recommandations :**\n\n🔥 **Détecteurs fumée** :\n- Optiques (chambres)\n- Norme EN 14604\n\n⚠️ **Détecteurs CO** :\n- Près chaudières\n\n📍 **Emplacements :**\n- Plafonds\n- Loin des ventilations\n\n🛒 [Comparatif 2024](https://www.quechoisir.org/comparatif-detecteurs-incendie)""",
    "followUp": [
      "Entretien détecteurs ?",
      "Alarme connectée ?",
      "Règlementation détecteurs ?"
    ],
    "keywords": ["détecteurs", "alarme", "fumée", "installation"]
  },

  // ========== RÈGLEMENTATION ==========
  "Quelles sont les obligations légales ?": {
    "response": """**Règlementation :**\n\n🏢 **ERP :**\n- Extincteurs vérifiés\n- Plans d'évacuation\n- Exercices annuels\n\n🏠 **Habitation :**\n- Détecteurs obligatoires\n- Issues accessibles\n\n📝 [Loi n°2023-123](https://www.legifrance.gouv.fr/loi/2023-123)""",
    "followUp": [
      "Sanctions non-conformité ?",
      "Normes extincteurs ?",
      "Responsabilités employeurs ?"
    ],
    "keywords": ["loi", "obligation", "règlementation", "normes"]
  },

  // ========== FORMATIONS ==========
  "Comment se former ?": {
    "response": """**Options de formation :**\n\n1. 🚒 **Pompiers** : Sessions publiques\n2. 🏢 **Organismes agréés** :\n   - SST (Sauveteur Secouriste)\n   - ESI (Équipier de 1ère Intervention)\n3. 💻 **E-learning** : Modules en ligne\n\n📅 [Calendrier formations](https://www.pompiers.fr/formations)""",
    "followUp": [
      "Coût formation ESI ?",
      "Programme formation SST ?",
      "Validation des acquis ?"
    ],
    "keywords": ["formation", "apprendre", "stage", "diplôme"]
  },

  // ========== FOLLOW-UP QUESTIONS ==========
  "Quel extincteur pour une maison ?": {
    "response": """**Pour une maison :**\n\n🧯 **Recommandé :**\n- 1 extincteur 6kg Poudre ABC\n- 1 couverture anti-feu (cuisine)\n\n📍 **Emplacements :**\n- Cuisine\n- Près chaudière\n- Garage\n\n💰 **Budget :** 50-100€ par extincteur""",
    "followUp": [
      "Où acheter un extincteur maison ?",
      "Comment installer ?",
      "Marques recommandées ?"
    ],
    "keywords": ["maison", "habitation", "choix", "recommandation"]
  },

  "Où faire réviser un extincteur ?": {
    "response": """**Options de révision :**\n\n1. 🔧 **Centres agréés** (liste sur www.securite-incendie.gouv.fr)\n2. 🚒 **Casernes de pompiers** (certaines proposent ce service)\n3. 🛒 **Magasins spécialisés** (achat = révision offerte)\n\n⏱️ **Fréquence :** Tous les ans obligatoire""",
    "followUp": [
      "Coût révision ?",
      "Durée validité après révision ?",
      "Contrôle visuel à faire ?"
    ],
    "keywords": ["réviser", "vérifier", "entretien", "centre"]
  },

  "Comment créer un plan d'évacuation ?": {
    "response": """**Étapes de création :**\n\n1. 🖍️ Dessiner le plan du bâtiment\n2. 🚪 Identifier 2 sorties par pièce\n3. ❌ Marquer les dangers potentiels\n4. 📍 Déterminer point de rassemblement\n5. 🧑‍🏫 Former les occupants\n\n📥 [Modèle à imprimer](https://www.prevention-incendie.gouv.fr/plan-evacuation)""",
    "followUp": [
      "Exemple de plan ?",
      "Où afficher le plan ?",
      "Logiciels pour créer ?"
    ],
    "keywords": ["plan", "évacuation", "créer", "modèle"]
  }
};

// ========== METHODES DE GESTION ==========
Map<String, dynamic>? _getResponseByKeywords(String query) {
  for (final entry in faq.entries) {
    final keywords = entry.value["keywords"] as List<String>? ?? [];
    if (keywords.any((kw) => query.toLowerCase().contains(kw.toLowerCase()))) {
      return {
        "response": entry.value["response"],
        "followUp": entry.value["followUp"],
        "isRich": true
      };
    }
  }
  return null;
}
Map<String, dynamic> _findBestResponse(String query) {
  query = query.toLowerCase().trim();
  
  // 1. Vérifier les salutations
  for (final entry in greetings.entries) {
    if (query.contains(entry.key.toLowerCase())) {
      return {
        "response": entry.value,
        "followUp": ["Comment utiliser un extincteur ?", "Numéros d'urgence"],
        "isRich": false
      };
    }
  }

  // 2. Recherche exacte
  for (final entry in faq.entries) {
    if (query == entry.key.toLowerCase()) {
      return {
        "response": entry.value["response"],
        "followUp": entry.value["followUp"],
        "isRich": true
      };
    }
  }

  // 3. Recherche par mots-clés
  final keywordResponse = _getResponseByKeywords(query);
  if (keywordResponse != null) return keywordResponse;

  // 4. Réponse par défaut
  return {
    "response": "Je n'ai pas trouvé de réponse exacte. Voici ce que je peux expliquer :\n\n"
        "- Extincteurs et leur utilisation\n- Procédures d'urgence\n- Prévention des risques\n\n"
        "Pouvez-vous reformuler ou choisir un thème ?",
    "followUp": ["Aide", "Contact humain", "Menu principal"],
    "isRich": false
  };
}
  Map<String, dynamic>? _findCloseMatch(String query) {
    const stopWords = {'le', 'la', 'les', 'un', 'une', 'des', 'de', 'du', 'que', 'quoi'};
    
    final cleanQuery = query
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .where((word) => word.length > 2 && !stopWords.contains(word))
        .join(' ');

    if (cleanQuery.isEmpty) return null;

    double bestScore = 0.6;
    MapEntry<String, dynamic>? bestMatch;

    for (final entry in faq.entries) {
      final cleanEntry = entry.key
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .split(' ')
          .where((word) => word.length > 2 && !stopWords.contains(word))
          .join(' ');

      if (cleanEntry.isEmpty) continue;

      final score = _calculateSimilarity(cleanQuery, cleanEntry);
      
      if (score > bestScore) {
        bestScore = score;
        bestMatch = entry;
      }
    }

    return bestMatch != null ? {
      "question": bestMatch.key,
      "response": bestMatch.value["response"],
      "followUp": bestMatch.value["followUp"]
    } : null;
  }

  double _calculateSimilarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    
    final wordsA = a.split(' ');
    final wordsB = b.split(' ');
    
    final commonWords = wordsA.where((word) => wordsB.contains(word)).length;
    return commonWords / max(wordsA.length, wordsB.length);
  }
  // ========== FIN DES NOUVELLES METHODES ==========

  // ========== SALUTATIONS ==========
  final Map<String, String> greetings = {
    "bonjour": "Bonjour ! 👋 Je suis votre expert sécurité. Posez-moi vos questions.",
    "salut": "Salut ! 😊 Besoin d'infos sur la sécurité incendie ?",
    "aide": "Je peux vous aider sur :\n- Extincteurs\n- Procédures\n- Prévention\nDites-moi votre besoin !",
    "coucou": "Coucou ! De quoi avez-vous besoin ? 😊",
    "bonsoir": "Bonsoir ! De quoi avez-vous besoin ce soir ? 🌙",
    "bonne nuit": "Bonne nuit ! Dormez bien et n'hésitez pas à me poser des questions demain. 😴",
    "j'ai une question": "Bien sûr ! Posez-moi votre question, je suis là pour vous aider. 🤔",
    "merci beaucoup": "Je vous en prie ! N'hésitez pas si vous avez d'autres questions. 😊",
    "merci": "Je vous en prie ! 😊",
    "hello": "Hello ! Comment puis-je vous aider aujourd'hui ? 😄",
    "hi": "Hi ! Comment puis-je vous aider aujourd'hui ? 😄",
    "urgence": "🚨 **Urgence ?** Composez le:\n- 198 (Pompiers)\n- 190 (Policier)\n- 197 (Ambulance)\nDécrivez ensuite la situation."
  };

  // ========== VARIABLES D'ÉTAT ==========
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';
  
   
 @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
    _sendWelcomeMessage();
  }

  // ========== FONCTIONS PRINCIPALES ==========
  void _sendWelcomeMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendBotMessage(
        "Je peux vous informer sur :\n"
        "- 🧯 Utilisation des extincteurs\n"
        "- 🚨 Procédures d'urgence\n"
        "- 🏢 Conformité réglementaire\n"
        "- 🛡️ Prévention des risques\n\n"
        "Posez votre question ou essayez :\n"
        "- 'Comment utiliser un extincteur ?'\n"
        "- 'Que faire en cas de fumée ?'",
        suggestions: ["Bonjour", "Aide", "Urgence"]
      );
    });
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone non disponible')),
      );
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _lastWords = val.recognizedWords;
            if (val.finalResult) {
              _controller.text = _lastWords;
              _stopListening();
            }
          }),
        );
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "role": "user", 
        "message": text,
        "time": DateTime.now()
      });
      
      // Faire défiler vers le bas
      _scrollToBottom();
    });

    _controller.clear();

    // Simuler un délai de réponse
    Future.delayed(Duration(milliseconds: 800), () {
      final response = _findResponse(text);
      _sendBotMessage(response["response"], 
        followUp: response["followUp"],
        isRich: response["isRich"]
      );
    });
  }

  void _sendBotMessage(String message, {List<String>? followUp, bool isRich = false, List<String>? suggestions}) {
    setState(() {
      messages.add({
        "role": "bot",
        "message": message,
        "time": DateTime.now(),
        "isRich": isRich,
        "followUp": followUp,
      });
      
      
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

   
  Map<String, dynamic> _findResponse(String query) {
    query = query.toLowerCase();

     // 1. Vérifier les salutations
    for (final entry in greetings.entries) {
      if (_isSimilar(query, entry.key)) {
        return {
          "response": entry.value,
          "followUp": ["Comment utiliser un extincteur ?", "Numéros d'urgence"],
          "isRich": true
        };
      }
    }

    // 2. Recherche exacte
    for (final entry in faq.entries) {
      if (_isSimilar(query, entry.key)) {
        return {
          "response": entry.value["response"],
          "followUp": entry.value["followUp"],
          "isRich": true
        };
      }
    }
     
     // 3. Recherche par mots-clés
  final keywordResponse = _getResponseByKeywords(query);
  if (keywordResponse != null) return keywordResponse;

  // 4. Recherche approximative
  final closeMatch = _findCloseMatch(query);
  if (closeMatch != null) {
    return {
      "response": "Voulez-vous dire : ${closeMatch['question']} ?\n\n${closeMatch['response']}",
      "followUp": closeMatch['followUp'],
      "isRich": true
    };
  }
  
    // 5. Réponse par défaut
  return {
    "response": "Je n'ai pas trouvé de réponse exacte. Voici ce que je peux expliquer :\n\n"
        "- Utilisation des extincteurs\n- Procédures d'urgence\n- Prévention des risques",
    "followUp": ["Aide", "Contact humain"],
    "isRich": false
  };
  }

  bool _isSimilar(String a, String b) {
    a = a.toLowerCase();
    b = b.toLowerCase();
    return a.contains(b) || b.contains(a);
  }

   @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "Assistant Chatbot",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline, color: Colors.white),
              onPressed: () => _showHelpDialog(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Animation et indicateur vocal
            Stack(
              alignment: Alignment.center,
              children: [
                if (_isListening)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                Lottie.asset(
                  'assets/animations/chatbot.json',
                  width: 80,
                  height: 80,
                ),
              ],
            ),
            if (_isListening)
              Text(
                "Je vous écoute...",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),

            // Messages de chat
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),

            // Suggestions de suivi
            if (messages.isNotEmpty && messages.last["followUp"] != null)
              _buildFollowUpSuggestions(messages.last["followUp"]),

            // Barre de saisie
            _buildInputBar(),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  
  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final bool isUser = message["role"] == "user";
    final time = message["time"] as DateTime;
    
    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          padding: EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          decoration: BoxDecoration(
            color: isUser 
              ? Colors.blueAccent.withOpacity(0.2)
              : Colors.redAccent.withOpacity(0.2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isUser ? 12 : 0),
              topRight: Radius.circular(isUser ? 0 : 12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUser ? "Vous" : "Assistant Sécurité",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUser ? Colors.blueAccent : Colors.redAccent,
                ),
              ),
              SizedBox(height: 4),
              if (message["isRich"] ?? false)
                MarkdownBody(
                  data: message["message"],
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(color: Colors.white, fontSize: 16),
                    a: TextStyle(color: Colors.blueAccent),
                  ),
                  onTapLink: (text, href, title) {
                    if (href != null) _launchURL(href);
                  },
                )
              else
                Text(
                  message["message"],
                  style: TextStyle(color: Colors.white),
                ),
              SizedBox(height: 4),
              Text(
                '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        if (!isUser && (message["followUp"] ?? []).isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: 12, top: 4),
            child: Text(
              "Suggestions:",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFollowUpSuggestions(List<String>? suggestions) {
    if (suggestions == null || suggestions.isEmpty) return SizedBox();
    
    return Container(
  height: 50,
  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: suggestions.length,
    itemBuilder: (context, index) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: Text(suggestions[index]),  // Remplacement du ; par ,
          selected: false,  // Ajout du paramètre required
          onSelected: (bool selected) => _sendMessage(suggestions[index]),  // Correction de la syntaxe
          backgroundColor: Colors.redAccent.withOpacity(0.2),
          selectedColor: Colors.redAccent,
          labelStyle: TextStyle(color: Colors.white),  // Correction de "labelstyle" à "labelStyle"
        ), // ChoiceChip
      ); // Container
    },
  ), // ListView.builder
); // Container
  }

  Widget _buildInputBar() {
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic_off : Icons.mic,
              color: _isListening ? Colors.red : Colors.white,
            ),
            onPressed: () {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening();
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Écrivez ou parlez...",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.white),
              maxLines: null,
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.white),
            onPressed: () => _sendMessage(_controller.text),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Aide de l'assistant"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Je peux vous aider sur :"),
            SizedBox(height: 10),
            _buildHelpItem("🚨", "Procédures d'urgence"),
            _buildHelpItem("🔥", "Prévention incendie"),
            _buildHelpItem("🧯", "Utilisation des équipements"),
            _buildHelpItem("📞", "Contacts d'urgence"),
            SizedBox(height: 20),
            Text("Essayez des questions comme :"),
            Text("- Où sont les extincteurs ?"),
            Text("- Que faire en cas de fumée ?"),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Fermer"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 20)),
          SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible d'ouvrir le lien")),
      );
    }
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 137, 17, 119),
            Color.fromARGB(255, 72, 6, 53),
          ],
        ),
      ),
      child: child,
    );
  }
}