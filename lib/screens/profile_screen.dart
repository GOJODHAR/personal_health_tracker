import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBackToDashboard;

  const ProfileScreen({super.key, this.onBackToDashboard});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String _selectedGender = 'Not set';
  TimeOfDay _notificationTime =  TimeOfDay(hour: 20, minute: 0);
  bool _isEditing = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Not set'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isEditing) {
      _loadProfileData();
    }
  }

  void _loadProfileData() {
    final user =
        Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _ageController.text = user.age > 0 ? '${user.age}' : '';
      _heightController.text =
          user.heightCm > 0 ? user.heightCm.toStringAsFixed(1) : '';
      _weightController.text =
          user.weightKg > 0 ? user.weightKg.toStringAsFixed(1) : '';
      _selectedGender = user.gender;
      _notificationTime =
          TimeOfDay(hour: user.notificationHour, minute: user.notificationMinute);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      gender: _selectedGender,
      heightCm: double.tryParse(_heightController.text.trim()) ?? 0,
      weightKg: double.tryParse(_weightController.text.trim()) ?? 0,
      notificationHour: _notificationTime.hour,
      notificationMinute: _notificationTime.minute,
    );

    if (success) {
      await NotificationService().cancelAll();
      await NotificationService().scheduleDailyReminder(
        hour: _notificationTime.hour,
        minute: _notificationTime.minute,
      );
    }

    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.error_outline,
                color: Colors.white,
                size: 20,
              ),
               SizedBox(width: 10),
              Text(
                success
                    ? 'Profile updated! ✨'
                    : authProvider.error ?? 'Update failed',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ],
          ),
          backgroundColor:
              success ? AppConstants.primaryColor : AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  Future<void> _handleLogout(AuthProvider auth) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        title: Text('Sign Out',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to sign out?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sign Out',
                style: GoogleFonts.poppins(color: AppConstants.errorColor)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await auth.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) =>  WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;

        return SafeArea(
          child: SingleChildScrollView(
            physics:  BouncingScrollPhysics(),
            padding:  EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              children: [
                // ── Header ──
                Row(
                  children: [
                    if (widget.onBackToDashboard != null)
                      GestureDetector(
                        onTap: widget.onBackToDashboard,
                        child: Container(
                          padding:  EdgeInsets.all(10),
                          margin:  EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset:  Offset(0, 2),
                              ),
                            ],
                          ),
                          child:  Icon(Icons.arrow_back_rounded,
                              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark), size: 20),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        'Profile Settings',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _handleLogout(authProvider),
                      child: Container(
                        padding:  EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset:  Offset(0, 2),
                            ),
                          ],
                        ),
                        child:  Icon(Icons.logout_rounded,
                            color: AppConstants.errorColor, size: 20),
                      ),
                    ),
                  ],
                ),
                 SizedBox(height: 28),

                // ── Avatar ──
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:  LinearGradient(
                      colors: [
                        AppConstants.gradientStart,
                        AppConstants.gradientEnd,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor
                            .withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset:  Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      (user?.name ?? 'U').isNotEmpty
                          ? (user?.name ?? 'U')[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                 SizedBox(height: 8),
                Text(
                  user?.email ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
                  ),
                ),
                 SizedBox(height: 24),

                // ── Actions Row ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Dark Mode Toggle
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return Container(
                          padding:  EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppConstants.primaryColor
                                  .withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                themeProvider.isDarkMode
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                color: AppConstants.primaryColor,
                                size: 18,
                              ),
                               SizedBox(width: 8),
                              SizedBox(
                                height: 24,
                                width: 40,
                                child: Switch(
                                  value: themeProvider.isDarkMode,
                                  onChanged: (val) =>
                                      themeProvider.toggleTheme(val),
                                    activeThumbColor: AppConstants.primaryColor,
                                    activeTrackColor: AppConstants.primaryColor.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                     SizedBox(width: 16),
                    // Edit Profile Toggle
                    GestureDetector(
                      onTap: () => setState(() => _isEditing = !_isEditing),
                      child: Container(
                        padding:  EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isEditing
                          ? AppConstants.primaryColor.withValues(alpha: 0.1)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppConstants.primaryColor
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isEditing
                              ? Icons.edit_off_rounded
                              : Icons.edit_rounded,
                          color: AppConstants.primaryColor,
                          size: 18,
                        ),
                         SizedBox(width: 8),
                        Text(
                          _isEditing ? 'Cancel Editing' : 'Edit Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
                 SizedBox(height: 24),

                // ── Form fields ──
                user == null
                    ? Center(
                        child: Column(
                          children: [
                             CircularProgressIndicator(
                                color: AppConstants.primaryColor),
                             SizedBox(height: 12),
                            Text('Loading profile...',
                                style: GoogleFonts.poppins(
                                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium))),
                          ],
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _nameController,
                              label: 'Name',
                              icon: Icons.person_outline_rounded,
                              color: AppConstants.primaryColor,
                              enabled: _isEditing,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Enter your name'
                                  : null,
                            ),
                             SizedBox(height: 14),
                            _buildTextField(
                              controller: _ageController,
                              label: 'Age',
                              icon: Icons.cake_outlined,
                              color: AppConstants.accentColor,
                              enabled: _isEditing,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Enter your age';
                                }
                                final age = int.tryParse(v.trim());
                                if (age == null || age < 1 || age > 120) {
                                  return 'Enter a valid age';
                                }
                                return null;
                              },
                            ),
                             SizedBox(height: 14),
                            _buildGenderSelector(),
                             SizedBox(height: 14),
                            _buildNotificationTimePicker(),
                             SizedBox(height: 14),
                            _buildTextField(
                              controller: _heightController,
                              label: 'Height (cm)',
                              icon: Icons.height_rounded,
                              color: AppConstants.secondaryColor,
                              enabled: _isEditing,
                              keyboardType:
                                   TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Enter height';
                                }
                                final h = double.tryParse(v.trim());
                                if (h == null || h < 50 || h > 300) {
                                  return 'Enter valid height (50-300)';
                                }
                                return null;
                              },
                            ),
                             SizedBox(height: 14),
                            _buildTextField(
                              controller: _weightController,
                              label: 'Weight (kg)',
                              icon: Icons.monitor_weight_outlined,
                              color: AppConstants.weightColor,
                              enabled: _isEditing,
                              keyboardType:
                                   TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Enter weight';
                                }
                                final w = double.tryParse(v.trim());
                                if (w == null || w < 10 || w > 500) {
                                  return 'Enter valid weight (10-500)';
                                }
                                return null;
                              },
                            ),
                             SizedBox(height: 28),

                            // ── Update Profile button ──
                            if (_isEditing)
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient:  LinearGradient(
                                      colors: [
                                        AppConstants.gradientStart,
                                        AppConstants.gradientEnd,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppConstants.primaryColor
                                            .withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset:  Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: authProvider.isLoading
                                        ? null
                                        : _saveProfile,
                                    icon: authProvider.isLoading
                                        ?  SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        :  Icon(
                                            Icons.check_circle_rounded,
                                            size: 20),
                                    label: Text(
                                      authProvider.isLoading
                                          ? 'Saving...'
                                          : 'Update Profile',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding:  EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                             SizedBox(height: 16),

                            // ── Sign out button ──
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _handleLogout(authProvider),
                                icon:  Icon(Icons.logout_rounded,
                                    size: 18,
                                    color: AppConstants.errorColor),
                                label: Text(
                                  'Sign Out',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: AppConstants.errorColor,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding:  EdgeInsets.symmetric(
                                      vertical: 14),
                                  side:  BorderSide(
                                      color: AppConstants.errorColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.borderRadius),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // INPUT FIELDS
  // ──────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    required bool enabled,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset:  Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: enabled ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark) : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
          ),
          prefixIcon: Container(
            margin:  EdgeInsets.all(10),
            padding:  EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          filled: true,
          fillColor: enabled
              ? Theme.of(context).cardColor
              : Theme.of(context).scaffoldBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppConstants.primaryColor.withValues(alpha: 0.15),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:  BorderSide(
              color: AppConstants.primaryColor,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:  BorderSide(
              color: AppConstants.errorColor,
            ),
          ),
          contentPadding:
               EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildNotificationTimePicker() {
    final timeLabel = _notificationTime.format(context);
    return GestureDetector(
      onTap: _isEditing
          ? () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _notificationTime,
              );
              if (picked != null) {
                setState(() => _notificationTime = picked);
              }
            }
          : null,
      child: Container(
        padding:  EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset:  Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: _isEditing
                ? AppConstants.primaryColor.withValues(alpha: 0.15)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              margin:  EdgeInsets.all(10),
              padding:  EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.sleepColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child:  Icon(Icons.notifications_outlined,
                  color: AppConstants.sleepColor, size: 18),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Reminder',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      timeLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _isEditing
                            ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark)
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isEditing)
              Padding(
                padding:  EdgeInsets.only(right: 12),
                child: Icon(Icons.edit_rounded,
                    color: AppConstants.primaryColor.withValues(alpha: 0.6),
                    size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset:  Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: _isEditing
              ? AppConstants.primaryColor.withValues(alpha: 0.15)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            margin:  EdgeInsets.all(10),
            padding:  EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.moodColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child:  Icon(Icons.wc_rounded,
                color: AppConstants.moodColor, size: 18),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gender',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
                  ),
                ),
                _isEditing
                    ? DropdownButton<String>(
                        value: _selectedGender,
                        isExpanded: true,
                        underline:  SizedBox(),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppConstants.textDark),
                        ),
                        items: _genderOptions
                            .map((g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(g),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedGender = val);
                          }
                        },
                      )
                    : Padding(
                        padding:  EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _selectedGender,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppConstants.textMedium),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
