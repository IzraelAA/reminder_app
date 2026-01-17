import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:reminder_app/features/reminder/services/location_permission_service.dart';
import 'package:reminder_app/utils/app_color.dart';
import 'package:reminder_app/utils/app_typography.dart';

/// Widget for picking and configuring location-based reminder settings
class LocationPickerWidget extends StatefulWidget {
  final bool isEnabled;
  final double? latitude;
  final double? longitude;
  final double radiusInMeters;
  final String? locationName;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<double?> onLatitudeChanged;
  final ValueChanged<double?> onLongitudeChanged;
  final ValueChanged<double> onRadiusChanged;
  final ValueChanged<String?> onLocationNameChanged;

  const LocationPickerWidget({
    super.key,
    required this.isEnabled,
    this.latitude,
    this.longitude,
    this.radiusInMeters = 150,
    this.locationName,
    required this.onEnabledChanged,
    required this.onLatitudeChanged,
    required this.onLongitudeChanged,
    required this.onRadiusChanged,
    required this.onLocationNameChanged,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  final _locationPermissionService = LocationPermissionService();
  final _locationNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _locationNameController.text = widget.locationName ?? '';
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        if (widget.isEnabled) ...[
          const SizedBox(height: 16),
          _buildLocationSection(),
          const SizedBox(height: 16),
          _buildRadiusSelector(),
          const SizedBox(height: 16),
          _buildLocationNameField(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.gray200.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.isEnabled
                  ? AppColor.accent.withValues(alpha: 0.1)
                  : AppColor.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: widget.isEnabled ? AppColor.accent : AppColor.textTertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Reminder',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Trigger when you arrive at a location',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: widget.isEnabled,
            onChanged: (value) async {
              if (value) {
                final result = await _locationPermissionService
                    .requestBackgroundLocationPermission();
                if (result != LocationPermissionResult.granted) {
                  if (context.mounted) {
                    _showPermissionDeniedDialog();
                  }
                  return;
                }
              }
              widget.onEnabledChanged(value);
            },
            activeTrackColor: AppColor.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    final hasLocation = widget.latitude != null && widget.longitude != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: AppTypography.labelLarge.copyWith(
              color: AppColor.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (hasLocation)
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColor.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.latitude!.toStringAsFixed(6)}, ${widget.longitude!.toStringAsFixed(6)}',
                    style: AppTypography.bodyMedium,
                  ),
                ),
                IconButton(
                  onPressed: _clearLocation,
                  icon: Icon(Icons.close_rounded, color: AppColor.textTertiary),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _getCurrentLocation,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColor.accent,
                        ),
                      )
                    : Icon(Icons.my_location_rounded, color: AppColor.accent),
                label: Text(
                  _isLoading ? 'Getting Location...' : 'Use Current Location',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColor.accent,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: AppColor.accent),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRadiusSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trigger Radius',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColor.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${widget.radiusInMeters.toInt()}m',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColor.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: widget.radiusInMeters.clamp(100, 500),
            min: 100,
            max: 500,
            divisions: 8,
            activeColor: AppColor.accent,
            inactiveColor: AppColor.gray200,
            onChanged: widget.onRadiusChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '100m',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColor.textTertiary,
                ),
              ),
              Text(
                '500m',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColor.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationNameField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColor.gray200.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _locationNameController,
        decoration: InputDecoration(
          hintText: 'Location name (optional)',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColor.textTertiary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.label_outline_rounded,
              color: AppColor.accent,
              size: 20,
            ),
          ),
        ),
        style: AppTypography.bodyLarge,
        textCapitalization: TextCapitalization.sentences,
        onChanged: widget.onLocationNameChanged,
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      widget.onLatitudeChanged(position.latitude);
      widget.onLongitudeChanged(position.longitude);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: AppColor.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearLocation() {
    widget.onLatitudeChanged(null);
    widget.onLongitudeChanged(null);
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location-based reminders require background location access. '
          'Please enable "Allow all the time" in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
