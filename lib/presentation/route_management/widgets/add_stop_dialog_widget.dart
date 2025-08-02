import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AddStopDialogWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddStop;

  const AddStopDialogWidget({
    super.key,
    required this.onAddStop,
  });

  @override
  State<AddStopDialogWidget> createState() => _AddStopDialogWidgetState();
}

class _AddStopDialogWidgetState extends State<AddStopDialogWidget> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  List<String> _selectedStudents = [];

  final List<String> _availableStudents = [
    'Emma Johnson',
    'Liam Smith',
    'Olivia Brown',
    'Noah Davis',
    'Ava Wilson',
    'William Miller',
    'Sophia Garcia',
    'James Rodriguez',
  ];

  List<String> _addressSuggestions = [];

  @override
  void initState() {
    super.initState();
    _addressController.addListener(_onAddressChanged);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onAddressChanged() {
    final query = _addressController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _addressSuggestions = [];
      });
      return;
    }

    // Mock address suggestions
    final suggestions = [
      '123 Oak Street, Springfield',
      '456 Maple Avenue, Springfield',
      '789 Pine Road, Springfield',
      '321 Elm Drive, Springfield',
      '654 Cedar Lane, Springfield',
    ].where((address) => address.toLowerCase().contains(query)).toList();

    setState(() {
      _addressSuggestions = suggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 90.w,
        constraints: BoxConstraints(maxHeight: 80.h),
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'add_location',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Add New Stop',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            // Address input with autocomplete
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Stop Address',
                    hintText: 'Enter address or tap on map',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'location_on',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                if (_addressSuggestions.isNotEmpty) ...[
                  SizedBox(height: 1.h),
                  Container(
                    constraints: BoxConstraints(maxHeight: 20.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _addressSuggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          dense: true,
                          leading: CustomIconWidget(
                            iconName: 'location_on',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                          title: Text(
                            _addressSuggestions[index],
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                          onTap: () {
                            _addressController.text =
                                _addressSuggestions[index];
                            setState(() {
                              _addressSuggestions = [];
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 2.h),
            // Time window input
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: 'Time Window',
                hintText: 'e.g., 8:00-8:05 AM',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'schedule',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            // Student selection
            Text(
              'Select Students',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              constraints: BoxConstraints(maxHeight: 20.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _availableStudents.length,
                itemBuilder: (context, index) {
                  final student = _availableStudents[index];
                  final isSelected = _selectedStudents.contains(student);

                  return CheckboxListTile(
                    dense: true,
                    value: isSelected,
                    title: Text(
                      student,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedStudents.add(student);
                        } else {
                          _selectedStudents.remove(student);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 2.h),
            // Notes input
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Special Instructions (Optional)',
                hintText: 'Enter any special notes for this stop...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'note',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 3.h),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canAddStop() ? _addStop : null,
                    child: Text('Add Stop'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _canAddStop() {
    return _addressController.text.isNotEmpty &&
        _timeController.text.isNotEmpty &&
        _selectedStudents.isNotEmpty;
  }

  void _addStop() {
    final newStop = {
      'address': _addressController.text,
      'timeWindow': _timeController.text,
      'students': _selectedStudents,
      'notes': _notesController.text,
      'status': 'pending',
      'mapX':
          0.3 + (DateTime.now().millisecond % 400) / 1000, // Random position
      'mapY':
          0.2 + (DateTime.now().millisecond % 600) / 1000, // Random position
    };

    widget.onAddStop(newStop);
    Navigator.pop(context);
  }
}
