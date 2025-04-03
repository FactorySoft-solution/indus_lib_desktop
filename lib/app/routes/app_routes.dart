part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const AUTH = _Paths.AUTH;
  static const LOGIN = _Paths.LOGIN;
  static const HOME = _Paths.HOME;
  static const MAIN = _Paths.MAIN;
  static const CREATEPROJECT = _Paths.MAIN + _Paths.CREATEPROJECT;
  static const SEARCHPIECE = _Paths.MAIN + _Paths.SEARCHPIECE;
  static const ROBERTMETHOD = _Paths.MAIN + _Paths.ROBERTMETHOD;
  static const PdfToHtmlConverter = _Paths.PdfToHtmlConverter;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const MAIN = '/main';
  static const CREATEPROJECT = '/createproject';
  static const SEARCHPIECE = '/searchpiece';
  static const ROBERTMETHOD = '/robertmethod';
  static const PdfToHtmlConverter = '/main/PdfToHtmlConverter';
  static const AUTH = '/auth';
}
