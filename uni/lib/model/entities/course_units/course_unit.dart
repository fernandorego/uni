/// Stores information about a course unit.
class CourseUnit {
  CourseUnit({
    this.id = 0,
    this.code = '',
    required this.abbreviation,
    required this.name,
    this.curricularYear,
    required this.occurrId,
    this.semesterCode,
    this.semesterName,
    this.type,
    this.status,
    this.grade,
    this.ectsGrade,
    this.result,
    this.ects,
    this.schoolYear,
  });

  int id;
  String code;
  String abbreviation;
  String name;
  int? curricularYear;
  int occurrId;
  String? semesterCode;
  String? semesterName;
  String? type;
  String? status;
  String? grade;
  String? ectsGrade;
  String? result;
  num? ects;
  String? schoolYear;

  /// Creates a new instance from a JSON object.
  static CourseUnit? fromJson(Map<String, dynamic> data) {
    if (data['ucurr_id'] == null) {
      return null;
    }
    return CourseUnit(
      id: data['ucurr_id'] as int,
      code: data['ucurr_codigo'] as String,
      abbreviation: data['ucurr_sigla'] as String,
      name: data['ucurr_nome'] as String,
      curricularYear: data['ano'] as int,
      occurrId: data['ocorr_id'] as int,
      semesterCode: data['per_codigo'] as String?,
      semesterName: data['per_nome'] as String?,
      type: data['tipo'] as String?,
      status: data['estado'] as String?,
      grade: data['resultado_melhor'] as String?,
      ectsGrade: data['resultado_ects'] as String?,
      result: data['resultado_insc'] as String?,
      ects: data['creditos_ects'] as double?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'abbreviation': abbreviation,
      'name': name,
      'curricularYear': curricularYear,
      'occurrId': occurrId,
      'semesterCode': semesterCode,
      'semesterName': semesterName,
      'type': type,
      'status': status,
      'grade': grade,
      'ectsGrade': ectsGrade,
      'result': result,
      'ects': ects,
      'schoolYear': schoolYear,
    };
  }

  bool enrollmentIsValid() {
    return status == 'V';
  }
}
