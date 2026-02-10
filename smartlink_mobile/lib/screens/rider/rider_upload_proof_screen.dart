import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_role.dart';
import '../../providers/auth_provider.dart';

enum RiderProofMode { pickup, delivery }

class RiderUploadProofScreen extends StatefulWidget {
  final Object orderId;
  final RiderProofMode mode;

  const RiderUploadProofScreen({
    super.key,
    required this.orderId,
    required this.mode,
  });

  @override
  State<RiderUploadProofScreen> createState() => _RiderUploadProofScreenState();
}

class _RiderUploadProofScreenState extends State<RiderUploadProofScreen> {
  bool _uploading = false;
  XFile? _file;

  Future<void> _pick() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (!mounted) return;
    setState(() => _file = file);
  }

  Future<void> _upload() async {
    final file = _file;
    if (file == null || _uploading) return;

    setState(() => _uploading = true);
    try {
      final path = widget.mode == RiderProofMode.pickup ? 'pickup-proof' : 'delivery-proof';
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.name,
        ),
      });

      await ApiClient.instance.dio.post('rider/orders/${widget.orderId}/$path', data: form);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final role = AppRoleX.fromApiValue(auth.currentUser?['role'] as String?);

    if (role != AppRole.rider) {
      return const _NotAuthorizedScreen(title: 'Upload proof');
    }

    final title = widget.mode == RiderProofMode.pickup ? 'Pickup proof' : 'Delivery proof';
    final file = _file;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Take a photo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'The backend stores your proof for dispute resolution.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (file != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                File(file.path),
                height: 220,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 180,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(Icons.photo_camera_outlined, size: 48, color: isDark ? Colors.white54 : Colors.black45),
            ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _uploading ? null : _pick,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Take photo'),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: (_uploading || file == null) ? null : _upload,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: Text(_uploading ? 'Uploading…' : 'Upload'),
          ),
        ],
      ),
    );
  }
}

class _NotAuthorizedScreen extends StatelessWidget {
  final String title;
  const _NotAuthorizedScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Not authorized for this section.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

