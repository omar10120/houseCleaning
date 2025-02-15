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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFloors();
  }

  Future<void> fetchFloors() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/api/hotel-floors'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        List<Floor> fetchedFloors =
            data.map((json) => Floor.fromJson(json)).toList();

        if (fetchedFloors.isNotEmpty) {
          fetchedFloors.sort((a, b) => a.number.compareTo(b.number));

          setState(() {
            floors = fetchedFloors;
            selectedFloorIndex = 0;
          });
        }
      }
    } catch (e) {
      print('Error fetching floors: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateRoomStatus(String roomGuid, int newStatus) async {
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:3000/api/hotel-floors'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'roomGuid': roomGuid, 'status': newStatus}),
      );

      if (response.statusCode == 200) {
        print('Room status updated successfully');

        // ✅ Fetch updated data after successful update
        fetchFloors();
      } else {
        print('Failed to update room status');
      }
    } catch (e) {
      print('Error updating room status: $e');
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: floors[selectedFloorIndex].rooms.length,
                    itemBuilder: (context, index) {
                      final room = floors[selectedFloorIndex].rooms[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔹 Room Title & Favorite Icon
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

                              const SizedBox(height: 16),

                              // 🔹 Room Status Dropdown
                              _buildStatusDropdown(room),

                              const SizedBox(height: 16),

                              // 🔹 Room Status Label (Badge)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      _getStatusColor(room.statusDescription),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  room.statusDescription ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // 🔹 Room Details (Back View, Beds, Suite)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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

                              // 🔹 Last Clean Date
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(Room room) {
    final Map<int, String> statusOptions = {
      0: "Normal",
      1: "CleanRequest",
      2: "OutOfService",
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

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return Colors.green; // ✅ Green for Available
      case 'dirty':
        return Colors.red; // ✅ Red for Dirty
      case 'reserved':
        return Colors.orange; // ✅ Orange for Reserved
      default:
        return Colors.black54;
    }
  }
}
