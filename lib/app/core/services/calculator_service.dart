import 'package:code_g/app/core/services/shared_service.dart';
import 'package:logger/logger.dart';

class CalculatorService {
  Logger logger = new Logger();
  final sharedService = new SharedService();

  Future<Map<String, dynamic>> calculateFiltage(
      String filetage, String machine) async {
    final filetageTable = await sharedService
        .loadJsonFromAssets('assets/json/filetageTable.json');
    final machineTable =
        await sharedService.loadJsonFromAssets('assets/json/machineTable.json');

    final filetageData = filetageTable[filetage];
    final machineData = machineTable[machine];

    final result =
        filetageData['reductionFactor'] * machineData['reductionFactor'];

    return {
      'filetage': filetage,
      'machine': machine,
      'result': result,
    };
  }

  Future<String> generateThreadingPasses(
      String threadType, int N, double pitch) async {
    // Thread data tables

    final filetageTable = await sharedService
        .loadJsonFromAssets('assets/json/filetageTable.json');
    final threadTables = filetageTable[threadType];

    // Get thread data
    final threadData = threadTables[threadType];

    if (threadData == null) {
      return 'Error: Thread type not found for $threadType';
    }

    final D1 = threadData["D1"] as double;
    final D3 = threadData["D3"] as double;
    final POriginal = threadData["P"] as double;
    final reductionFactor = threadData["reductionFactor"] as double;

    // Use provided pitch or original pitch if not provided
    final P = pitch ?? POriginal;

    // Calculate X values for each pass
    final xValues = <double>[];
    for (int i = 0; i < N; i++) {
      double X;
      if (i < N - 1) {
        // Linear interpolation between D3 and D1
        X = D3 + ((D1 - D3) * i / (N - 1));
      } else {
        // Last pass - apply reduction factor
        X = D1 - reductionFactor;
      }
      xValues.add(X);
    }

    // Generate G-code
    final gCode = StringBuffer();
    for (int i = 0; i < xValues.length; i++) {
      final lineNumberBase = 690 + i * 5;
      gCode.writeln('N${lineNumberBase} G0 X${(D1 + 2).toStringAsFixed(3)} Y0');
      gCode.writeln('N${lineNumberBase + 5} X${xValues[i].toStringAsFixed(3)}');
      gCode.writeln('N${lineNumberBase + 10} G33 K${P.toStringAsFixed(2)}');
      gCode.writeln('N${lineNumberBase + 15} G4 F.2');
      gCode.writeln(
          'N${lineNumberBase + 20} G0 X${(D1 + 2).toStringAsFixed(3)}');
    }

    return gCode.toString();
  }

  Map<String, dynamic> calculateThreading(
      double nominalDiameter, double threadPitch) {
    final rootDiameterBase = nominalDiameter - (0.613 * 2 * threadPitch);
    final thirdPassRootDiameter = (rootDiameterBase * 10).floor() / 10;
    final secondPassRootDiameter = thirdPassRootDiameter + 0.1;
    final firstPassRootDiameter = secondPassRootDiameter + 0.1;

    final clearanceDiameterBase = nominalDiameter + 0.15;
    final thirdPassClearance = (clearanceDiameterBase * 100).floor() / 100;
    final secondPassClearance =
        double.parse((thirdPassClearance + 0.1).toStringAsFixed(2));
    final firstPassClearance =
        double.parse((secondPassClearance + 0.1).toStringAsFixed(2));

    // Calculate Z for clearance
    final zClearance = threadPitch + 0.2;

    return {
      'rootDiameter': {
        'firstPass': firstPassRootDiameter.toStringAsFixed(1),
        'secondPass': secondPassRootDiameter.toStringAsFixed(1),
        'thirdPass': thirdPassRootDiameter.toStringAsFixed(1),
      },
      'clearance': {
        'firstPass': firstPassClearance.toStringAsFixed(2),
        'secondPass': secondPassClearance.toStringAsFixed(2),
        'thirdPass': thirdPassClearance.toStringAsFixed(2),
      },
      'z': zClearance.toStringAsFixed(2),
    };
  }

// Example usage
  void main() {
    final threadType = "M22x1,0";
    final passes = 10;
    final pitch = 1.0;
    final result = generateThreadingPasses(threadType, passes, pitch);
    print(result);
  }
}
