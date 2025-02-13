class Material {
  final String guid;
  final int id;
  final int? matType;
  final String? matGuid;
  final double? qnt;
  final double? materialBalance;
  final String? notes;

  Material({
    required this.guid,
    required this.id,
    this.matType,
    this.matGuid,
    this.qnt,
    this.materialBalance,
    this.notes,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      guid: json['Guid'],
      id: json['ID'],
      matType: json['MatType'],
      matGuid: json['MatGuid'],
      qnt: json['Qnt'] != null
          ? double.parse(json['Qnt'].toString())
          : null, // Handle potential string/int
      materialBalance: json['MaterialBalance'] != null
          ? double.parse(json['MaterialBalance'].toString())
          : null, // Handle potential string/int
      notes: json['Notes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'Guid': guid,
        'ID': id,
        'MatType': matType,
        'MatGuid': matGuid,
        'Qnt': qnt,
        'MaterialBalance': materialBalance,
        'Notes': notes,
      };
}
