import 'package:flutter/material.dart';

class AddressSection extends StatelessWidget {
  const AddressSection({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Địa chỉ nhận hàng',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ví dụ: 12 Nguyễn Trãi, P.Bến Thành, Q.1, TP.HCM',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
