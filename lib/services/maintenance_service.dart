import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/maintenance_request.dart';

class MaintenanceService {
  static const String baseUrl = 'http://94.127.214.117:3000/api';
  static String _lastRequestNumber = 'REQ-1005';

  static String getNextRequestNumber() {
    // Extract the numeric part and increment
    int currentNumber = int.parse(_lastRequestNumber.split('-')[1]);
    currentNumber++;
    _lastRequestNumber = 'REQ-${currentNumber.toString().padLeft(4, '0')}';
    return _lastRequestNumber;
  }

  static Future<List<MaintenanceRequest>> getMaintenanceRequests() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/maintenanceRequest'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MaintenanceRequest.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load maintenance requests');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<MaintenanceRequest> createMaintenanceRequest({
    required String maintenanceTitle,
    required String maintenanceStatement,
    required String roomNumber,
  }) async {
    try {
      final requestData = {
        'RequestNumber': getNextRequestNumber(),
        'RequestDate': DateTime.now().toUtc().toIso8601String(),
        'RequestDepartment': 2,
        'RequestType': 'Maintenance',
        'MaintenanceTitle': maintenanceTitle,
        'MaintenanceStatement': maintenanceStatement,
        'MaintenancePlace': 'Room $roomNumber',
        'DeviceName': 'General',
        'DeviceNumber': 'N/A',
        'Branch': '3753add4-9f80-40b4-81e4-94c1a6615f15',
        'RequestStatus': 0,
        'RequestImage': null,
        'FinishDate': null,
        'MaintenanceOfficerNotes': maintenanceStatement,
        'AuditField': null
      };

      final response = await http.post(
        Uri.parse('$baseUrl/maintenanceRequest'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return MaintenanceRequest.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create maintenance request');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
