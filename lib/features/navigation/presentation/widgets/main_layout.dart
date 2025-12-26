import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/palette.dart';
import '../../../home/presentation/pages/landing_page.dart';
import '../../../gallery/presentation/pages/gallery_page.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../../collective_session/presentation/bloc/collective_session_bloc.dart';
import 'package:tbp_v2/l10n/app_localizations.dart'; // Added import

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    if (index == 0 && _currentIndex == 0) {
      // User tapped Home while on Home -> Go back to Lobby
      context.read<CollectiveSessionBloc>().add(LeaveSession());
    }
    setState(() {
      _currentIndex = index;
    });
  }



//...

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: TbpPalette.lightBackground,
      body: Stack(
        children: [
          // 1. HOME (Persisted to keep Bloc/Timer alive)
          Offstage(
            offstage: _currentIndex != 0,
            child: const LandingPage(),
          ),
          
          // 2. ACCOUNT (Recreated on visit)
          if (_currentIndex == 1) 
            const AccountPage(),
          
          // 3. GALLERY (Recreated on visit -> Triggers Auto-Refresh)
          if (_currentIndex == 2) 
            const GalleryPage(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(
          color: TbpPalette.periwinkle, 
        ),
        child: SafeArea(
          child: SizedBox(
            height: 70, 
            child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
               children: [
                 // 1. HOME
                 _buildNavItem(
                   icon: Icons.home, 
                   label: l10n.navHome, 
                   index: 0,
                 ),
                 
                 // 2. ACCOUNT (White Logo)
                 _buildLogoNavItem(
                   label: l10n.navAccount, 
                   index: 1,
                 ),
                 
                 // 3. GALLERY
                 _buildNavItem(
                   icon: Icons.grid_view, 
                   label: l10n.navGallery, 
                   index: 2,
                 ),
               ],
            ),
          ),
        ),
      ),
    );
  }

//...

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            color: isSelected ? TbpPalette.darkViolet : Colors.white.withValues(alpha: 0.6), 
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? TbpPalette.darkViolet : Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLogoNavItem({required String label, required int index}) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/logo_white.png',
            height: 28,
            width: 28,
            color: isSelected ? TbpPalette.darkViolet : null,
            colorBlendMode: isSelected ? BlendMode.modulate : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? TbpPalette.darkViolet : Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
