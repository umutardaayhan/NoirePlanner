import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('tasks');
  runApp(const NoireApp());
}

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
  final _tasksBox = Hive.box('tasks');
  DateTime _selectedDate = DateTime.now();

  String _formatDateId(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getDayName(int weekday) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }

  void _showAddTaskSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TimeOfDay selectedTimeOfDay = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    top: 20, left: 24, right: 24),
                decoration: BoxDecoration(
                  color: NoireColors.voidBlack.withOpacity(0.9),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  border: Border(top: BorderSide(color: NoireColors.gold.withOpacity(0.3), width: 1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 20),
                    Text("NEW PROTOCOL", style: GoogleFonts.cinzel(color: NoireColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Task Title",
                        hintStyle: const TextStyle(color: NoireColors.textDim),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Description",
                        hintStyle: const TextStyle(color: NoireColors.textDim),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTimeOfDay,
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: NoireColors.gold,
                                  onPrimary: Colors.black,
                                  surface: NoireColors.surface,
                                  onSurface: NoireColors.textMain,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != selectedTimeOfDay) {
                          setModalState(() {
                            selectedTimeOfDay = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: NoireColors.gold),
                            const SizedBox(width: 10),
                            Text(
                              "${selectedTimeOfDay.hour.toString().padLeft(2, '0')}:${selectedTimeOfDay.minute.toString().padLeft(2, '0')}",
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            const Text("Tap to change", style: TextStyle(color: NoireColors.textDim, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NoireColors.gold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
                            String formattedTime = "${selectedTimeOfDay.hour.toString().padLeft(2, '0')}:${selectedTimeOfDay.minute.toString().padLeft(2, '0')}";
                            
                            _tasksBox.add({
                              'title': titleController.text,
                              'desc': descController.text.isEmpty ? 'No Description' : descController.text,
                              'time': formattedTime,
                              'active': false,
                              'icon': 'shield',
                              'date': _formatDateId(_selectedDate),
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("INITIATE PROTOCOL", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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

  Widget _buildHeader() {
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    String formattedDate = "${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formattedDate, style: const TextStyle(color: NoireColors.textDim, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isSameDay(_selectedDate, DateTime.now()) ? "TODAY" : _getDayName(_selectedDate.weekday),
                style: GoogleFonts.cinzel(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: NoireColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NoireColors.gold.withOpacity(0.3)),
                ),
                child: const Icon(Icons.storage, color: NoireColors.gold, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(border: Border(left: BorderSide(color: NoireColors.gold, width: 2))),
            child: const Text("// SYSTEM: LOCAL STORAGE", style: TextStyle(color: NoireColors.mutedGold, fontSize: 10, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStrip() {
    return SizedBox(
      height: 85,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          bool isSelected = isSameDay(date, _selectedDate);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: _DateCard(
              day: _getDayName(date.weekday),
              date: date.day.toString(),
              isSelected: isSelected,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveTimelineList() {
    String targetDate = _formatDateId(_selectedDate);

    return ValueListenableBuilder(
      valueListenable: _tasksBox.listenable(),
      builder: (context, Box box, _) {
        final allTasks = box.toMap(); 
        
        final dailyEntries = allTasks.entries.where((entry) {
          final task = Map<String, dynamic>.from(entry.value);
          return task['date'] == targetDate;
        }).toList();

        dailyEntries.sort((a, b) {
          final taskA = Map<String, dynamic>.from(a.value);
          final taskB = Map<String, dynamic>.from(b.value);
          return (taskA['time'] as String).compareTo(taskB['time'] as String);
        });

        if (dailyEntries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_as_outlined, color: NoireColors.gold.withOpacity(0.3), size: 40),
                const SizedBox(height: 10),
                Text("LOCAL DATA EMPTY", style: GoogleFonts.cinzel(color: NoireColors.textDim, letterSpacing: 1)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 120),
          itemCount: dailyEntries.length,
          itemBuilder: (context, index) {
            final entry = dailyEntries[index];
            final key = entry.key;
            final task = Map<String, dynamic>.from(entry.value);
            IconData iconToUse = _getIconData(task['icon']);

            return Dismissible(
              key: Key(key.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.red.shade900.withOpacity(0.5),
                child: const Icon(Icons.delete_forever, color: Colors.white, size: 32),
              ),
              onDismissed: (direction) {
                _tasksBox.delete(key);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${task['title']} deleted from disk.", style: GoogleFonts.montserrat(color: Colors.black)),
                    backgroundColor: NoireColors.gold,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: _TimelineItem(
                keyId: key,
                time: task['time'] ?? '--:--',
                title: task['title'] ?? '',
                desc: task['desc'] ?? '',
                icon: iconToUse,
                isActive: task['active'] ?? false,
                onToggle: () {
                   task['active'] = !task['active'];
                   _tasksBox.put(key, task);
                },
              ),
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
              _showAddTaskSheet();
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
  final dynamic keyId;
  final String time; final String title; final String desc; final IconData icon; final bool isActive;
  final VoidCallback onToggle;

  const _TimelineItem({required this.keyId, required this.time, required this.title, required this.desc, required this.icon, required this.isActive, required this.onToggle});

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
                onTap: onToggle,
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