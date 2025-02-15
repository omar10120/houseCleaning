class Room {
  final String guid;
  final int number;
  final String code;
  final String name;
  final int badsNumber;
  final double price;
  final String overLooking;
  final String roomType;
  int status; // ✅ Changed from String to int
  final String notes;
  final String floorGUID;
  final DateTime? lastClean;
  final String? statusDescription;

  // Keep these for UI purposes
  bool get isCleaned => status == 0;
  bool get isInProgress => status == 1;
  bool get isMaintenance => status == 2;

  Room({
    required this.guid,
    required this.number,
    required this.code,
    required this.name,
    required this.badsNumber,
    required this.price,
    required this.overLooking,
    required this.roomType,
    required this.status, // ✅ Ensure status is an int
    required this.notes,
    required this.floorGUID,
    this.lastClean,
    this.statusDescription,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      guid: json['GUID'],
      number: json['Number'],
      code: json['Code'],
      name: json['Name'],
      badsNumber: json['BadsNumber'],
      price: (json['Price'] as num).toDouble(), // ✅ Ensure price is double
      overLooking: json['OverLooking'] ?? "",
      roomType: json['RoomType'] ?? "",
      status: json['Status'] is int
          ? json['Status']
          : int.tryParse(json['Status'].toString()) ?? 0, // ✅ Fix TypeError
      notes: json['Notes'] ?? "",
      floorGUID: json['FloorGUID'],
      statusDescription: json['statusDescription'],
      lastClean: json['LastClean'] != null
          ? DateTime.tryParse(json['LastClean'])
          : null,
    );
  }
}
