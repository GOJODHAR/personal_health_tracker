import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/health_provider.dart';
import '../utils/constants.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  String _selectedType = 'Running';

  final List<Map<String, dynamic>> _workoutTypes = [
    {'name': 'Running', 'icon': Icons.directions_run_rounded},
    {'name': 'Gym', 'icon': Icons.fitness_center_rounded},
    {'name': 'Cycling', 'icon': Icons.directions_bike_rounded},
    {'name': 'Yoga', 'icon': Icons.self_improvement_rounded},
    {'name': 'Walking', 'icon': Icons.directions_walk_rounded},
  ];

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ap = Provider.of<AuthProvider>(context, listen: false);
    final hp = Provider.of<HealthProvider>(context, listen: false);

    if (ap.currentUserId == null) return;

    final duration = int.tryParse(_durationController.text.trim()) ?? 0;
    final calories = int.tryParse(_caloriesController.text.trim()) ?? 0;

    final success = await hp.updateWorkoutForToday(
      userId: ap.currentUserId!,
      type: _selectedType,
      duration: duration,
      calories: calories,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workout logged successfully!', style: GoogleFonts.poppins()),
            backgroundColor: AppConstants.primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hp.error ?? 'Failed to add workout', style: GoogleFonts.poppins()),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Log Workout'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What did you do today?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                ),
              ),
              const SizedBox(height: 20),
              // Dropdown
              Container(
                decoration: BoxDecoration(color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: _workoutTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['name'],
                      child: Row(
                        children: [
                          Icon(type['icon'], color: AppConstants.primaryColor),
                          const SizedBox(width: 12),
                          Text(type['name'], style: GoogleFonts.poppins()),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Duration
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter duration';
                  if (int.tryParse(val) == null || int.parse(val) <= 0) return 'Valid duration in info';
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Duration (minutes)',
                  prefixIcon: const Icon(Icons.timer_outlined, color: AppConstants.primaryColor),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              // Calories
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Calories Burned (optional)',
                  prefixIcon: const Icon(Icons.local_fire_department_outlined, color: AppConstants.energyColor),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: Consumer<HealthProvider>(
                  builder: (context, hp, _) {
                    return FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: hp.isLoading ? null : _submit,
                      child: hp.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Workout'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
