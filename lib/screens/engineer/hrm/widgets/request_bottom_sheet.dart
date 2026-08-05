import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/hrm_providers.dart';
import 'package:intl/intl.dart';

class RequestBottomSheet extends ConsumerStatefulWidget {
  const RequestBottomSheet({super.key});

  @override
  ConsumerState<RequestBottomSheet> createState() => _RequestBottomSheetState();
}

class _RequestBottomSheetState extends ConsumerState<RequestBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String _requestType = 'holiday'; // holiday, online, permission
  DateTime? _selectedDate;
  String _hours = '';
  String _reason = '';
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final hrmActions = ref.read(hrmActionsProvider);
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      if (_requestType == 'holiday') {
        await hrmActions.submitHolidayRequest(dateStr);
      } else if (_requestType == 'online') {
        await hrmActions.submitOnlineRequest(dateStr);
      } else if (_requestType == 'permission') {
        await hrmActions.submitPermissionRequest(dateStr, double.parse(_hours), _reason);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request submitted successfully')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Submit a Request', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildTypeButton('holiday', Icons.calendar_today, 'Holiday'),
                  const SizedBox(width: 8),
                  _buildTypeButton('online', Icons.language, 'Online'),
                  const SizedBox(width: 8),
                  _buildTypeButton('permission', Icons.access_time, 'Permission'),
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null ? 'Select Date' : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        style: TextStyle(fontSize: 16, color: _selectedDate == null ? Colors.grey : Theme.of(context).colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_requestType == 'permission') ...[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Hours Needed',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (double.tryParse(val) == null) return 'Invalid number';
                    return null;
                  },
                  onSaved: (val) => _hours = val ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Reason (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onSaved: (val) => _reason = val ?? '',
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String type, IconData icon, String label) {
    final isSelected = _requestType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _requestType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
            border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
