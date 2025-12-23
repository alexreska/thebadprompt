import 'package:flutter/material.dart';
import '../../../../design_system/palette.dart';
import '../../../home/presentation/pages/landing_page.dart'; // Corrected path
import '../../../gallery/presentation/pages/gallery_page.dart';
import '../../../account/presentation/pages/account_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const LandingPage(),
    const AccountPage(),
    const GalleryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TbpPalette.lightBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(
          color: TbpPalette.periwinkle, // Request: #B0B4E1
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
                   label: 'HOME', 
                   index: 0,
                 ),
                 
                 // 2. ACCOUNT (White Logo)
                 _buildLogoNavItem(
                   label: 'ACCOUNT', 
                   index: 1,
                 ),
                 
                 // 3. GALLERY
                 _buildNavItem(
                   icon: Icons.grid_view, 
                   label: 'GALLERY', 
                   index: 2,
                 ),
               ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            color: isSelected ? TbpPalette.darkViolet : Colors.white.withValues(alpha: 0.6), // Violet if active, white dim if not
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
          // Using the white logo as requested
          Image.asset(
            'assets/logo_white.png',
            height: 28,
            width: 28,
            color: isSelected ? TbpPalette.darkViolet : null, // Tint violet if selected? Or keep white?
            // "instead of the icon account we use the logo white"
            // Usually logos shouldn't be tinted if they are "Logo White". 
            // BUT active state usually indicates selection.
            // If I leave it white, it might look inactive compared to the violet Home icon.
            // However, "logo white" implies the ASSET is white.
            // If I tint it Dark Violet when active, it becomes "Logo Violet".
            // I will NOT tint it for now, let it be the distinctive element.
            // Or maybe opacity change?
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
