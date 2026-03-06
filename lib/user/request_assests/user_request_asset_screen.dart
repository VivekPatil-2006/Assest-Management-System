import 'package:assest_management_system/user/request_assests/services/user_request_asset_service.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../shared_widgets/user_drawer.dart';

class UserRequestAssetScreen extends StatefulWidget {
  const UserRequestAssetScreen({super.key});

  @override
  State<UserRequestAssetScreen> createState() => _UserRequestAssetScreenState();
}

class _UserRequestAssetScreenState extends State<UserRequestAssetScreen> {
  final _formKey = GlobalKey<FormState>();

  final _assetIdCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _deskCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _swapAssetCtrl = TextEditingController();

  bool _loading = false;
  bool _locationsLoading = false;
  String? _error;

  List<UserLocation> _locations = [];
  String? _selectedLocationId;
  DateTime? _startDate;
  String _requestType = 'new_request';

  String? _prefilledAssetId;
  String? _prefilledAssetName;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final assetId = (args['assetId'] ?? '').toString();
      final assetName = (args['assetName'] ?? '').toString();

      if (assetId.isNotEmpty && _prefilledAssetId == null) {
        _prefilledAssetId = assetId;
        _prefilledAssetName = assetName.isEmpty ? null : assetName;
      }
    }
  }

  @override
  void dispose() {
    _assetIdCtrl.dispose();
    _reasonCtrl.dispose();
    _deskCtrl.dispose();
    _durationCtrl.dispose();
    _swapAssetCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    setState(() {
      _locationsLoading = true;
      _error = null;
    });

    try {
      final data = await UserRequestAssetService.fetchLocations();

      if (!mounted) return;
      setState(() {
        _locations = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _locationsLoading = false);
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final initial = _startDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked == null) return;

    setState(() {
      _startDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocationId == null || _selectedLocationId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return;
    }
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a start date')),
      );
      return;
    }

    final effectiveAssetId = (_prefilledAssetId ?? '').isNotEmpty
        ? _prefilledAssetId!
        : _assetIdCtrl.text.trim();

    if (effectiveAssetId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asset ID is required')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final message = await UserRequestAssetService.createRequest(
        CreateAssetRequestPayload(
          assetId: effectiveAssetId,
          labId: _selectedLocationId!,
          duration: _durationCtrl.text.trim(),
          startDate: _startDate!,
          requestType: _requestType,
          reason: _reasonCtrl.text.trim(),
          deskLocation: _deskCtrl.text.trim(),
          swapWithAssetId: _requestType == 'swap_request'
              ? _swapAssetCtrl.text.trim()
              : null,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      Navigator.pushReplacementNamed(context, '/userMyRequests');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const UserDrawer(currentRoute: '/userRequestAsset'),
      appBar: AppBar(
        title: const Text('Request Asset'),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadLocations,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            if (_error != null) _errorCard(_error!),
            if (_locationsLoading)
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              _formCard(),
          ],
        ),
      ),
    );
  }

  Widget _formCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              Row(
                children: [
                  const Icon(Icons.inventory_2, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    "Asset Request Form",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if ((_prefilledAssetId ?? '').isNotEmpty) ...[
                _assetInfoTile(Icons.devices, 'Asset', _prefilledAssetName ?? _prefilledAssetId!),
                _assetInfoTile(Icons.qr_code, 'Asset ID', _prefilledAssetId!),
                const SizedBox(height: 10),
              ] else ...[
                _inputField(
                  controller: _assetIdCtrl,
                  label: "Asset ID *",
                  icon: Icons.qr_code,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Asset ID is required'
                      : null,
                ),
                const SizedBox(height: 12),
              ],

              /// REQUEST TYPE
              _dropdownField(
                icon: Icons.swap_horiz,
                label: "Request Type",
                value: _requestType,
                items: const [
                  DropdownMenuItem(value: 'new_request', child: Text('New Request')),
                  DropdownMenuItem(value: 'swap_request', child: Text('Swap Request')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _requestType = v);
                },
              ),

              const SizedBox(height: 12),

              /// LOCATION
              _dropdownField(
                icon: Icons.location_on,
                label: "Location *",
                value: _selectedLocationId,
                items: _locations
                    .map((loc) =>
                    DropdownMenuItem(value: loc.id, child: Text(loc.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedLocationId = v),
              ),

              const SizedBox(height: 12),

              _inputField(
                controller: _durationCtrl,
                label: "Duration (ex: 15 days) *",
                icon: Icons.schedule,
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Duration is required' : null,
              ),

              const SizedBox(height: 12),

              /// DATE PICKER
              InkWell(
                onTap: _pickStartDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Start Date *',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _startDate == null
                        ? 'Select date'
                        : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _inputField(
                controller: _deskCtrl,
                label: "Desk Location",
                icon: Icons.desk,
              ),

              const SizedBox(height: 12),

              _inputField(
                controller: _reasonCtrl,
                label: "Reason",
                icon: Icons.description,
                maxLines: 3,
              ),

              if (_requestType == 'swap_request') ...[
                const SizedBox(height: 12),
                _inputField(
                  controller: _swapAssetCtrl,
                  label: "Swap With Asset ID *",
                  icon: Icons.swap_calls,
                  validator: (v) {
                    if (_requestType == 'swap_request' &&
                        (v == null || v.trim().isEmpty)) {
                      return 'Swap asset ID required';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 20),

              /// SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: _loading
                      ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Icon(Icons.send),
                  label: Text(_loading ? 'Submitting...' : 'Submit Request'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _assetInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: $value",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyTile(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _errorCard(String message) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            TextButton(onPressed: _loadLocations, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}