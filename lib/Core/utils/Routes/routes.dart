import 'package:asset_flow/Core/Constants/app_colors.dart';
import 'package:asset_flow/Core/Constants/size_extension.dart';
import 'package:asset_flow/Core/utils/Routes/routes_name.dart';
import 'package:asset_flow/view/Auth/login_screen.dart';
import 'package:asset_flow/view/Auth/signup_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.loginScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => LoginScreen(),
        );
      case RoutesName.signUpScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SignUpScreen(),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => Scaffold(
            body: Stack(
              children: [
                Center(
                  child: Text(
                    'No Route Found',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.headingColor,
                      fontSize: context.text(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: context.h(50),
                  left: context.w(20),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.headingColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}
