class AppConstants {
  // API Constants
  static const String apiBaseUrl = 'YOUR_API_BASE_URL';

  // File System Constants
  static const String projectBaseFolder = 'aerobase';
  static const List<String> projectSubfolders = [
    'copied_folder',
    'Fiche Zoller',
    'Programme',
    'Dessin',
    'Photo'
  ];

  // File Types
  static const List<String> supportedFileTypes = [
    '.pdf',
    '.dwg',
    '.dxf',
    '.step',
    '.stp',
    '.nc',
    '.tap'
  ];

  // Search Constants
  static const int maxSearchResults = 100;
  static const int searchDebounceTime = 300; // milliseconds

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultIconSize = 24.0;

  // Animation Constants
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Error Messages
  static const String errorFileNotFound = 'File not found';
  static const String errorDirectoryNotFound = 'Directory not found';
  static const String errorInvalidPath = 'Invalid path';
  static const String errorPermissionDenied = 'Permission denied';

  // Success Messages
  static const String successFileCopied = 'File copied successfully';
  static const String successFileDeleted = 'File deleted successfully';
  static const String successFolderCreated = 'Folder created successfully';
}
