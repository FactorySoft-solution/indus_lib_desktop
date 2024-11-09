import 'package:code_g/app/modules/home/bindings/home_binding.dart';
import 'package:code_g/app/modules/home/views/home_view.dart';
import 'package:code_g/app/modules/create_project/views/create_project_view.dart';
import 'package:code_g/app/modules/create_project/bindings/create_project_binding.dart';
import 'package:code_g/app/views/spalsh_screen/auth_page.dart';
import 'package:code_g/app/views/spalsh_screen/splash_screen.dart';
import 'package:get/get.dart';
// import 'package:code_g/app/modules/profile/profile_binding.dart';
// import 'package:code_g/app/modules/profile/profile_view.dart';
// import 'package:code_g/app/modules/settings/settings_binding.dart';
// import 'package:code_g/app/modules/settings/settings_view.dart';
// import 'package:code_g/app/modules/settings_detail/settings_detail_binding.dart';
// import 'package:code_g/app/modules/settings_detail/settings_detail_view.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashScreen(),
      // children: [],
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthPage(),
      // children: [],
    ),
    GetPage(
      name: _Paths.CREATEPROJECT,
      page: () => CreateProjectView(),
      binding: CreateProjectBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    // GetPage(
    //   name: _Paths.CREATEPROJECT,
    //   page: () => CreateProjectView(),
    //   binding: CreateProjectBinding(),
    // )
  ];
}
