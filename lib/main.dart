import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NoireApp());
}

// --- NOIRE COLOR PALETTE ---
class NoireColors {
  static const Color voidBlack = Color(0xFF050505); 
  static const Color surface = Color(0xFF121212);   
  static const Color gold = Color(0xFFFFD700);      
  static const Color mutedGold = Color(0xFFC5A028); 
  static const Color textMain = Color(0xFFEEEEEE);
  static const Color textDim = Color(0xFF666666);
}

class NoireApp extends StatelessWidget {
  const NoireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Noire Planner',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: NoireColors.voidBlack,
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: NoireColors.textMain,
          displayColor: NoireColors.textMain,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CollectionReference _tasksRef = FirebaseFirestore.instance.collection('tasks');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. AMBIENT GLOW
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: NoireColors.gold.withOpacity(0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // 2. MAIN CONTENT
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildDateStrip(),
                const SizedBox(height: 20),
                Expanded(child: _buildLiveTimelineList()),
              ],
            ),
          ),

          // 3. BOTTOM DOCK
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(child: _buildBottomDock()),
          ),
        ],
      ),
    );
  }

  // --- NEW: LIVE DATA LISTENER ---
  Widget _buildLiveTimelineList() {
    return StreamBuilder<QuerySnapshot>(
      // We listen to the 'tasks' collection sorted by time
      stream: _tasksRef.orderBy('time').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Hata oluştu"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: NoireColors.gold));
        }

        final data = snapshot.requireData;

        // If the database is empty, we show "No Operations"
        if (data.size == 0) {
          return Center(
            child: Text(
              "NO OPERATIONS SCHEDULED",
              style: GoogleFonts.cinzel(color: NoireColors.textDim, letterSpacing: 1),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 120),
          itemCount: data.size,
          itemBuilder: (context, index) {
            final doc = data.docs[index];
            final task = doc.data() as Map<String, dynamic>;
            
            // Icon name string to IconData
            IconData iconToUse = _getIconData(task['icon']);

            return _TimelineItem(
              docId: doc.id, // Güncelleme için ID lazım
              time: task['time'] ?? '--:--',
              title: task['title'] ?? '',
              desc: task['desc'] ?? '',
              icon: iconToUse,
              isActive: task['active'] ?? false,
            );
          },
        );
      },
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'shield': return Icons.shield_outlined;
      case 'code': return Icons.code;
      case 'sync': return Icons.sync;
      case 'design': return Icons.design_services_outlined;
      default: return Icons.circle_outlined;
    }
  }

  // --- HEADER, DATESTRIP AND DOCK ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("JANUARY 11, 2026", style: TextStyle(color: NoireColors.textDim, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("TODAY", style: GoogleFonts.cinzel(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: NoireColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NoireColors.gold.withOpacity(0.3)),
                ),
                child: const Icon(Icons.calendar_today, color: NoireColors.gold, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(border: Border(left: BorderSide(color: NoireColors.gold, width: 2))),
            child: Text("// EXECUTION MODE: LIVE", style: TextStyle(color: NoireColors.mutedGold, fontSize: 10, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStrip() {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return SizedBox(
      height: 85,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          bool isSelected = index == 6; 
          return _DateCard(day: days[index], date: "${5 + index}", isSelected: isSelected);
        },
      ),
    );
  }

  Widget _buildBottomDock() {
    return Container(
      height: 70, width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF151515).withOpacity(0.9),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(icon: const Icon(Icons.home_filled, color: NoireColors.gold), onPressed: () {}),
          GestureDetector(
            onTap: () {
              // NEW MISSION TEST
              _tasksRef.add({
                'title': 'New Protocol',
                'desc': 'Added via Backend',
                'time': '18:00',
                'active': false,
                'icon': 'shield'
              });
            },
            child: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: NoireColors.gold, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: NoireColors.gold.withOpacity(0.4), blurRadius: 15, spreadRadius: 1)],
              ),
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.grey), onPressed: () {}),
        ],
      ),
    );
  }
}

// --- WIDGET COMPONENTS ---

class _DateCard extends StatelessWidget {
  final String day; final String date; final bool isSelected;
  const _DateCard({required this.day, required this.date, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 55,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1A1A1A) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: NoireColors.gold.withOpacity(0.5), width: 1) : Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: isSelected ? [BoxShadow(color: NoireColors.gold.withOpacity(0.15), blurRadius: 12, spreadRadius: 0)] : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day, style: TextStyle(fontSize: 10, color: isSelected ? NoireColors.gold : Colors.grey)),
          const SizedBox(height: 4),
          Text(date, style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String docId;
  final String time; final String title; final String desc; final IconData icon; final bool isActive;

  const _TimelineItem({required this.docId, required this.time, required this.title, required this.desc, required this.icon, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 70,
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0, right: 12),
              child: Text(time, textAlign: TextAlign.right, style: TextStyle(color: isActive ? NoireColors.gold : NoireColors.textDim, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          SizedBox(
            width: 30,
            child: Stack(
              children: [
                Center(child: Container(width: 2, color: isActive ? const Color(0xFF332A00) : const Color(0xFF1A1A1A))),
                Positioned(
                  top: 24, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: NoireColors.voidBlack, shape: BoxShape.circle,
                        border: Border.all(color: isActive ? NoireColors.gold : Colors.grey.shade800, width: 2),
                        boxShadow: isActive ? [BoxShadow(color: NoireColors.gold.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)] : [],
                      ),
                      child: isActive ? Center(child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: NoireColors.gold, shape: BoxShape.circle))) : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0, right: 24, left: 8),
              child: GestureDetector(
                onTap: () {
                  FirebaseFirestore.instance.collection('tasks').doc(docId).update({'active': !isActive});
                },
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: isActive ? NoireColors.gold.withOpacity(0.05) : Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isActive ? NoireColors.gold.withOpacity(0.4) : Colors.white.withOpacity(0.05), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: isActive ? NoireColors.gold.withOpacity(0.2) : Colors.black, borderRadius: BorderRadius.circular(10)),
                          child: Icon(icon, color: isActive ? NoireColors.gold : Colors.grey, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(title, style: GoogleFonts.cinzel(color: isActive ? Colors.white : Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}