import 'package:code_g/app/modules/home/views/main.dart';
import 'package:code_g/app/modules/search_piece/bindings/search_piece_binding.dart';
import 'package:code_g/app/modules/search_piece/views/search_view.dart';
import 'package:code_g/app/modules/robert_method/bindings/robert_method_binding.dart';
import 'package:code_g/app/modules/robert_method/views/robert_method_view.dart';
import 'package:code_g/app/widgets/pdf_to_html_converter.dart';
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

class AppPages {
  static const initial = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
        name: _Paths.MAIN,
        page: () => MainView(),
        binding: HomeBinding(),
        transition: Transition.fadeIn,
        children: [
          GetPage(
            name: _Paths.CREATEPROJECT,
            page: () => CreateProjectView(),
            binding: CreateProjectBinding(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: _Paths.SEARCHPIECE,
            page: () => SearchView(),
            binding: SearchPieceBinding(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: _Paths.ROBERTMETHOD,
            page: () => const RobertMethodView(),
            binding: RobertMethodBinding(),
            transition: Transition.fadeIn,
          ),
        ]),
    GetPage(
      name: _Paths.LOGIN,
      page: () => AuthView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
