import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/room.dart';
import '../../models/floor.dart';
import '../../components/settings_page.dart';
import '../../components/bottom_nav_bar.dart';
import '../room/room_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedFloorIndex = -1;
  List<Floor> floors = [];
  bool isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchFloors();
  }

  Future<void> fetchFloors() async {
    try {
      final response = await http
          .get(Uri.parse('http://94.127.214.117:3000/api/hotel-floors'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Floor> fetchedFloors =
            data.map((json) => Floor.fromJson(json)).toList();

        setState(() {
          floors = fetchedFloors;
          selectedFloorIndex = fetchedFloors.isEmpty ? -1 : 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching floors: $e');
      setState(() {
        isLoading = false;
        selectedFloorIndex = -1;
      });
    }
  }

  Future<void> updateRoomStatus(String roomGuid, int newStatus) async {
    try {
      final response = await http.patch(
        Uri.parse('http://94.127.214.117:3000/api/hotel-floors'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'roomGuid': roomGuid, 'status': newStatus}),
      );

      if (response.statusCode == 200) {
        print('Room status updated successfully');
        fetchFloors();
      } else {
        print('Failed to update room status');
      }
    } catch (e) {
      print('Error updating room status: $e');
    }
  }

  Widget _buildHomeContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (floors.isEmpty) {
      return const Center(
        child: Text(
          'No floors available',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Column(
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
                  child: Text('Floor ${floors[index].number}'),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Rooms List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: floors[selectedFloorIndex].rooms.length,
            itemBuilder: (context, index) {
              final room = floors[selectedFloorIndex].rooms[index];
              return Card(
                margin: const EdgeInsets.all(8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                        const SizedBox(height: 16),
                        _buildStatusDropdown(room),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(room.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(room.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.landscape,
                                    size: 18, color: Colors.black54),
                                const SizedBox(width: 4),
                                const Text("Back View"),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.bed,
                                    size: 18, color: Colors.black54),
                                const SizedBox(width: 4),
                                Text('${room.badsNumber} Beds'),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.apartment,
                                    size: 18, color: Colors.black54),
                                const SizedBox(width: 4),
                                const Text("Suite"),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Last Clean: ${room.lastClean ?? "Not Cleaned"}',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 223, 69, 13),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      PageStorage(
        bucket: PageStorageBucket(),
        child: _buildHomeContent(),
      ),
      PageStorage(
        bucket: PageStorageBucket(),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cleaning_services, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'Cleaning Tasks',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Coming Soon',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      PageStorage(
        bucket: PageStorageBucket(),
        child: const SettingsPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'House Keeping'
              : _currentIndex == 1
                  ? 'Cleaning Tasks'
                  : 'Settings',
        ),
        centerTitle: true,
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildStatusDropdown(Room room) {
    final Map<int, String> statusOptions = {
      0: "Clean",
      1: "Clean Request",
      2: "Out Of Service",
    };

    return DropdownButton<int>(
      value: room.status,
      icon: const Icon(Icons.arrow_drop_down),
      isExpanded: true,
      style: const TextStyle(fontSize: 16, color: Colors.black),
      onChanged: (int? newStatus) {
        if (newStatus != null) {
          setState(() {
            room.status = newStatus;
          });
          updateRoomStatus(room.guid, newStatus);
        }
      },
      items: statusOptions.entries.map((entry) {
        return DropdownMenuItem<int>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
    );
  }

  String _getStatusText(int status) {
    final Map<int, String> statusOptions = {
      0: "Clean",
      1: "Clean Request",
      2: "Out Of Service",
    };

    return statusOptions[status] ?? '';
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.black54;
    }
  }
}
