import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hungry/features/dashboard/controllers/dashboard_controller.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _textController = TextEditingController();
  final DashboardController _dashboardController = Get.find();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFFFF5200), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _textController,
                  onChanged: (value) {
                    _dashboardController.search(value);
                  },
                  decoration: InputDecoration(
                    hintText: "Restaurant name or a dish...",
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Clear button if searching
              Obx(
                () => _dashboardController.searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _textController.clear();
                          _dashboardController.stopSearch();
                          FocusScope.of(context).unfocus();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 12),
              Container(height: 24, width: 1, color: Colors.grey[300]),
              const SizedBox(width: 12),
              const Icon(Icons.mic, color: Color(0xFFFF5200), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
