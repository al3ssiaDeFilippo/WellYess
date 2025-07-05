import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wellyess/models/accessibilita_model.dart';
import 'package:wellyess/widgets/tappable_reader.dart';
import 'package:wellyess/services/flutter_tts.dart';

class PopUpConferma extends StatelessWidget {
  final String message;
  final VoidCallback? onConfirm;

  const PopUpConferma({
    Key? key,
    required this.message,
    this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final access = context.watch<AccessibilitaModel>();
    final fontSizeFactor = access.fontSizeFactor;
    final highContrast = access.highContrast;

    final Color bgColor = highContrast ? Colors.black : Colors.white;
    final Color borderColor = highContrast ? Colors.yellow : Colors.transparent;
    final Color textColor = highContrast ? Colors.yellow : Colors.black87;
    final Color buttonBg = highContrast ? Colors.black : Colors.redAccent;
    final Color iconColor = highContrast ? Colors.yellow : Colors.white;

    return AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: borderColor, width: highContrast ? 3 : 0),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: TappableReader(
        label: message,
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: (18 * fontSizeFactor).clamp(15.0, 24.0),
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TappableReader(
          label: 'Chiudi conferma',
          child: ElevatedButton(
            onPressed: () {
              TalkbackService.announce(message);
              Navigator.of(context).pop();
              if (onConfirm != null) onConfirm!();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonBg,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
              elevation: 6,
              side: highContrast
                  ? const BorderSide(color: Colors.yellow, width: 2)
                  : BorderSide.none,
            ),
            child: Icon(Icons.close, color: iconColor, size: 28),
          ),
        ),
      ],
    );
  }
}