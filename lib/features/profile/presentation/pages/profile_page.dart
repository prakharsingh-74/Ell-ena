import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildProfileSection(
            title: 'Account Settings',
            children: [
              _buildProfileTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () {
                  // TODO: Implement edit profile
                },
              ),
              _buildProfileTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  // TODO: Implement notifications settings
                },
              ),
              _buildProfileTile(
                icon: Icons.lock_outline,
                title: 'Privacy & Security',
                onTap: () {
                  // TODO: Implement privacy settings
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProfileSection(
            title: 'Preferences',
            children: [
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, state) {
                  final isDarkMode =
                      state is ThemeInitial ? state.isDarkMode : false;
                  return _buildProfileTile(
                    icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    title: isDarkMode ? 'Dark Mode' : 'Light Mode',
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        context.read<ThemeBloc>().add(ToggleTheme());
                      },
                    ),
                  );
                },
              ),
              _buildProfileTile(
                icon: Icons.language,
                title: 'Language',
                onTap: () {
                  // TODO: Implement language selection
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProfileSection(
            title: 'Support',
            children: [
              _buildProfileTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                onTap: () {
                  // TODO: Implement help center
                },
              ),
              _buildProfileTile(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {
                  // TODO: Implement about page
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(
            'https://via.placeholder.com/150',
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'John Doe',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'john.doe@example.com',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () => _handleLogout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text('Logout'),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
