import 'package:flutter/material.dart';
import 'package:code_g/app/widgets/CustomCard.dart';
import 'package:code_g/app/widgets/jsonDropDown.dart';
import 'package:code_g/app/widgets/text_input_widget.dart';
import '../controllers/create_project_controller.dart';

class ProjectOperationForm extends StatefulWidget {
  final CreateProjectController controller;
  final double inputWidth;
  final double inputHeight;
  final Map<String, dynamic>? operationData;
  final int? operationIndex;

  const ProjectOperationForm({
    Key? key,
    required this.controller,
    required this.inputWidth,
    required this.inputHeight,
    this.operationData,
    this.operationIndex,
  }) : super(key: key);

  @override
  State<ProjectOperationForm> createState() => _ProjectOperationFormState();
}

class _ProjectOperationFormState extends State<ProjectOperationForm> {
  late TextEditingController localOperationName;
  late TextEditingController localDisplayOperation;
  late TextEditingController localTopSolideOperation;
  late TextEditingController localArrosageType;

  // Flag to track if we're in initial building phase
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    localOperationName = TextEditingController();
    localDisplayOperation = TextEditingController();
    localTopSolideOperation = TextEditingController();
    localArrosageType = TextEditingController();

    // Initialize with data after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
        // Mark initialization complete
        _isInitializing = false;
      }
    });

    // Add listeners after initialization
    if (widget.operationIndex == 0) {
      widget.controller.displayOperation.addListener(_saveOperationData);
    } else {
      localDisplayOperation.addListener(_saveOperationData);
    }
  }

  @override
  void didUpdateWidget(ProjectOperationForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If operation index changed, reset form and reload data
    if (oldWidget.operationIndex != widget.operationIndex ||
        oldWidget.operationData != widget.operationData) {
      // Clear local controllers if this isn't the first operation
      if (widget.operationIndex != 0) {
        localTopSolideOperation.clear();
        localArrosageType.clear();
      }

      // Set initializing flag to prevent inadvertent updates
      _isInitializing = true;

      // Schedule loading for the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadData();
          // Mark initialization complete
          _isInitializing = false;
        }
      });
    }
  }

  void _loadData() {
    // Check if we have saved data for this operation index in selectedOperations
    if (widget.operationIndex != null &&
        widget.operationIndex! < widget.controller.selectedOperations.length &&
        widget
            .controller.selectedOperations[widget.operationIndex!].isNotEmpty) {
      // Load previously saved data
      Map<String, dynamic> savedData =
          widget.controller.selectedOperations[widget.operationIndex!];

      if (widget.operationIndex == 0) {
        // For the first operation, load data into main controller fields
        widget.controller.operationName.text = savedData['operation'] ?? "";
        widget.controller.displayOperation.text =
            savedData['displayOperation'] ?? "";
        widget.controller.topSolideOperation.text =
            savedData['topSolideOperation'] ?? "";
        widget.controller.arrosageType.text = savedData['arrosageType'] ?? "";
      } else {
        // For other operations, load data into local controllers
        localOperationName.text = savedData['operation'] ?? "";
        localDisplayOperation.text = savedData['displayOperation'] ?? "";

        // Only load these fields if there's saved data, otherwise keep them empty
        if (savedData['topSolideOperation'] != null &&
            savedData['topSolideOperation'] != "") {
          localTopSolideOperation.text = savedData['topSolideOperation'] ?? "";
        }

        if (savedData['arrosageType'] != null &&
            savedData['arrosageType'] != "") {
          localArrosageType.text = savedData['arrosageType'] ?? "";
        }
      }
    }
    // If no saved data but we have operation data (from fileZJsonData)
    else if (widget.operationData != null) {
      localOperationName.text = widget.operationData!["operation"] ?? "";
      localDisplayOperation.text = widget.operationData!["description"] ?? "";

      // Only use controller's values if this is the first operation
      if (widget.operationIndex == 0) {
        widget.controller.operationName.text = localOperationName.text;
        widget.controller.displayOperation.text = localDisplayOperation.text;
      }

      // Keep operation type and arrosage fields empty for new operations
      if (widget.operationIndex != 0) {
        localTopSolideOperation.clear();
        localArrosageType.clear();
      }
    }

    // Save the initial values to the controller safely
    if (widget.operationIndex != null) {
      // Only save if not already populated
      if (!(widget.controller.selectedOperations.length >
              widget.operationIndex! &&
          widget.controller.selectedOperations[widget.operationIndex!]
              .isNotEmpty)) {
        // Use the silent version during initialization to avoid setState during build
        if (widget.operationIndex != null && mounted) {
          widget.controller.addOrUpdateOperationSilently(
            widget.operationIndex!,
            widget.operationIndex == 0
                ? widget.controller.operationName.text
                : localOperationName.text,
            widget.operationIndex == 0
                ? widget.controller.displayOperation.text
                : localDisplayOperation.text,
            widget.operationIndex == 0
                ? widget.controller.topSolideOperation.text
                : localTopSolideOperation.text,
            widget.operationIndex == 0
                ? widget.controller.arrosageType.text
                : localArrosageType.text,
          );
        }
      }
    }
  }

  void _saveOperationData() {
    // Don't update during initialization
    if (!_isInitializing && widget.operationIndex != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.controller.addOrUpdateOperation(
            widget.operationIndex!,
            widget.operationIndex == 0
                ? widget.controller.operationName.text
                : localOperationName.text,
            widget.operationIndex == 0
                ? widget.controller.displayOperation.text
                : localDisplayOperation.text,
            widget.operationIndex == 0
                ? widget.controller.topSolideOperation.text
                : localTopSolideOperation.text,
            widget.operationIndex == 0
                ? widget.controller.arrosageType.text
                : localArrosageType.text,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    // Remove listeners before disposing
    if (widget.operationIndex != 0) {
      localOperationName.dispose();
      localDisplayOperation.removeListener(_saveOperationData);
      localDisplayOperation.dispose();
      localTopSolideOperation.dispose();
      localArrosageType.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      enableScroll: false, // Disable scrolling for this card specifically
      children: [
        Row(
          children: [
            JsonDropDown(
              onChanged: (value) {
                if (widget.operationIndex == 0) {
                  // For first operation, always clear fields first
                  widget.controller.topSolideOperation.clear();
                  widget.controller.arrosageType.clear();

                  // Call controller's update method to handle display operation and check for saved data
                  widget.controller.updateDisplayOperation(value);
                } else {
                  // For non-first operations, start with cleared fields
                  localDisplayOperation.text = "";
                  localTopSolideOperation.clear();
                  localArrosageType.clear();

                  // Try to find the operation in fileZJsonData for description
                  if (widget.controller.fileZJsonData.isNotEmpty) {
                    final data = widget.controller.fileZJsonData
                        .where((element) => element["operation"] == value)
                        .toList();

                    if (data.isNotEmpty && data[0].containsKey("description")) {
                      localDisplayOperation.text = data[0]["description"];
                    }
                  }

                  // Check if this operation already has saved data
                  bool foundSavedData = false;
                  for (var op in widget.controller.selectedOperations) {
                    if (op['operation'] == value) {
                      foundSavedData = true;

                      // Load saved data for this operation
                      localDisplayOperation.text =
                          op['displayOperation'] ?? localDisplayOperation.text;

                      // Only load these if they exist in saved data
                      if (op['topSolideOperation'] != null &&
                          op['topSolideOperation'].toString().isNotEmpty) {
                        localTopSolideOperation.text = op['topSolideOperation'];
                      }

                      if (op['arrosageType'] != null &&
                          op['arrosageType'].toString().isNotEmpty) {
                        localArrosageType.text = op['arrosageType'];
                      }

                      // Display a message that saved data was loaded
                      if (op['topSolideOperation'] != null ||
                          op['arrosageType'] != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Saved data loaded for operation: $value'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ));
                      }
                      break;
                    }
                  }

                  // If no saved data was found, show a message
                  if (!foundSavedData) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'No saved data for this operation. Please fill in the details.'),
                      backgroundColor: Colors.blue,
                      duration: Duration(seconds: 2),
                    ));
                  }
                }

                _saveOperationData();
              },
              label: "Saisir une opération *",
              hint: "Sélectionner une opération",
              controller: widget.operationIndex == 0
                  ? widget.controller.operationName
                  : localOperationName,
              future: widget.controller.extractOperationsData(),
              keyExtractor: (item) => item,
              width: widget.inputWidth - 10,
              height: widget.inputHeight,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    JsonDropDown(
                      label: "Ajouter un type pour l'operation *",
                      hint:
                          "Choisir une opération puis Sélectionner un type de la liste TopSolid",
                      controller: widget.operationIndex == 0
                          ? widget.controller.topSolideOperation
                          : localTopSolideOperation,
                      future: widget.controller
                          .extractTopSolideOperationsJsonData(),
                      keyExtractor: (item) => item["name"],
                      width: widget.inputWidth - 10,
                      height: widget.inputHeight,
                      showReset: true,
                      fieldName: 'topSolideOperation',
                      onReset: () {
                        if (widget.operationIndex == 0) {
                          widget.controller.handleReset('topSolideOperation');
                        } else {
                          localTopSolideOperation.clear();
                        }
                        _saveOperationData();
                      },
                      onChanged: (value) {
                        _saveOperationData();
                      },
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      (widget.operationIndex == 0
                                  ? widget.controller.topSolideOperation.text
                                  : localTopSolideOperation.text)
                              .isNotEmpty
                          ? Icons.check_circle
                          : Icons.pending,
                      color: (widget.operationIndex == 0
                                  ? widget.controller.topSolideOperation.text
                                  : localTopSolideOperation.text)
                              .isNotEmpty
                          ? Colors.green
                          : Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            CustomTextInput(
              width: widget.inputWidth - 10,
              height: widget.inputHeight,
              label: '',
              hint: 'Choisir une opération pour l\'Affichage de l\'Outil',
              controller: widget.operationIndex == 0
                  ? widget.controller.displayOperation
                  : localDisplayOperation,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    JsonDropDown(
                      label: "Ajouter l\'arrosage *",
                      hint:
                          "Choisir une opération puis Sélectionner un arrosage pour l\'outil",
                      controller: widget.operationIndex == 0
                          ? widget.controller.arrosageType
                          : localArrosageType,
                      future: widget.controller.extractArrosageTypesJsonData(),
                      keyExtractor: (item) => item["name"],
                      width: widget.inputWidth - 10,
                      height: widget.inputHeight,
                      showReset: true,
                      fieldName: 'arrosageType',
                      onReset: () {
                        if (widget.operationIndex == 0) {
                          widget.controller.handleReset('arrosageType');
                        } else {
                          localArrosageType.clear();
                        }
                        _saveOperationData();
                      },
                      onChanged: (value) {
                        _saveOperationData();
                      },
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      (widget.operationIndex == 0
                                  ? widget.controller.arrosageType.text
                                  : localArrosageType.text)
                              .isNotEmpty
                          ? Icons.check_circle
                          : Icons.pending,
                      color: (widget.operationIndex == 0
                                  ? widget.controller.arrosageType.text
                                  : localArrosageType.text)
                              .isNotEmpty
                          ? Colors.green
                          : Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
