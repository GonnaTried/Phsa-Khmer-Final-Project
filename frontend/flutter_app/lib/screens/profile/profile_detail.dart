import 'package:flutter/material.dart';
import 'package:flutter_app/models/user_profile.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/services/token_service.dart';
import 'package:flutter_app/utils/app_constants.dart';
import 'package:flutter_app/utils/navigation_utils.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:flutter_app/widgets/custom_input_box.dart';

// Convert to StatefulWidget to manage controllers and the future initialization
class ProfileDetail extends StatefulWidget {
  const ProfileDetail({super.key});

  @override
  State<ProfileDetail> createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetail> {
  // Services
  late final AuthService _authService;

  // Future to hold the profile data loading state
  late Future<UserProfile?> _profileFuture;

  // Controllers for editable fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  UserProfile? _currentProfile;

  @override
  void initState() {
    super.initState();
    // Initialize services
    final tokenService = TokenService();
    _authService = AuthService(tokenService);

    // Start fetching the profile data immediately
    _profileFuture = _fetchProfileData();
  }

  Future<UserProfile?> _fetchProfileData() async {
    final profile = await _authService.fetchUserProfile();
    if (profile != null) {
      _currentProfile = profile;
      // Populate controllers with fetched data
      _firstNameController.text = profile.firstName ?? '';
      _lastNameController.text = profile.lastName ?? '';
      _phoneNumberController.text = profile.phoneNumber ?? '';
    }
    return profile;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final updatedProfile = await _authService.updateUserProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phoneNumber: _phoneNumberController.text,
    );

    if (!mounted) {
      return;
    }
    if (updatedProfile != null) {
      setState(() {
        _currentProfile = updatedProfile;
      });
      NavigationUtils.showAppSnackbar(context, "Update Profile Sccessfully");
    } else {
      NavigationUtils.showAppSnackbar(
        context,
        "Update Profile Failed",
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        titleText: "Profile Detail",
        automaticallyImplyLeading: true,
      ),
      body: FutureBuilder<UserProfile?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading profile: ${snapshot.error}'),
            );
          }

          final UserProfile? userProfile = snapshot.data;

          if (userProfile == null) {
            return const Center(child: Text('Failed to load user profile.'));
          }

          return Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.kMaxContentWidth,
              ),
              padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomInputBox(
                      title: "Telegram Username",
                      placeholder: userProfile.telegramUsername ?? 'N/A',
                      initialValue: userProfile.telegramUsername,
                      enabled: false,
                    ),
                    AppSpaces.largeDivider,

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomInputBox(
                            title: "First Name",
                            description: "Other User Will See",
                            controller: _firstNameController,
                          ),
                        ),
                        AppSpaces.mediumHorizontal,
                        Expanded(
                          child: CustomInputBox(
                            title: "Last Name",
                            description: "Other User Will See",
                            controller: _lastNameController,
                          ),
                        ),
                      ],
                    ),
                    AppSpaces.largeDivider,

                    CustomInputBox(
                      title: "Phone Number",
                      description:
                          "Only Delivery Man Will See | Cambodia Phone Number | +855",
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                    ),

                    AppSpaces.largeDivider,

                    CustomButton(text: "Save Changes", onPressed: _saveChanges),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
