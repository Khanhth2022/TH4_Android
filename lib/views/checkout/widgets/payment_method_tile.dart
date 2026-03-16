import 'package:flutter/material.dart';

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final IconData icon;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
          ),
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
