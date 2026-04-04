import 'package:flutter/material.dart';
import '../models/onboarding_model.dart';

class OnboardingItem extends StatelessWidget {
  final OnboardingModel model;

  const OnboardingItem({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // If we want to use an Icon string or asset path:
          // For now, let's treat imagePath as a placeholder for actual images.
          // Since we don't have assets yet, we can use a placeholder widget or an icon.
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              // Simple mapping from imagePath string to icon just for placeholder
              _getIcon(model.imagePath),
              size: 100,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 50),
          Text(
            model.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            model.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String path) {
    if (path.contains('search')) return Icons.search_rounded;
    if (path.contains('compare')) return Icons.compare_arrows_rounded;
    if (path.contains('flash')) return Icons.flash_on_rounded;
    return Icons.image_rounded;
  }
}
