import 'package:flutter/material.dart';
import '../../utils/responsive.dart';
import 'widgets/desktop_home_view.dart';
import 'widgets/mobile_home_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive.build(
        context,
        mobile: const MobileHomeView(),
        tablet: const DesktopHomeView(),
        desktop: const DesktopHomeView(),
      ),
    );
  }
}
