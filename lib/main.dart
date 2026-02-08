import 'package:asset_flow/Core/utils/Routes/routes.dart';
import 'package:asset_flow/Core/utils/Routes/routes_name.dart';
import 'package:asset_flow/repository/auth_repository.dart';
import 'package:asset_flow/viewModel/login_screen_view_model.dart';
import 'package:asset_flow/viewModel/signup_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final authRepo = AuthRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginScreenViewModel()),
        ChangeNotifierProvider(
          create: (_) => SignupScreenViewModel(repository: authRepo),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: RoutesName.loginScreen,
        onGenerateRoute: Routes.generateRoute,
      ),
    ),
  );
}
