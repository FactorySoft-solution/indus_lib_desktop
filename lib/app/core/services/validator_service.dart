import 'package:flutter/material.dart';

class ValidatorService {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName must be a number';
    }
    return null;
  }

  static String? validateMinLength(
      String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  static String? validateMaxLength(
      String? value, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  static String? validateURL(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  static String? validateImageFile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Image file is required';
    }
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final extension = value.toLowerCase().substring(value.lastIndexOf('.'));
    if (!imageExtensions.contains(extension)) {
      return 'Please select a valid image file (jpg, jpeg, png, gif, bmp, webp)';
    }
    return null;
  }

  static String? validateDocumentFile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Document file is required';
    }
    final documentExtensions = ['.pdf', '.doc', '.docx', '.txt', '.rtf'];
    final extension = value.toLowerCase().substring(value.lastIndexOf('.'));
    if (!documentExtensions.contains(extension)) {
      return 'Please select a valid document file (pdf, doc, docx, txt, rtf)';
    }
    return null;
  }

  static String? validateVideoFile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Video file is required';
    }
    final videoExtensions = ['.mp4', '.avi', '.mov', '.wmv', '.flv', '.mkv'];
    final extension = value.toLowerCase().substring(value.lastIndexOf('.'));
    if (!videoExtensions.contains(extension)) {
      return 'Please select a valid video file (mp4, avi, mov, wmv, flv, mkv)';
    }
    return null;
  }

  static String? validateAudioFile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Audio file is required';
    }
    final audioExtensions = ['.mp3', '.wav', '.ogg', '.m4a', '.aac', '.wma'];
    final extension = value.toLowerCase().substring(value.lastIndexOf('.'));
    if (!audioExtensions.contains(extension)) {
      return 'Please select a valid audio file (mp3, wav, ogg, m4a, aac, wma)';
    }
    return null;
  }

  static String? validateFileSize(String? value, int maxSizeInMB) {
    if (value == null || value.isEmpty) {
      return 'File is required';
    }
    try {
      final fileSize = int.parse(value);
      if (fileSize > maxSizeInMB * 1024 * 1024) {
        return 'File size must not exceed $maxSizeInMB MB';
      }
      return null;
    } catch (e) {
      return 'Invalid file size';
    }
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username must be 3-20 characters and can only contain letters, numbers, and underscores';
    }
    return null;
  }

  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }
    final postalCodeRegex = RegExp(r'^\d{5}(-\d{4})?$');
    if (!postalCodeRegex.hasMatch(value)) {
      return 'Please enter a valid postal code';
    }
    return null;
  }

  static String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Credit card number is required';
    }
    // Remove spaces and dashes
    final cleanValue = value.replaceAll(RegExp(r'[\s-]'), '');
    if (!RegExp(r'^\d{16}$').hasMatch(cleanValue)) {
      return 'Please enter a valid 16-digit credit card number';
    }
    return null;
  }

  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }
    final expiryRegex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
    if (!expiryRegex.hasMatch(value)) {
      return 'Please enter a valid expiry date (MM/YY)';
    }
    return null;
  }

  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }
    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'Please enter a valid CVV (3 or 4 digits)';
    }
    return null;
  }

  static String? validateHexColor(String? value) {
    if (value == null || value.isEmpty) {
      return 'Color code is required';
    }
    final hexRegex = RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');
    if (!hexRegex.hasMatch(value)) {
      return 'Please enter a valid hex color code';
    }
    return null;
  }

  static String? validateIPAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'IP address is required';
    }
    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    if (!ipRegex.hasMatch(value)) {
      return 'Please enter a valid IP address';
    }
    return null;
  }
}
