import 'package:asset_flow/Core/utils/Routes/routes.dart';
import 'package:asset_flow/Core/utils/Routes/routes_name.dart';
import 'package:asset_flow/viewModel/login_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginScreenViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: RoutesName.loginScreen,
        onGenerateRoute: Routes.generateRoute,
      ),
    ),
  );
}
