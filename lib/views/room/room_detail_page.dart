import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/maintenance_service.dart';
import '../../models/maintenance_request.dart';
import '../../models/room.dart';

class RoomDetailPage extends StatefulWidget {
  final Room room;

  const RoomDetailPage({super.key, required this.room});

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color cardBackground = Color(0xFFF5F7FA);

  late TabController _tabController;
  final TextEditingController _maintenanceTitleController =
      TextEditingController();
  final TextEditingController _maintenanceNoticeController =
      TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<MaintenanceRequest> _maintenanceRequests = [];
  List<MaintenanceRequest> _filteredMaintenanceRequests = [];
  bool _isLoading = false;

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

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemCountController = TextEditingController();
  final List<Map<String, dynamic>> minibarItems = [
    {'name': 'Water Bottles', 'count': 2},
    {'name': 'Soft Drinks', 'count': 3},
    {'name': 'Snacks', 'count': 4},
  ];

  final Map<String, List<String>> primaryItems = {
    'Bathroom': ['Wipes', 'Shampoo', 'Soap', 'Towels'],
    'Bedroom': ['Bed Sheets', 'Pillows', 'Blankets'],
    'Kitchen': ['Utensils', 'Plates', 'Glasses'],
    'Living Room': ['Couch', 'TV', 'Coffee Table'],
  };

  final Map<String, String> itemNotes = {};
  final Map<String, List<String>> selectedItems = {
    'Bathroom': [],
    'Bedroom': [],
    'Kitchen': [],
    'Living Room': [],
  };

  void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: successGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMaintenanceRequests();
  }

  Future<void> _loadMaintenanceRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await MaintenanceService.getMaintenanceRequests();
      setState(() {
        _maintenanceRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading maintenance requests: $e')),
      );
    }
  }

  Future<void> _submitMaintenanceRequest() async {
    if (_maintenanceTitleController.text.isEmpty ||
        _maintenanceNoticeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await MaintenanceService.createMaintenanceRequest(
        maintenanceTitle: _maintenanceTitleController.text,
        maintenanceStatement: _maintenanceNoticeController.text,
        roomNumber: widget.room.number.toString(),
      );

      // Clear the form and reload the list
      _maintenanceTitleController.clear();
      _maintenanceNoticeController.clear();
      await _loadMaintenanceRequests();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Maintenance request submitted successfully')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting maintenance request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          //image scetion
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // flexibleSpace: FlexibleSpaceBar(
            //   background: PageView.builder(
            //     itemCount: widget.room.images.length,
            //     itemBuilder: (context, index) {
            //       return Image.network(
            //         widget.room.images[index],
            //         fit: BoxFit.cover,
            //       );
            //     },
            //   ),
            // ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: [
                    Tab(text: l10n.details),
                    Tab(text: l10n.minibar),
                    Tab(text: l10n.schedule),
                    Tab(text: l10n.maintenance),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDetailsTab(context),
                      _buildMinibarTab(),
                      _buildScheduleTab(),
                      _buildMaintenanceTab(),
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

  Widget _buildMaintenanceTab() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Room ${widget.room.name}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Cleaned',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Maintenance Notice',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _maintenanceTitleController,
            decoration: InputDecoration(
              labelText: 'Add Maintenance Title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _maintenanceNoticeController,
            decoration: InputDecoration(
              labelText: 'Add Maintenance Notice',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitMaintenanceRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Submit Notice'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Maintenance Requests',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search Maintenance Requests',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _filteredMaintenanceRequests = _maintenanceRequests
                    .where((request) =>
                        request.maintenanceTitle
                            .toLowerCase()
                            .contains(value.toLowerCase()) ||
                        request.maintenanceStatement
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                    .toList();
              });
            },
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchController.text.isEmpty
                      ? _maintenanceRequests.length
                      : _filteredMaintenanceRequests.length,
                  itemBuilder: (context, index) {
                    final request = _searchController.text.isEmpty
                        ? _maintenanceRequests[index]
                        : _filteredMaintenanceRequests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    request.maintenanceTitle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    request.requestStatus == 0
                                        ? 'Pending'
                                        : 'Done',
                                    style: TextStyle(
                                      color: request.requestStatus == 0
                                          ? Colors.orange
                                          : Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              request.maintenanceStatement,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Request Number: ${request.requestNumber}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'In Progress';
      case 2:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailsTab(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Room ${widget.room.name}',
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
          const SizedBox(height: 24),
          Text(
            l10n.roomItems,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...primaryItems.entries.map((entry) {
            String category = entry.key;
            List<String> items = entry.value;

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(), // Pushes the icon to the right
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline,
                              color: Colors.blue),
                          onPressed: () => _addItem(category),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: items.map((item) {
                        bool isSelected =
                            selectedItems[category]?.contains(item) ?? false;
                        return FilterChip(
                          label: Text(item),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                selectedItems[category]?.add(item);
                              } else {
                                selectedItems[category]?.remove(item);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: l10n.notesFor + ' $category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: primaryBlue, width: 2),
                        ),
                        filled: true,
                        fillColor: cardBackground,
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        setState(() {
                          itemNotes[category] = value;
                        });
                      },
                      controller:
                          TextEditingController(text: itemNotes[category]),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              showSuccessSnackBar(context, 'Changes saved successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              l10n.saveChanges,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinibarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Room ${widget.room.name}',
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
          const SizedBox(height: 24),
          const Text(
            'Add New Item',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _itemNameController,
                    decoration: InputDecoration(
                      labelText: 'Item Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: primaryBlue, width: 2),
                      ),
                      filled: true,
                      fillColor: cardBackground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _itemCountController,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: primaryBlue, width: 2),
                      ),
                      filled: true,
                      fillColor: cardBackground,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_itemNameController.text.isNotEmpty &&
                          _itemCountController.text.isNotEmpty) {
                        setState(() {
                          minibarItems.add({
                            'name': _itemNameController.text,
                            'count': int.parse(_itemCountController.text),
                          });
                          _itemNameController.clear();
                          _itemCountController.clear();
                        });
                        showSuccessSnackBar(context, 'Item added successfully');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Add Item',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Minibar Items',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: minibarItems.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: Key(minibarItems[index]['name']),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  setState(() {
                    minibarItems.removeAt(index);
                  });
                },
                child: _buildMinibarItem(
                  minibarItems[index]['name'],
                  minibarItems[index]['count'],
                ),
              );
            },
          ),
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

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Room ${widget.room.name}',
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
          const SizedBox(height: 24),
          const Text(
            'Cleaning History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildScheduleItem(
                'Last Cleaned',
                widget.room.lastClean,
                'John Smith',
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildScheduleItem(
                'Deep Cleaning',
                widget.room.lastClean,
                'Sarah Johnson',
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(height: 24),
              const Text(
                'Upcoming Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildScheduleItem(
                'Regular Cleaning',
                widget.room.lastClean,
                'Mike Wilson',
                Icons.schedule,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
    String title,
    DateTime? time,
    String assignedTo,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time != null ? time.toString() : 'No Time',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Assigned to: $assignedTo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addItem(String category) {}

  @override
  void dispose() {
    _tabController.dispose();
    _maintenanceTitleController.dispose();
    _maintenanceNoticeController.dispose();
    super.dispose();
  }
}
