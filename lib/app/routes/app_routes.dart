part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const AUTH = _Paths.AUTH;
  static const LOGIN = _Paths.LOGIN;
  static const HOME = _Paths.HOME;
  static const CREATEPROJECT = _Paths.CREATEPROJECT;
  // static const SETTINGS = _Paths.SETTINGS;
  // static const SETTINGS_DETAIL = _Paths.SETTINGS_DETAIL;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/SplachScreen';
  static const AUTH = '/AuthPage';
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const CREATEPROJECT = '/CreateProject';
}
