import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/room.dart';
import '../../models/floor.dart';
import '../../components/settings_page.dart';
import '../../components/bottom_nav_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../room/room_detail_page.dart';
import '../profile/profile_page.dart';

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
        _buildFloorButtons(),
        const SizedBox(height: 16),
        // Rooms List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: floors[selectedFloorIndex].rooms.length,
            itemBuilder: (context, index) {
              final room = floors[selectedFloorIndex].rooms[index];
              return _buildRoomCard(room);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFloorButtons() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(
            floors.length,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedFloorIndex = index;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedFloorIndex == index
                        ? Colors.blue
                        : Colors.white,
                    foregroundColor: selectedFloorIndex == index
                        ? Colors.white
                        : Colors.blue,
                    elevation: selectedFloorIndex == index ? 8 : 2,
                    shadowColor: Colors.blue.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: selectedFloorIndex == index
                            ? Colors.transparent
                            : Colors.blue.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                  ),
                  child: Text(
                    '${l10n.floor} ${floors[index].code}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: selectedFloorIndex == index
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<Widget> pages = [
      PageStorage(
        bucket: PageStorageBucket(),
        child: RefreshIndicator(
          onRefresh: fetchFloors,
          child: _buildHomeContent(),
        ),
      ),
      PageStorage(
        bucket: PageStorageBucket(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cleaning_services, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                l10n.cleaning,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.comingSoon,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      PageStorage(
        bucket: PageStorageBucket(),
        child: const SettingsPage(),
      ),
      PageStorage(
        bucket: PageStorageBucket(),
        child: const ProfilePage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue, Colors.lightBlueAccent],
            ),
          ),
        ),
        title: Text(
          _currentIndex == 0
              ? l10n.appName
              : _currentIndex == 1
                  ? l10n.cleaning
                  : _currentIndex == 2
                      ? l10n.settings
                      : l10n.profile,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: _getStatusColor(room.status).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RoomDetailPage(room: room),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.hotel,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${l10n.room} ${room.name}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.red,
                        size: 28,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade50,
                  ),
                  child: _buildStatusDropdown(room),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(room.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(room.status).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: _getStatusColor(room.status),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getStatusText(room.status),
                        style: TextStyle(
                          color: _getStatusColor(room.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(Icons.landscape, l10n.backView),
                      _buildInfoItem(
                          Icons.bed, '${room.badsNumber} ${l10n.beds}'),
                      _buildInfoItem(Icons.apartment, l10n.suite),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 245, 240),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromARGB(255, 223, 69, 13),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cleaning_services,
                        color: const Color.fromARGB(255, 223, 69, 13),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${l10n.lastClean}: ${room.lastClean ?? l10n.notCleaned}',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 223, 69, 13),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(Room room) {
    final l10n = AppLocalizations.of(context)!;
    final Map<int, String> statusOptions = {
      0: l10n.clean,
      1: l10n.cleanRequest,
      2: l10n.outOfService,
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
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 0:
        return l10n.clean;
      case 1:
        return l10n.cleanRequest;
      case 2:
        return l10n.outOfService;
      default:
        return '';
    }
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
