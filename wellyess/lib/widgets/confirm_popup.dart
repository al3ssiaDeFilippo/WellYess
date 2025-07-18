import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellyess/models/accessibilita_model.dart';
import 'package:wellyess/widgets/tappable_reader.dart';
import 'package:wellyess/services/flutter_tts.dart';

// Dialog di conferma riutilizzabile con due pulsanti (Annulla/Conferma)
class ConfirmDialog extends StatelessWidget {
  final String titleText;         // Testo del titolo della dialog
  final String cancelButtonText;  // Testo del pulsante Annulla
  final String confirmButtonText; // Testo del pulsante Conferma
  final VoidCallback onCancel;    // Callback quando si preme Annulla
  final VoidCallback onConfirm;   // Callback quando si preme Conferma

  const ConfirmDialog({
    Key? key,
    required this.titleText,
    required this.cancelButtonText,
    required this.confirmButtonText,
    required this.onCancel,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    // Accessibilità: recupera fattore testo, contrasto e TalkBack dal provider
    final access = context.watch<AccessibilitaModel>();
    final fontSizeFactor = access.fontSizeFactor;
    final highContrast = access.highContrast;

    // Colori adattati per l'accessibilità
    final Color bgColor = highContrast ? Colors.yellow.shade700 : Colors.white;
    final Color borderColor = highContrast ? Colors.black : Colors.transparent;
    final Color titleColor = highContrast ? Colors.black : Colors.black87;
    final Color cancelBg = highContrast ? Colors.black : Colors.red;
    final Color confirmBg = highContrast ? Colors.black : Colors.green;
    final Color buttonTextColor = highContrast ? Colors.yellow.shade700 : Colors.white;

    return AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(w * 0.05),
        side: BorderSide(color: borderColor, width: highContrast ? 2 : 0),
      ),
      // Messaggio centrato con padding e larghezza limitata
      contentPadding: EdgeInsets.fromLTRB(
        w * 0.05, // left
        w * 0.04, // top
        w * 0.05, // right
        w * 0.025, // bottom
      ),
      content: TappableReader(
        label: titleText,
        child: Text(
          titleText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: (w * 0.05 * fontSizeFactor).clamp(16.0, 28.0),
            color: titleColor,
          ),
        ),
      ),
      // Centra i pulsanti sotto il testo
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pulsante Annulla
            TappableReader(
              label: cancelButtonText,
              child: ElevatedButton(
                onPressed: () {
                  if (access.talkbackEnabled) {
                    TalkbackService.announce(cancelButtonText);
                  }
                  onCancel();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cancelBg,
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.08,
                    vertical: h * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(w * 0.05)),
                ),
                child: Text(
                  cancelButtonText,
                  style: TextStyle(
                    color: buttonTextColor,
                    fontSize: (w * 0.045 * fontSizeFactor).clamp(14.0, 24.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Pulsante Conferma
            TappableReader(
              label: confirmButtonText,
              child: ElevatedButton(
                onPressed: () {
                  if (access.talkbackEnabled) {
                    TalkbackService.announce(confirmButtonText);
                  }
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmBg,
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.08,
                    vertical: h * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(w * 0.05)),
                ),
                child: Text(
                  confirmButtonText,
                  style: TextStyle(
                    color: buttonTextColor,
                    fontSize: (w * 0.045 * fontSizeFactor).clamp(14.0, 24.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}