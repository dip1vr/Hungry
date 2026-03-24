import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hungry/shared/widgets/optimized_network_image.dart';

import 'package:hungry/features/chat/chat_page.dart';
import 'package:get/get.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please login to view orders"));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(
          "My Orders",
          style: TextStyle(
            fontSize: 28,
            color: Colors.black87,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFF5200),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFFF5200),
          indicatorWeight: 3,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: "Live Orders"),
            Tab(text: "History"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LiveOrdersList(userId: user.uid),
          _HistoryOrdersList(userId: user.uid),
        ],
      ),
    );
  }
}

class _LiveOrdersList extends StatefulWidget {
  final String userId;
  const _LiveOrdersList({required this.userId});

  @override
  State<_LiveOrdersList> createState() => _LiveOrdersListState();
}

class _LiveOrdersListState extends State<_LiveOrdersList> {
  Future<void> _refresh() async {
    // Simulate refresh or force re-fetch if needed.
    // For StreamBuilder, rebuilding triggers a new stream subscription if the stream instance changes.
    // Since we create the stream in build, setState works.
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFFFF5200),
      onRefresh: _refresh,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF5200)),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final orders =
              snapshot.data?.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final status = (data['status'] ?? '').toString().toLowerCase();
                return status != 'delivered' && status != 'cancelled';
              }).toList() ??
              [];

          orders.sort((a, b) {
            final aTime =
                (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            final bTime =
                (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            return bTime.compareTo(aTime);
          });

          if (orders.isEmpty) {
            return Stack(
              children: [
                ListView(), // Ensure RefreshIndicator works even when empty
                Positioned.fill(
                  child: _buildEmptyState(
                    "No Active Orders",
                    "Hungry? Place an order now!",
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              return _LiveOrderCard(orderDoc: orders[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5200).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FeatherIcons.truck,
              size: 48,
              color: Color(0xFFFF5200),
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 24, color: Colors.grey[800])),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _HistoryOrdersList extends StatefulWidget {
  final String userId;
  const _HistoryOrdersList({required this.userId});

  @override
  State<_HistoryOrdersList> createState() => _HistoryOrdersListState();
}

class _HistoryOrdersListState extends State<_HistoryOrdersList> {
  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFFFF5200),
      onRefresh: _refresh,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF5200)),
            );
          }

          final orders =
              snapshot.data?.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final status = (data['status'] ?? '').toString().toLowerCase();
                return status == 'delivered' || status == 'cancelled';
              }).toList() ??
              [];

          orders.sort((a, b) {
            final aTime =
                (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            final bTime =
                (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(0);
            return bTime.compareTo(aTime);
          });

          if (orders.isEmpty) {
            return Stack(
              children: [
                ListView(),
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FeatherIcons.clock,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Past Orders",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _HistoryOrderCard(
                orderData: orders[index].data() as Map<String, dynamic>,
              );
            },
          );
        },
      ),
    );
  }
}

class _LiveOrderCard extends StatelessWidget {
  final DocumentSnapshot orderDoc;
  const _LiveOrderCard({required this.orderDoc});

  @override
  Widget build(BuildContext context) {
    final data = orderDoc.data() as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>? ?? [];
    final status = (data['status'] ?? 'pending').toString();
    final vendorId = data['vendorId'];
    final deliveryBoyId = data['deliveryBoyId'];
    final orderId = data['orderId'] ?? orderDoc.id;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Header with Restaurant Info
          if (vendorId != null)
            _buildRestaurantHeader(context, vendorId, status, orderId),

          const Divider(height: 1),

          // 2. Order Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order Items",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: OptimizedNetworkImage(
                                imageUrl: item['imageUrl'] ?? '',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item['title'] ?? 'Unknown',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "${item['quantity']}x • ₹${item['price']}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 3. Status Stepper
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildStatusTracker(status),
          ),

          // 4. Delivery Boy Section (If assigned)
          if (deliveryBoyId != null)
            _buildDeliveryBoyInfo(context, deliveryBoyId, orderId, status),

          if (deliveryBoyId == null && status != 'pending')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFF5200),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Searching for delivery partner...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // 5. Footer Details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TOTAL AMOUNT",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      "₹${((data['totalAmount'] ?? 0) + (data['deliveryFee'] ?? 0)).toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5200).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (data['paymentMethod'] ?? 'COD').toString().toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF5200),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantHeader(
    BuildContext context,
    String vendorId,
    String status,
    String orderId,
  ) {
    bool canChat = status.toLowerCase() != 'pending';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('restaurants')
          .doc(vendorId)
          .get(),
      builder: (context, snapshot) {
        String name = "Restaurant";
        String address = "Loading info...";

        if (snapshot.hasData && snapshot.data!.exists) {
          final rData = snapshot.data!.data() as Map<String, dynamic>;
          name = rData['restaurantName'] ?? 'Unknown Restaurant';
          address = rData['location'] ?? 'Location info unavailable';
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  FeatherIcons.coffee,
                  color: Color(0xFFFF5200),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 18, letterSpacing: 0.5),
                    ),
                    Text(
                      address,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (canChat)
                IconButton(
                  onPressed: () {
                    Get.to(
                      () => ChatPage(
                        orderId: orderId,
                        targetId: vendorId,
                        targetName: name,
                        title: "Chat with Restaurant",
                      ),
                    );
                  },
                  icon: const Icon(
                    FeatherIcons.messageCircle,
                    color: Color(0xFFFF5200),
                  ),
                  tooltip: 'Chat with Restaurant',
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeliveryBoyInfo(
    BuildContext context,
    String deliveryBoyId,
    String orderId,
    String status,
  ) {
    bool canChat = status.toLowerCase() != 'pending';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('deliveryBoys')
          .doc(deliveryBoyId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox();
        }

        final dData = snapshot.data!.data() as Map<String, dynamic>;
        final name = dData['name'] ?? 'Delivery Partner';
        final phone = dData['phone'] as String?;
        final vehicle = dData['vehicleDetails']?['model'] ?? 'Bike';
        final vehicleNo = dData['vehicleDetails']?['number'] ?? '';
        final profilePic = dData['profilePic'];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50]?.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[100],
                backgroundImage: profilePic != null
                    ? NetworkImage(profilePic)
                    : null,
                child: profilePic == null
                    ? const Icon(
                        FeatherIcons.user,
                        color: Colors.blue,
                        size: 20,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "$vehicle • $vehicleNo",
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              if (canChat)
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.to(
                          () => ChatPage(
                            orderId: orderId,
                            targetId: deliveryBoyId,
                            targetName: name,
                            title: "Chat with Driver",
                          ),
                        );
                      },
                      icon: const Icon(
                        FeatherIcons.messageCircle,
                        color: Colors.blue,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              if (phone != null)
                IconButton(
                  onPressed: () async {
                    final Uri launchUri = Uri(scheme: 'tel', path: phone);
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri);
                    }
                  },
                  icon: const Icon(FeatherIcons.phoneCall, color: Colors.green),
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusTracker(String status) {
    // Stages: Pending -> Accepted -> In Kitchen (Preparing) -> Out for delivery -> Delivered
    // Mapping internal status to steps
    int currentStep = 0;
    status = status.toLowerCase();

    if (status == 'pending') {
      currentStep = 0;
    } else if (status == 'accepted')
      currentStep = 1;
    else if (status == 'preparing')
      currentStep = 2; // Assuming 'preparing' is a status
    else if (status == 'out_for_delivery' || status == 'picked_up')
      currentStep = 3;
    else if (status == 'delivered')
      currentStep = 4;

    // We only show up to 'Out for delivery' in tracking usually, as 'Delivered' finishes it.
    // Let's make a visual bar.
    final steps = ["Placed", "Accepted", "Cooking", "On way"];

    return Row(
      children: List.generate(steps.length, (index) {
        bool isActive = index <= currentStep;
        bool isLast = index == steps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 30, // Fixed width for dot
                    height: 30,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFFF5200)
                          : Colors.grey[200],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFFFF5200)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Icon(
                      _getStepIcon(index),
                      size: 14,
                      color: isActive ? Colors.white : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? Colors.black87 : Colors.grey,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(
                      bottom: 14,
                    ), // Align with circle center roughly
                    color: isActive && index < currentStep
                        ? const Color(0xFFFF5200)
                        : Colors.grey[200],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  IconData _getStepIcon(int index) {
    switch (index) {
      case 0:
        return FeatherIcons.fileText;
      case 1:
        return FeatherIcons.checkCircle;
      case 2:
        return FeatherIcons.grid; // Kitchen/Cooking
      case 3:
        return FeatherIcons.truck;
      default:
        return FeatherIcons.circle;
    }
  }
}

class _HistoryOrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;
  const _HistoryOrderCard({required this.orderData});

  @override
  Widget build(BuildContext context) {
    // Format Date
    String formattedDate = '';
    if (orderData['createdAt'] != null) {
      final timestamp = orderData['createdAt'] as Timestamp;
      formattedDate = DateFormat(
        'MMM dd, yyyy • hh:mm a',
      ).format(timestamp.toDate());
    }

    // Status Color
    final String status = orderData['status'] ?? 'Pending';
    Color statusColor = status.toLowerCase() == 'delivered'
        ? Colors.green
        : Colors.red;

    // Items List String
    List<dynamic> items = orderData['items'] ?? [];
    String itemsText = items
        .map((item) {
          if (item is Map) return "${item['quantity']}x ${item['title']}";
          return "";
        })
        .join(", ");

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            itemsText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Vendor Name Future
          if (orderData['vendorId'] != null)
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('restaurants')
                  .doc(orderData['vendorId'])
                  .get(),
              builder: (context, snapshot) {
                String text = "Unknown Restaurant";
                if (snapshot.hasData && snapshot.data!.exists) {
                  text = snapshot.data!['restaurantName'] ?? text;
                }
                return Row(
                  children: [
                    const Icon(
                      FeatherIcons.mapPin,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      text,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                );
              },
            ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Amount",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                "₹${((orderData['totalAmount'] ?? 0) + (orderData['deliveryFee'] ?? 0)).toStringAsFixed(2)}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
