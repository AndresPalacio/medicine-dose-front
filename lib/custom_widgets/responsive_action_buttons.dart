import 'package:flutter/material.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class ResponsiveActionButtons extends StatelessWidget {
  final VoidCallback onCitasPressed;
  final VoidCallback onCalendarioPressed;
  final VoidCallback onCambiarMesPressed;
  final VoidCallback? onSintomasPressed;

  const ResponsiveActionButtons({
    Key? key,
    required this.onCitasPressed,
    required this.onCalendarioPressed,
    required this.onCambiarMesPressed,
    this.onSintomasPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Ajustado para iPhone 11 (414px) y otros móviles comunes
    final isSmallScreen = screenWidth <= 430; // Incluye iPhone 11, 12, 13, etc.
    final isMediumScreen = screenWidth <= 600;

    if (isSmallScreen) {
      // Para pantallas muy pequeñas: diseño vertical
      return Column(
        children: [
          _buildButtonRow(
            context,
            [
              _buildResponsiveButton(
                context,
                'Citas médicas',
                moody_blue,
                moody_blue,
                white,
                onCitasPressed,
                isSmallScreen: true,
              ),
              const SizedBox(width: 8),
              _buildResponsiveButton(
                context,
                'Calendario',
                carribean_green,
                carribean_green,
                white,
                onCalendarioPressed,
                isSmallScreen: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildButtonRow(
            context,
            [
              if (onSintomasPressed != null) ...[
                _buildResponsiveButton(
                  context,
                  'Síntomas',
                  Colors.orange,
                  Colors.orange,
                  white,
                  onSintomasPressed!,
                  isSmallScreen: true,
                ),
                const SizedBox(width: 8),
              ],
              _buildResponsiveButton(
                context,
                'Cambiar mes',
                white,
                wood_smoke,
                wood_smoke,
                onCambiarMesPressed,
                isSmallScreen: true,
              ),
            ],
          ),
        ],
      );
    } else if (isMediumScreen) {
      // Para pantallas medianas: botones más pequeños pero en fila
      return Wrap(
        spacing: 6,
        runSpacing: 8,
        children: [
          _buildResponsiveButton(
            context,
            'Citas',
            moody_blue,
            moody_blue,
            white,
            onCitasPressed,
            isCompact: true,
          ),
          _buildResponsiveButton(
            context,
            'Calendario',
            carribean_green,
            carribean_green,
            white,
            onCalendarioPressed,
            isCompact: true,
          ),
          if (onSintomasPressed != null)
            _buildResponsiveButton(
              context,
              'Síntomas',
              Colors.orange,
              Colors.orange,
              white,
              onSintomasPressed!,
              isCompact: true,
            ),
          _buildResponsiveButton(
            context,
            'Cambiar mes',
            white,
            wood_smoke,
            wood_smoke,
            onCambiarMesPressed,
            isCompact: true,
          ),
        ],
      );
    } else {
      // Para pantallas grandes: diseño original
      return Row(
        children: [
          Expanded(
            child: _buildResponsiveButton(
              context,
              'Citas médicas',
              moody_blue,
              moody_blue,
              white,
              onCitasPressed,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildResponsiveButton(
              context,
              'Calendario',
              carribean_green,
              carribean_green,
              white,
              onCalendarioPressed,
            ),
          ),
          if (onSintomasPressed != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: _buildResponsiveButton(
                context,
                'Síntomas',
                Colors.orange,
                Colors.orange,
                white,
                onSintomasPressed!,
              ),
            ),
          ],
          const SizedBox(width: 8),
          Expanded(
            child: _buildResponsiveButton(
              context,
              'Cambiar mes',
              white,
              wood_smoke,
              wood_smoke,
              onCambiarMesPressed,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildButtonRow(BuildContext context, List<Widget> children) {
    return Row(
      children: children,
    );
  }

  Widget _buildResponsiveButton(
    BuildContext context,
    String text,
    Color color,
    Color borderColor,
    Color textColor,
    VoidCallback onPressed, {
    bool isSmallScreen = false,
    bool isCompact = false,
    bool isFullWidth = false,
  }) {
    double? buttonWidth;
    double fontSize = 12;
    double buttonHeight = 48;

    if (isFullWidth) {
      buttonWidth = double.infinity;
      fontSize = 14;
      buttonHeight = 50;
    } else if (isSmallScreen) {
      buttonWidth = (MediaQuery.of(context).size.width - 40) / 2 - 4;
      fontSize = 11;
      buttonHeight = 46;
    } else if (isCompact) {
      buttonWidth = (MediaQuery.of(context).size.width - 48) / 3 - 4;
      fontSize = 10;
      buttonHeight = 44;
    }

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: borderColor, width: 1.5),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 8 : 12,
            vertical: 8,
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
