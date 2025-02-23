import 'room.dart';

class Floor {
  final String guid;
  final int number;
  final String code;
  final String name;
  final String notes;
  final List<Room> rooms; // ✅ Make sure rooms are included

  Floor({
    required this.guid,
    required this.number,
    required this.code,
    required this.name,
    required this.notes,
    required this.rooms, // ✅ Initialize rooms
  });

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      guid: json['GUID'],
      number: json['Number'],
      code: json['Code'],
      name: json['Name'],
      notes: json['Notes'] ?? "",
      rooms: (json['rooms'] as List<dynamic>) // ✅ Correctly map rooms
          .map((roomJson) => Room.fromJson(roomJson))
          .toList(),
    );
  }
}
