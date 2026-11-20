# Smart Fire Alarm — Alarme incendie intelligente

Application mobile Flutter réalisée dans le cadre d’un projet de fin d’études. Elle rassemble le suivi de capteurs, la visualisation des mesures, les alertes, l’analyse des risques et le pilotage d’équipements.

> Ce projet est un prototype académique et ne remplace pas un système d’alarme certifié ni les services de secours.

## Fonctionnalités par module

### 1. Tableau de bord et suivi des capteurs

L’accueil donne une vue rapide sur les mesures et l’état des capteurs. Les graphiques permettent de consulter les relevés de température, d’humidité et de gaz, de choisir le nombre de points affichés et d’activer ou désactiver le mode temps réel.

<table>
  <tr>
    <td align="center" width="50%"><strong>Vue d’ensemble</strong><br><img src="screenshots/dashboard-and-alerts.png" alt="Tableau de bord des capteurs et aperçu des alertes" width="360"></td>
    <td align="center" width="50%"><strong>Mesures et graphiques</strong><br><img src="screenshots/sensor-charts-live.png" alt="Graphiques capteurs avec sélection de période et mode temps réel" width="360"></td>
  </tr>
</table>

### 2. Alertes et analyse des risques

Les alertes peuvent être consultées et triées depuis l’application, avec des indicateurs de notifications non lues. L’écran d’analyse présente le niveau et le score de risque associés aux capteurs.

<table>
  <tr>
    <td align="center" width="50%"><strong>Gestion des alertes</strong><br><img src="screenshots/alert-sorting.png" alt="Options de tri et liste des alertes" width="360"></td>
    <td align="center" width="50%"><strong>Évaluation du risque</strong><br><img src="screenshots/fire-risk-analysis.png" alt="Niveaux et scores d’analyse des risques par capteur" width="360"></td>
  </tr>
</table>

### 3. Pilotage des équipements

Des écrans dédiés affichent l’état de l’extincteur et du ventilateur. Des commandes rapides regroupent les actions principales. Les états des appareils sont synchronisés avec les données Supabase du projet.

<table>
  <tr>
    <td align="center" width="50%"><strong>Extincteur</strong><br><img src="screenshots/extinguisher-controls.png" alt="Commande et état de l’extincteur" width="360"></td>
    <td align="center" width="50%"><strong>Ventilation</strong><br><img src="screenshots/ventilation-controls.png" alt="Commande et état du ventilateur" width="360"></td>
  </tr>
  <tr>
    <td colspan="2" align="center"><strong>Accès rapide aux commandes</strong><br><img src="screenshots/quick-device-controls.png" alt="Commandes rapides des équipements" width="420"></td>
  </tr>
</table>

### 4. Assistant de sécurité incendie

Le chatbot propose une interface de questions-réponses avec des suggestions et des fonctions vocales. Les captures montrent l’écran d’accueil de l’assistant et des exemples d’échanges.

<table>
  <tr>
    <td align="center" width="50%"><strong>Accueil de l’assistant</strong><br><img src="screenshots/fire-safety-chat-assistant.png" alt="Assistant de sécurité incendie et questions suggérées" width="360"></td>
    <td align="center" width="50%"><strong>Exemples de conversation</strong><br><img src="screenshots/fire-safety-chat-examples.png" alt="Exemples de questions et réponses du chatbot" width="360"></td>
  </tr>
</table>

### 5. Connexion, compte et personnalisation

Les paramètres regroupent les préférences d’affichage, la gestion du profil et les options du compte. L’application propose également un écran de connexion.

Les captures d’écran du profil ont été anonymisées pour protéger les informations personnelles.

<table>
  <tr>
    <td align="center" width="50%"><strong>Connexion et paramètres</strong><br><img src="screenshots/authentication-and-settings.png" alt="Écrans de connexion et de paramètres" width="360"></td>
    <td align="center" width="50%"><strong>Thème et profil</strong><br><img src="screenshots/theme-and-profile-settings-anonymized.png" alt="Réglages d’apparence et profil" width="360"></td>
  </tr>
  <tr>
    <td colspan="2" align="center"><strong>Informations du compte</strong><br><img src="screenshots/profile-and-account-anonymized.png" alt="Gestion du profil et des informations du compte" width="420"></td>
  </tr>
</table>

## Architecture

L’application est initialisée dans `lib/main.dart` : Supabase est configuré, puis `MultiProvider` fournit l’état partagé à l’interface Flutter. `NavigationWrapper` organise les onglets Accueil, Chatbot et Paramètres. Les écrans et widgets sont séparés dans `lib/views/` et `lib/widgets/`; les modèles décrivent les mesures et les alertes.

```mermaid
flowchart TD
    Main[main.dart] --> Supabase[Supabase Flutter]
    Main --> Providers[MultiProvider]
    Providers --> App[MaterialApp / ThemeProvider]
    App --> Navigation[NavigationWrapper]
    Navigation --> Screens[Accueil, Chatbot, Paramètres]
    Screens --> SensorViews[Cartes de données et graphiques]
    Screens --> AlertViews[Alertes et analyse des risques]
    Screens --> DeviceViews[Extincteur et ventilateur]
    SensorViews --> Supabase
    AlertViews --> Supabase
    DeviceViews --> Supabase
    Supabase --> Tables[(capteurs, alerts, fire_risk_analysis, états des appareils)]
    Supabase --> Realtime[Broadcast et changements Postgres]
    Realtime --> Counters[Providers de compteurs non lus]
    Providers --> Local[SharedPreferences]
```

Les mesures sont lues dans `capteurs`; les alertes et les analyses de risque proviennent de `alerts` et `fire_risk_analysis`. Le pilotage utilise les tables d’état de l’extincteur et du ventilateur. Les providers gèrent notamment le thème et les compteurs ; `SharedPreferences` conserve des préférences et l’historique local du chatbot. Des services dédiés gèrent les alertes et les notifications.

## Technologies

- **Flutter / Dart** pour l’application mobile.
- **Supabase** pour l’authentification, les données et les flux temps réel.
- **Provider** pour l’état partagé.
- **fl_chart** et **Syncfusion Charts** pour les visualisations.
- **SharedPreferences** pour les préférences et l’historique local.
- **speech_to_text** et **flutter_tts** pour les fonctions vocales.
- **permission_handler**, **url_launcher** et **image_picker** pour les fonctions de l’application.

## Lancer l’application

Prérequis : Flutter avec un SDK Dart compatible avec `^3.7.0`, ainsi qu’un appareil ou un émulateur configuré.

Configurez l’URL Supabase et une clé anon dans l’initialisation de Supabase dans `lib/main.dart`, et définissez les règles d’accès nécessaires sur les tables et les flux Realtime. Ne publiez jamais de clé `service_role` dans une application mobile.

```bash
flutter pub get
flutter run
```

Pour générer un APK Android :

```bash
flutter build apk
```
