import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellyess/models/user_model.dart';
import '../widgets/base_layout.dart';
import '../widgets/feature_card.dart';
import '../widgets/sos_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'med_section.dart';
import 'consigli_salute.dart';
import 'sos.dart';
import 'monitoring_section.dart';
import 'med_diary.dart';
import 'user_profile.dart';
import 'package:provider/provider.dart';
import 'package:wellyess/models/accessibilita_model.dart';
import 'tutorial_page.dart';    // ← importa la Guida Rapida

class HomePage extends StatefulWidget {
  final int? farmacoKeyToShow;

  const HomePage({super.key, this.farmacoKeyToShow});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserType? _userType; // Tipo utente (caregiver, anziano, ecc.)
  bool _isLoading = true; // Stato di caricamento

  @override
  void initState() {
    super.initState();
    _loadUserType(); // Carica il tipo di utente dalle preferenze

    // Mostra la Guida Rapida al primo avvio
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final shown = prefs.getBool('tutorial_shown') ?? false;
      if (!shown) {
        await prefs.setBool('tutorial_shown', true);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TutorialPage()),
        );
      }
    });

    // Se c'è una chiave da evidenziare, apri subito la FarmaciPage
    if (widget.farmacoKeyToShow != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  FarmaciPage(farmacoKeyToShow: widget.farmacoKeyToShow!),
            ),
          );
        }
      });
    }
  }

  // Carica il tipo di utente dalle SharedPreferences
  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    final userTypeString = prefs.getString('userType');
    if (mounted) {
      setState(() {
        _userType = userTypeString != null
            ? UserType.values
                .firstWhere((e) => e.toString() == userTypeString)
            : null;
        _isLoading = false;
      });
    }
  }

  // Restituisce il percorso dell'icona SVG in base al tema (contrasto alto o normale)
  String _getIconAsset(String baseName, bool highContrast) {
    // Usa la versione nera se highContrast, altrimenti la versione verde
    switch (baseName) {
      case 'pills':
        return highContrast
            ? 'assets/icons/Pill_icon_black_v.svg'
            : 'assets/icons/pills.svg';
      case 'heartbeat':
        return highContrast
            ? 'assets/icons/Heartbeat_black_v.svg'
            : 'assets/icons/heartbeat.svg';
      case 'calendar':
        return highContrast
            ? 'assets/icons/Caldendar_black_v.svg'
            : 'assets/icons/calendar.svg';
      case 'sport':
        return highContrast
            ? 'assets/icons/Sport_black_v.svg'
            : 'assets/icons/sport_food.svg';
      case 'elder':
        return highContrast
            ? 'assets/icons/Elder_black_v.svg'
            : 'assets/icons/elder_ic.svg';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Recupera impostazioni di accessibilità dal provider
    final access = context.watch<AccessibilitaModel>();
    final highContrast = access.highContrast;
    final fontSizeFactor = access.fontSizeFactor;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double iconSize = screenWidth * 0.14 * fontSizeFactor;
    final double cardHeight = screenHeight * 0.16;

    // Mostra loader se i dati sono in caricamento
    if (_isLoading) {
      return BaseLayout(
        pageTitle: 'Home', // ← aggiunto
        userType: _userType,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final isCaregiver = _userType == UserType.caregiver;

    return BaseLayout(
      pageTitle: 'Home', // ← aggiunto
      currentIndex: 1,
      userType: _userType,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.01),
            // Messaggio di benvenuto personalizzato in base al tipo utente
            Align(
              alignment: Alignment.center,
              child: Text(
                isCaregiver ? "Bentornata,\nSvetlana!" : "Bentornato,\nMichele!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.075 * fontSizeFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            SizedBox(height: screenHeight * 0.02),
            // Sezione delle funzionalità principali (Farmaci, Parametri, Agenda, Salute/Assistito)
            Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    children: [
                      // Card Farmaci
                      Expanded(
                        child: SizedBox(
                          height: cardHeight,
                          child: FeatureCard(
                            icon: SvgPicture.asset(
                              _getIconAsset('pills', highContrast),
                              height: iconSize,
                              width: iconSize,
                            ),
                            label: "Farmaci",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FarmaciPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      // Card Parametri
                      Expanded(
                        child: SizedBox(
                          height: cardHeight,
                          child: FeatureCard(
                            icon: SvgPicture.asset(
                              _getIconAsset('heartbeat', highContrast),
                              height: iconSize,
                              width: iconSize,
                            ),
                            label: "Parametri",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const MonitoraggioParametriPage()),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      // Card Agenda
                      Expanded(
                        child: SizedBox(
                          height: cardHeight,
                          child: FeatureCard(
                            icon: SvgPicture.asset(
                              _getIconAsset('calendar', highContrast),
                              height: iconSize,
                              width: iconSize,
                            ),
                            label: "Agenda",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MedDiaryPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      // Card Salute (per anziano) o Assistito (per caregiver)
                      Expanded(
                        child: SizedBox(
                          height: cardHeight,
                          child: isCaregiver
                              ? _buildAssistitoCard(iconSize, highContrast, fontSizeFactor)
                              : _buildConsigliCard(iconSize, highContrast, fontSizeFactor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            // Pulsante SOS in fondo alla pagina
            SizedBox(
              width: double.infinity,
              height: screenHeight * 0.1,
              child: SosButton(
                userType: _userType!,
                hasNewRequest: isCaregiver,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EmergenzaScreen()),
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
          ],
        ),
      ),
    );
  }

  // Card "Assistito" per il caregiver
  Widget _buildAssistitoCard(double iconSize, bool highContrast, double fontSizeFactor) {
    return FeatureCard(
      icon: SvgPicture.asset(
        _getIconAsset('elder', highContrast),
        height: iconSize,
        width: iconSize,
      ),
      label: "Assistito",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfiloUtente(forceElderView: true),
          ),
        );
      },
    );
  }

  // Card "Salute" per l'anziano
  Widget _buildConsigliCard(double iconSize, bool highContrast, double fontSizeFactor) {
    return FeatureCard(
      icon: SvgPicture.asset(
        _getIconAsset('sport', highContrast),
        height: iconSize,
        width: iconSize,
      ),
      label: "Salute",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ConsigliSalutePage(),
          ),
        );
      },
    );
  }
}