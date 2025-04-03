import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:code_g/app/core/services/calculator_service.dart';

class ThreadData {
  final double D1;
  final double D3;
  final double P;
  final double reductionFactor;

  ThreadData({
    required this.D1,
    required this.D3,
    required this.P,
    required this.reductionFactor,
  });

  factory ThreadData.fromJson(Map<String, dynamic> json) {
    return ThreadData(
      D1: json['D1']?.toDouble() ?? 0.0,
      D3: json['D3']?.toDouble() ?? 0.0,
      P: json['P']?.toDouble() ?? 0.0,
      reductionFactor: json['reductionFactor']?.toDouble() ?? 0.0,
    );
  }
}

class RobertMethodController extends GetxController {
  final calculatorService = CalculatorService();

  final formKey = GlobalKey<FormState>();
  final diameterController = TextEditingController();
  final pitchController = TextEditingController();

  final results = Rxn<Map<String, dynamic>>();
  final showResults = false.obs;
  final showEquation = false.obs;

  final threadTypeController = TextEditingController();
  final threadDesignationController = TextEditingController();

  final selectedThreadType = ''.obs;
  final selectedThreadDesignation = ''.obs;
  final threadDesignations = <String>[''].obs;
  final threadData = Rx<ThreadData?>(null);
  final hasResults = false.obs;

  Map<String, dynamic> threadTypeData = {};

  @override
  void onInit() {
    super.onInit();
    loadThreadData();
  }

  @override
  void onClose() {
    diameterController.dispose();
    pitchController.dispose();
    threadTypeController.dispose();
    threadDesignationController.dispose();
    super.onClose();
  }

  Future<void> loadThreadData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/json/filetageTable.json');
      final Map<String, dynamic> data = await json.decode(response);
      threadTypeData = data['threadType'] ?? {};
      update(); // Notify UI to rebuild after data is loaded
    } catch (e) {
      print('Error loading thread data: $e');
    }
  }

  void updateThreadType(String type) {
    selectedThreadType.value = type;
    selectedThreadDesignation.value = '';
    threadDesignationController.text = '';
    threadData.value = null;
    hasResults.value = false;

    // Update available designations based on selected type
    if (type == 'Métrique') {
      threadDesignations.value = threadTypeData.keys.toList();
    } else {
      threadDesignations.value = [];
    }
    update(); // Notify UI to rebuild
  }

  void updateThreadDesignation(String designation) {
    selectedThreadDesignation.value = designation;

    // Get thread data for selected designation
    if (threadTypeData.containsKey(designation)) {
      final data = threadTypeData[designation];
      threadData.value = ThreadData.fromJson(data);
      hasResults.value = true;
    } else {
      threadData.value = null;
      hasResults.value = false;
    }
    update(); // Notify UI to rebuild
  }

  void importPdfProcedure() {
    // Implement PDF import functionality
    Get.snackbar(
      'Import PDF',
      'Cette fonctionnalité sera implémentée ultérieurement',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void displayPdfProcedure() {
    // Implement PDF display functionality
    Get.snackbar(
      'Afficher PDF',
      'Cette fonctionnalité sera implémentée ultérieurement',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void calculate() {
    if (formKey.currentState!.validate()) {
      final nominalDiameter = double.parse(diameterController.text);
      final threadPitch = double.parse(pitchController.text);

      results.value =
          calculatorService.calculateThreading(nominalDiameter, threadPitch);
      showResults.value = true;
      showEquation.value = true;
    }
  }

  void reset() {
    formKey.currentState?.reset();
    diameterController.clear();
    pitchController.clear();
    results.value = null;
    showResults.value = false;
    showEquation.value = false;
  }

  String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
}
