import 'package:flutter/material.dart';
import '../../models/room.dart';
import '../room/room_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedFloor = 1;
  int _selectedIndex = 0;

  final Map<int, List<Room>> _floorRooms = {
    1: [
      Room(
          number: '101',
          rating: 4.5,
          isCleaned: true,
          isInProgress: false,
          isMaintenance: false,
          area: 32,
          beds: 1,
          maxOccupancy: 2),
      Room(
          number: '102',
          rating: 4.4,
          isCleaned: false,
          isInProgress: false,
          isMaintenance: false,
          area: 40,
          beds: 2,
          maxOccupancy: 3),
      Room(
          number: '103',
          rating: 4.0,
          isCleaned: false,
          isInProgress: true,
          isMaintenance: false,
          area: 48,
          beds: 2,
          maxOccupancy: 4),
      // Room(
      //     number: '104',
      //     rating: 5.0,
      //     isCleaned: false,
      //     isInProgress: false,
      //     isMaintenance: true,
      //     area: 48,
      //     beds: 2,
      //     maxOccupancy: 4),
    ],
    2: [
      Room(
          number: '201',
          rating: 4.3,
          isCleaned: true,
          isInProgress: false,
          isMaintenance: false,
          area: 35,
          beds: 1,
          maxOccupancy: 2),
      Room(
          number: '202',
          rating: 4.6,
          isCleaned: false,
          isInProgress: true,
          isMaintenance: false,
          area: 42,
          beds: 2,
          maxOccupancy: 3),
      Room(
          number: '203',
          rating: 4.2,
          isCleaned: false,
          isInProgress: false,
          isMaintenance: false,
          area: 45,
          beds: 2,
          maxOccupancy: 4),
      // Room(
      //     number: '204',
      //     rating: 2.2,
      //     isCleaned: false,
      //     isInProgress: false,
      //     isMaintenance: true,
      //     area: 45,
      //     beds: 2,
      //     maxOccupancy: 4),
    ],
    3: [
      Room(
          number: '301',
          rating: 4.7,
          isCleaned: true,
          isInProgress: false,
          isMaintenance: false,
          area: 38,
          beds: 1,
          maxOccupancy: 2),
      Room(
          number: '302',
          rating: 4.5,
          isCleaned: true,
          isInProgress: false,
          isMaintenance: false,
          area: 44,
          beds: 2,
          maxOccupancy: 3),
      Room(
          number: '303',
          rating: 4.3,
          isCleaned: false,
          isInProgress: true,
          isMaintenance: false,
          area: 50,
          beds: 2,
          maxOccupancy: 4),
      // Room(
      //     number: '304',
      //     rating: 4.3,
      //     isCleaned: false,
      //     isInProgress: false,
      //     isMaintenance: true,
      //     area: 50,
      //     beds: 2,
      //     maxOccupancy: 4),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'House Keeping Hotel',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Explore Our Services',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFloorButton(1, 'Floor 1'),
                _buildFloorButton(2, 'Floor 2'),
                _buildFloorButton(3, 'Floor 3'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _floorRooms[_selectedFloor]?.length ?? 0,
              itemBuilder: (context, index) {
                final room = _floorRooms[_selectedFloor]![index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomDetailPage(room: room),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Room ${room.number}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.favorite_border),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              Text(' ${room.rating}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildStatusChip(
                            room.isCleaned
                                ? 'Cleaned'
                                : room.isInProgress
                                    ? 'In Progress'
                                    : room.isMaintenance
                                        ? 'Needs Maintenance'
                                        : 'Needs Cleaning',
                            room.isCleaned
                                ? Colors.green
                                : room.isInProgress
                                    ? Colors.amber
                                    : Colors.red,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.square_foot, size: 16),
                                  Text(' ${room.area}m²'),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.bed, size: 16),
                                  Text(' ${room.beds} Beds'),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.person_outline, size: 16),
                                  Text(' Max ${room.maxOccupancy}'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cleaning_services),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildFloorButton(int floor, String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _selectedFloor == floor ? Colors.black : Colors.grey[200],
        foregroundColor: _selectedFloor == floor ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () {
        setState(() {
          _selectedFloor = floor;
        });
      },
      child: Text(label),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
