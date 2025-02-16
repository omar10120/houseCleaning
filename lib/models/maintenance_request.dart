class MaintenanceRequest {
  final String requestNumber;
  final DateTime requestDate;
  final int requestDepartment;
  final String requestType;
  final String maintenanceTitle;
  final String maintenanceStatement;
  final String maintenancePlace;
  final String deviceName;
  final String deviceNumber;
  final String branch;
  final int requestStatus;
  final String? requestImage;
  final DateTime? finishDate;
  final String? maintenanceOfficerNotes;
  final dynamic auditField;

  MaintenanceRequest({
    required this.requestNumber,
    required this.requestDate,
    required this.requestDepartment,
    required this.requestType,
    required this.maintenanceTitle,
    required this.maintenanceStatement,
    required this.maintenancePlace,
    required this.deviceName,
    required this.deviceNumber,
    required this.branch,
    required this.requestStatus,
    this.requestImage,
    this.finishDate,
    this.maintenanceOfficerNotes,
    this.auditField,
  });

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      requestNumber: json['RequestNumber'],
      requestDate: DateTime.parse(json['RequestDate']),
      requestDepartment: json['RequestDepartment'],
      requestType: json['RequestType'],
      maintenanceTitle: json['MaintenanceTitle'],
      maintenanceStatement: json['MaintenanceStatement'],
      maintenancePlace: json['MaintenancePlace'],
      deviceName: json['DeviceName'],
      deviceNumber: json['DeviceNumber'],
      branch: json['Branch'],
      requestStatus: json['RequestStatus'],
      requestImage: json['RequestImage'],
      finishDate: json['FinishDate'] != null ? DateTime.parse(json['FinishDate']) : null,
      maintenanceOfficerNotes: json['MaintenanceOfficerNotes'],
      auditField: json['AuditField'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RequestNumber': requestNumber,
      'RequestDate': requestDate.toIso8601String(),
      'RequestDepartment': requestDepartment,
      'RequestType': requestType,
      'MaintenanceTitle': maintenanceTitle,
      'MaintenanceStatement': maintenanceStatement,
      'MaintenancePlace': maintenancePlace,
      'DeviceName': deviceName,
      'DeviceNumber': deviceNumber,
      'Branch': branch,
      'RequestStatus': requestStatus,
      'RequestImage': requestImage,
      'FinishDate': finishDate?.toIso8601String(),
      'MaintenanceOfficerNotes': maintenanceOfficerNotes,
      'AuditField': auditField,
    };
  }
}
