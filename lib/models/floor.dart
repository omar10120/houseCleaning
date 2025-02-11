class Floor {
  final String guid;
  final int number;
  final String code;
  final String name;
  final String notes;

  Floor({
    required this.guid,
    required this.number,
    required this.code,
    required this.name,
    required this.notes,
  });

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      guid: json['GUID'],
      number: json['Number'],
      code: json['Code'],
      name: json['Name'],
      notes: json['Notes'],
    );
  }
}
