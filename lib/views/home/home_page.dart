import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/room.dart';
import '../../models/floor.dart';
import '../room/room_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedFloorIndex = 0;
  List<Floor> floors = [];
  List<Room> rooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFloors();
  }

  Future<void> fetchFloors() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.105:3000/api/hotel-floors'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Convert API response to Floor objects
        List<Floor> fetchedFloors =
            data.map((json) => Floor.fromJson(json)).toList();

        if (fetchedFloors.isNotEmpty) {
          // ✅ Find the floor with the lowest Number value
          fetchedFloors.sort((a, b) => a.number.compareTo(b.number));
          String selectedFloorGUID = fetchedFloors.first.guid;

          setState(() {
            floors = fetchedFloors;
            selectedFloorIndex =
                floors.indexWhere((floor) => floor.guid == selectedFloorGUID);
          });

          // Fetch rooms for the selected floor
          await fetchRooms(selectedFloorGUID);
        }
      }
    } catch (e) {
      print('Error fetching floors: $e');
    }
  }

  Future<void> fetchRooms(String floorGUID) async {
    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(
        Uri.parse(
            'http://192.168.1.105:3000/api/hotelRooms?FloorGUID=$floorGUID'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          rooms = data.map((json) => Room.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error fetching rooms: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'House Keeping Hotel',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Explore Our Services',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: const Icon(Icons.person_outline, color: Colors.black),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Floor Selection
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(
                floors.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedFloorIndex = index;
                      });
                      fetchRooms(floors[index].guid);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedFloorIndex == index
                          ? Colors.black
                          : Colors.grey[200],
                      foregroundColor: selectedFloorIndex == index
                          ? Colors.white
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                        'Floor ${floors[index].number}'), // ✅ Updated text to match `Number`
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Rooms List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RoomDetailPage(room: room),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Room ${room.name}',
                                      style: const TextStyle(
                                        fontSize: 20,
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
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 20),
                                    const SizedBox(width: 4),
                                    Text('4.5'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildStatusChip(room.status),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.square_foot, size: 20),
                                        Text(' ${room.roomType}'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.bed, size: 20),
                                        Text(' ${room.badsNumber} Beds'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.person_outline,
                                            size: 20),
                                        Text('  ${room.overLooking}'),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Last Clean:  ${room.lastClean}',
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 223, 69, 13),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
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
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(int status) {
    String label;
    Color color;

    switch (status) {
      case 0:
        label = 'Cleaned';
        color = Colors.green;
        break;
      case 1:
        label = 'In Progress';
        color = Colors.orange;
        break;
      case 2:
        label = 'Needs Cleaning';
        color = Colors.red;
        break;
      default:
        label = 'Unknown';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color),
      ),
    );
  }
}
