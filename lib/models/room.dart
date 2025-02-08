class Room {
  final String number;
  final double rating;
  final bool isCleaned;
  final bool isInProgress;
  final int area;
  final int beds;
  final int maxOccupancy;
  final List<String> images;

  Room({
    required this.number,
    required this.rating,
    required this.isCleaned,
    required this.isInProgress,
    required this.area,
    required this.beds,
    required this.maxOccupancy,
    this.images = const [
      'https://images.unsplash.com/photo-1611892440504-42a792e24d32?q=80&w=2070&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=2070&auto=format&fit=crop'
    ],
  });
}
