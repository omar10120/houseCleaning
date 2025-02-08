import 'package:flutter/material.dart';
import 'views/auth/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'House Keeping Hotel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

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

class RoomDetailPage extends StatefulWidget {
  final Room room;

  const RoomDetailPage({super.key, required this.room});

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, bool> departmentChecklist = {
    'Bathroom': false,
    'Kitchen': false,
    'Bedroom': false,
    'Living Room': false,
    'Balcony': false,
  };

  Map<String, String> staffAssignments = {
    'Bathroom': 'John',
    'Kitchen': 'Sarah',
    'Bedroom': 'Mike',
    'Living Room': 'Emma',
    'Balcony': 'David',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: PageView.builder(
                itemCount: widget.room.images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.room.images[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Details'),
                    Tab(text: 'Minibar'),
                    Tab(text: 'Schedule'),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildDetailsTab(),
                      _buildMinibarTab(),
                      _buildScheduleTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Room ${widget.room.number}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Cleaned',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Premium Suite',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn('Size', '32m²'),
              _buildInfoColumn('Occupancy', '2 Adults'),
              _buildInfoColumn('Rating', '4.5 ★'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Luxurious and spacious room featuring modern amenities, a comfortable king-size bed, and a stunning view. Perfect for both business and leisure travelers seeking comfort and style.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Premium Suite',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              if (widget.room.isCleaned)
                _buildStatusChip(
                  'Cleaned',
                  Colors.green[100]!,
                  Colors.green,
                  Icons.check_circle,
                )
              else if (widget.room.isInProgress)
                _buildStatusChip(
                  'In Progress',
                  Colors.yellow[100]!,
                  Colors.orange,
                  Icons.access_time,
                )
              else
                _buildStatusChip(
                  'Needs Cleaning',
                  Colors.red[100]!,
                  Colors.red,
                  Icons.cleaning_services,
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Department Checklist',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          ...departmentChecklist.keys.map((department) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: departmentChecklist[department],
                      onChanged: (bool? value) {
                        setState(() {
                          departmentChecklist[department] = value ?? false;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  title: Text(
                    department,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      staffAssignments[department] ?? '',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 24),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue[700], size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Room Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow('Size', '32m²'),
                  _buildInfoRow('Occupancy', '2 Adults'),
                  _buildInfoRow('Rating', '4.5 ★'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinibarTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Minibar Items',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMinibarItem('Water Bottles', 2),
          _buildMinibarItem('Soft Drinks', 3),
          _buildMinibarItem('Snacks', 4),
        ],
      ),
    );
  }

  Widget _buildMinibarItem(String name, int items) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '$items items',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesTab() {
    final amenities = [
      {
        'icon': Icons.wifi,
        'title': 'Free WiFi',
        'description': 'High-speed internet access'
      },
      {
        'icon': Icons.ac_unit,
        'title': 'Air Conditioning',
        'description': 'Climate control system'
      },
      {
        'icon': Icons.tv,
        'title': 'Smart TV',
        'description': '55-inch 4K display'
      },
      {
        'icon': Icons.local_parking,
        'title': 'Parking',
        'description': 'Complimentary parking'
      },
      {
        'icon': Icons.fitness_center,
        'title': 'Gym Access',
        'description': '24/7 fitness center'
      },
      {
        'icon': Icons.room_service,
        'title': 'Room Service',
        'description': 'Available 24 hours'
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: amenities.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final amenity = amenities[index];
        return ListTile(
          leading:
              Icon(amenity['icon'] as IconData, color: Colors.blue, size: 28),
          title: Text(
            amenity['title'] as String,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(amenity['description'] as String),
        );
      },
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildScheduleSection(
            'Cleaning History',
            [
              _buildScheduleItem(
                'Last Cleaned',
                '2 hours ago',
                'John Smith',
                Icons.check_circle,
                Colors.green,
              ),
              _buildScheduleItem(
                'Deep Cleaning',
                'Yesterday, 2:30 PM',
                'Sarah Johnson',
                Icons.check_circle,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildScheduleSection(
            'Upcoming Schedule',
            [
              _buildScheduleItem(
                'Regular Cleaning',
                'Tomorrow, 10:00 AM',
                'Mike Wilson',
                Icons.schedule,
                Colors.orange,
              ),
              _buildScheduleItem(
                'Deep Cleaning',
                'Next Week, Monday',
                'Team A',
                Icons.event,
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildScheduleItem(
    String title,
    String time,
    String staff,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Assigned to: $staff',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
      String label, Color backgroundColor, Color iconColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: iconColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class HotelFloorPage extends StatefulWidget {
  const HotelFloorPage({super.key});

  @override
  State<HotelFloorPage> createState() => _HotelFloorPageState();
}

class _HotelFloorPageState extends State<HotelFloorPage> {
  int _selectedFloor = 1;

  final Map<int, List<Room>> _floorRooms = {
    1: [
      Room(
          number: '101',
          rating: 4.5,
          isCleaned: true,
          isInProgress: false,
          area: 32,
          beds: 1,
          maxOccupancy: 2),
      Room(
          number: '102',
          rating: 4.4,
          isCleaned: false,
          isInProgress: false,
          area: 40,
          beds: 2,
          maxOccupancy: 3),
      Room(
          number: '103',
          rating: 4.0,
          isCleaned: false,
          isInProgress: true,
          area: 48,
          beds: 2,
          maxOccupancy: 4),
    ],
    2: [
      Room(
          number: '201',
          rating: 4.3,
          isCleaned: true,
          isInProgress: false,
          area: 35,
          beds: 1,
          maxOccupancy: 2),
      Room(
          number: '202',
          rating: 4.6,
          isCleaned: false,
          isInProgress: true,
          area: 42,
          beds: 2,
          maxOccupancy: 3),
      Room(
          number: '203',
          rating: 4.2,
          isCleaned: false,
          isInProgress: false,
          area: 45,
          beds: 2,
          maxOccupancy: 4),
    ],
    3: [
      Room(
          number: '301',
          rating: 4.7,
          isCleaned: true,
          isInProgress: false,
          area: 38,
          beds: 1,
          maxOccupancy: 2),
      Room(
          number: '302',
          rating: 4.5,
          isCleaned: true,
          isInProgress: false,
          area: 44,
          beds: 2,
          maxOccupancy: 3),
      Room(
          number: '303',
          rating: 4.3,
          isCleaned: false,
          isInProgress: true,
          area: 50,
          beds: 2,
          maxOccupancy: 4),
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
              onPressed: () {
                // Handle profile button press
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Explore Our Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [1, 2, 3].map((floor) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedFloor == floor
                          ? Colors.black
                          : Colors.grey[200],
                      foregroundColor:
                          _selectedFloor == floor ? Colors.white : Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedFloor = floor;
                      });
                    },
                    child: Text('Floor $floor'),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _floorRooms[_selectedFloor]?.length ?? 0,
              itemBuilder: (context, index) {
                final room = _floorRooms[_selectedFloor]![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomDetailPage(room: room),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
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
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              Text(' ${room.rating}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (room.isCleaned)
                            _buildStatusChip(
                              'Cleaned',
                              Colors.green[100]!,
                              Colors.green,
                              Icons.check_circle,
                            )
                          else if (room.isInProgress)
                            _buildStatusChip(
                              'In Progress',
                              Colors.yellow[100]!,
                              Colors.orange,
                              Icons.access_time,
                            )
                          else
                            _buildStatusChip(
                              'Needs Cleaning',
                              Colors.red[100]!,
                              Colors.red,
                              Icons.cleaning_services,
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildInfoItem(
                                  Icons.square_foot, '${room.area}m²'),
                              const SizedBox(width: 16),
                              _buildInfoItem(Icons.bed, '${room.beds} Beds'),
                              const SizedBox(width: 16),
                              _buildInfoItem(
                                  Icons.person, 'Max ${room.maxOccupancy}'),
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
          BottomNavigationBar(
            currentIndex: 0,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz),
                label: 'Maintenance',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
      String label, Color backgroundColor, Color iconColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: iconColor),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
