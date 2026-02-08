import 'package:asset_flow/Core/Model/auth_token_store.dart';
import 'package:asset_flow/Core/Network/network.dart';
import 'package:asset_flow/Core/utils/Routes/routes.dart';
import 'package:asset_flow/Core/utils/Routes/routes_name.dart';
import 'package:asset_flow/repository/asset_repository.dart';
import 'package:asset_flow/repository/auth_repository.dart';
import 'package:asset_flow/repository/damage_repository.dart';
import 'package:asset_flow/repository/dashboard_repository.dart';
import 'package:asset_flow/repository/employee_repository.dart';
import 'package:asset_flow/repository/profile_repository.dart';
import 'package:asset_flow/repository/reports_repository.dart';
import 'package:asset_flow/repository/store_repository.dart';
import 'package:asset_flow/viewModel/assets_screen_view_model.dart';
import 'package:asset_flow/viewModel/damaged_assets_screen_view_model.dart';
import 'package:asset_flow/viewModel/dashboard_view_model.dart';
import 'package:asset_flow/viewModel/employee_screen_view_model.dart';
import 'package:asset_flow/viewModel/asset_reports_screen_view_model.dart';
import 'package:asset_flow/viewModel/login_screen_view_model.dart';
import 'package:asset_flow/viewModel/profile_management_screen_view_model.dart';
import 'package:asset_flow/viewModel/repair_management_screen_view_model.dart';
import 'package:asset_flow/viewModel/store_inventory_screen_view_model.dart';
import 'package:asset_flow/viewModel/signup_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final tokenStore = AuthTokenStore();
  late final AuthRepository authRepo;

  /// API client for protected endpoints. Uses stored access token and refreshes on 401.
  final apiWithAuth = BaseApiService(
    tokenGetter: () => tokenStore.accessToken,
    on401Refresh: () async {
      final r = tokenStore.refreshToken;
      if (r == null || r.isEmpty) return null;
      final res = await authRepo.refresh(r);
      if (res.success && res.data != null) {
        tokenStore.setTokens(res.data!.accessToken, res.data!.refreshToken);
        return res.data!.accessToken;
      }
      return null;
    },
  );

  authRepo = AuthRepository(authApi: apiWithAuth);
  final dashboardRepo = DashboardRepository(api: apiWithAuth);
  final employeeRepo = EmployeeRepository(api: apiWithAuth);
  final assetRepo = AssetRepository(api: apiWithAuth);
  final storeRepo = StoreRepository(api: apiWithAuth);
  final damageRepo = DamageRepository(api: apiWithAuth);
  final reportsRepo = ReportsRepository(api: apiWithAuth);
  final profileRepo = ProfileRepository(api: apiWithAuth);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthTokenStore>.value(value: tokenStore),
        Provider<BaseApiService>.value(value: apiWithAuth),
        Provider<AuthRepository>.value(value: authRepo),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(repository: dashboardRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => EmployeeScreenViewModel(repository: employeeRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => AssetsScreenViewModel(repository: assetRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => StoreInventoryScreenViewModel(repository: storeRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => DamagedAssetsScreenViewModel(repository: damageRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => RepairManagementScreenViewModel(repository: damageRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => AssetReportsScreenViewModel(repository: reportsRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileManagementScreenViewModel(repository: profileRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => LoginScreenViewModel(
            repository: authRepo,
            tokenStore: tokenStore,
          ),
        ),
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
