class Room {
  final String guid;
  final int number;
  final String code;
  final String name;
  final int badsNumber;
  final double price;
  final String overLooking;
  final String roomType;
  final int status;
  final String notes;
  final String floorGUID;
  final DateTime? lastClean;

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
    required this.status,
    required this.notes,
    required this.floorGUID,
    this.lastClean,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      guid: json['GUID'],
      number: json['Number'],
      code: json['Code'],
      name: json['Name'],
      badsNumber: json['BadsNumber'],
      price: json['Price'].toDouble(),
      overLooking: json['OverLooking'],
      roomType: json['RoomType'],
      status: json['Status'],
      notes: json['Notes'],
      floorGUID: json['FloorGUID'],
      lastClean:
          json['LastClean'] != null ? DateTime.parse(json['LastClean']) : null,
    );
  }
}
