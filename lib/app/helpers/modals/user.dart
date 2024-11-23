import 'package:code_g/app/helpers/enums.dart';

class UserModel {
  late int id;
  final String status;
  final String login;
  final Company company;
  final Workstation workstation;
  final bool robert_access;
  final bool sttr_access;
  final bool quality;
  final bool calculateur;
  final bool db_doc_machine;
  final bool code_gen_robert;
  final bool outil_mach_sttr;
  final bool procedure_robert;
  final bool calculateur_procudeur_spec;

  UserModel({
    this.id = 0,
    this.status = "user",
    this.login = "",
    required this.company,
    required this.workstation,
    this.robert_access = false,
    this.sttr_access = false,
    this.quality = false,
    this.calculateur = false,
    this.db_doc_machine = false,
    this.code_gen_robert = false,
    this.outil_mach_sttr = false,
    this.procedure_robert = false,
    this.calculateur_procudeur_spec = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      status: json['status'],
      login: json['login'],
      company: json['company'],
      workstation: json['workstation'],
      robert_access: json['robert_access'],
      sttr_access: json['sttr_access'],
      quality: json['quality'],
      calculateur: json['calculateur'],
      db_doc_machine: json['db_doc_machine'],
      code_gen_robert: json['code_gen_robert'],
      outil_mach_sttr: json['outil_mach_sttr'],
      procedure_robert: json['procedure_robert'],
      calculateur_procudeur_spec: json['calculateur_procudeur_spec'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'login': login,
      'company': company.name, // Assuming company is an enum
      'workstation': workstation.name, // Assuming workstation is an enum
      'robert_access': robert_access,
      'sttr_access': sttr_access,
      'quality': quality,
      'calculateur': calculateur,
      'db_doc_machine': db_doc_machine,
      'code_gen_robert': code_gen_robert,
      'outil_mach_sttr': outil_mach_sttr,
      'procedure_robert': procedure_robert,
      'calculateur_procudeur_spec': calculateur_procudeur_spec,
    };
  }
}
