class ProjectModel {
  final String pieceRef;
  final String pieceIndice;
  final String? pieceName;
  final String? machine;
  final String? pieceDiametre;
  final String? form;
  final String? epaisseur;
  final String? operationName;
  final String? topSolideOperation;
  final String? materiel;
  final String? specification;
  final List<String>? selectedItems;
  final String? createdDate;
  final String? projectPath;
  final String? copiedFolderPath;
  final List<Map<String, dynamic>>? operations;

  ProjectModel({
    required this.pieceRef,
    required this.pieceIndice,
    this.pieceName,
    this.machine,
    this.pieceDiametre,
    this.form,
    this.epaisseur,
    this.operationName,
    this.topSolideOperation,
    this.materiel,
    this.specification,
    this.selectedItems,
    this.createdDate,
    this.projectPath,
    this.copiedFolderPath,
    this.operations,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      pieceRef: json['pieceRef'] as String,
      pieceIndice: json['pieceIndice'] as String,
      pieceName: json['pieceName'] as String?,
      machine: json['machine'] as String?,
      pieceDiametre: json['pieceDiametre'] as String?,
      form: json['form'] as String?,
      epaisseur: json['epaisseur'] as String?,
      operationName: json['operationName'] as String?,
      topSolideOperation: json['topSolideOperation'] as String?,
      materiel: json['materiel'] as String?,
      specification: json['specification'] as String?,
      selectedItems: (json['selectedItems'] as List<dynamic>?)?.cast<String>(),
      createdDate: json['createdDate'] as String?,
      projectPath: json['projectPath'] as String?,
      copiedFolderPath: json['copiedFolderPath'] as String?,
      operations: (json['operations'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pieceRef': pieceRef,
      'pieceIndice': pieceIndice,
      'pieceName': pieceName,
      'machine': machine,
      'pieceDiametre': pieceDiametre,
      'form': form,
      'epaisseur': epaisseur,
      'operationName': operationName,
      'topSolideOperation': topSolideOperation,
      'materiel': materiel,
      'specification': specification,
      'selectedItems': selectedItems,
      'createdDate': createdDate,
      'projectPath': projectPath,
      'copiedFolderPath': copiedFolderPath,
      'operations': operations,
    };
  }

  ProjectModel copyWith({
    String? pieceRef,
    String? pieceIndice,
    String? pieceName,
    String? machine,
    String? pieceDiametre,
    String? form,
    String? epaisseur,
    String? operationName,
    String? topSolideOperation,
    String? materiel,
    String? specification,
    List<String>? selectedItems,
    String? createdDate,
    String? projectPath,
    String? copiedFolderPath,
    List<Map<String, dynamic>>? operations,
  }) {
    return ProjectModel(
      pieceRef: pieceRef ?? this.pieceRef,
      pieceIndice: pieceIndice ?? this.pieceIndice,
      pieceName: pieceName ?? this.pieceName,
      machine: machine ?? this.machine,
      pieceDiametre: pieceDiametre ?? this.pieceDiametre,
      form: form ?? this.form,
      epaisseur: epaisseur ?? this.epaisseur,
      operationName: operationName ?? this.operationName,
      topSolideOperation: topSolideOperation ?? this.topSolideOperation,
      materiel: materiel ?? this.materiel,
      specification: specification ?? this.specification,
      selectedItems: selectedItems ?? this.selectedItems,
      createdDate: createdDate ?? this.createdDate,
      projectPath: projectPath ?? this.projectPath,
      copiedFolderPath: copiedFolderPath ?? this.copiedFolderPath,
      operations: operations ?? this.operations,
    );
  }
}
