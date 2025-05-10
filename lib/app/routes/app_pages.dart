import 'package:code_g/app/modules/home/views/main.dart';
import 'package:code_g/app/modules/robert_method/bindings/robert_method_binding.dart';
import 'package:code_g/app/modules/robert_method/views/robert_method_view.dart';
import 'package:code_g/app/modules/search_piece/bindings/search_piece_binding.dart';
import 'package:code_g/app/modules/search_piece/views/search_view.dart';
import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_page.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/auth/views/splash_screen.dart';
import '../modules/create_project/bindings/create_project_binding.dart';
import '../modules/create_project/views/create_project_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

part 'app_routes.dart';

abstract class Routes {
  static const SPLASH = '/splash';
  static const AUTH = '/auth';
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const MAIN = '/main';
  static const CREATEPROJECT = '/create-project';
  static const SEARCHPIECE = '/search-piece';
  static const ROBERTMETHOD = '/robert-method';
}

class AppPages {
  static const initial = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.AUTH,
      page: () => const AuthPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
        name: Routes.MAIN,
        page: () => MainView(),
        binding: HomeBinding(),
        transition: Transition.fadeIn,
        children: [
          GetPage(
            name: Routes.CREATEPROJECT,
            page: () => CreateProjectView(),
            binding: CreateProjectBinding(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: Routes.SEARCHPIECE,
            page: () => SearchView(),
            binding: SearchPieceBinding(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: Routes.ROBERTMETHOD,
            page: () => const RobertMethodView(),
            binding: RobertMethodBinding(),
            transition: Transition.fadeIn,
          ),
        ]),
    GetPage(
      name: Routes.LOGIN,
      page: () => AuthView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
