import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_button.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_button_round.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/contra_text.dart';
import 'package:vibe_coding_tutorial_weather_app/custom_widgets/circle_dot_widget.dart';
import 'package:vibe_coding_tutorial_weather_app/features/saved_appointments/presentation/pages/saved_appointments_page.dart';
import 'package:vibe_coding_tutorial_weather_app/utils/colors.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: white,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Center(
                child: Container(
                  width: 290,
                  height: 290,
                  decoration: const BoxDecoration(
                    color: lightening_yellow,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    "assets/images/peep_lady_one.svg",
                  ),
                ),
              ),
            ),
            const Expanded(
              flex: 4,
              child: OnboardingPageText(
                title: "Controla tu salud",
                description:
                    "Una forma sencilla de gestionar tu salud.",
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: ContraButtonRound(
                  borderColor: black,
                  shadowColor: black,
                  color: lightening_yellow,
                  iconPath: "assets/icons/arrow_forward.svg",
                  callback: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavedAppointmentsPage(),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OnboardingPageText extends StatelessWidget {
  final String title;
  final String description;

  const OnboardingPageText({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 40),
          ContraText(
            alignment: Alignment.centerLeft,
            text: title,
            size: 44,
          ),
          const SizedBox(
            height: 21,
          ),
          ContraText(
            alignment: Alignment.centerLeft,
            text: description,
            size: 24,
            color: trout,
            weight: FontWeight.w500,
          )
        ],
      ),
    );
  }
}
