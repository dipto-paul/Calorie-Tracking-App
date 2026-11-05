import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/food_item.dart';
import '../widgets/summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int dailyGoal = 2000;

  // Local list to store food items (resets when app restarts).
  final List<FoodItem> _foods = [];

  int get _totalCalories => _foods.fold(0, (sum, f) => sum + f.calories);
  int get _remaining => dailyGoal - _totalCalories;

  void _addFood(FoodItem item) {
    setState(() => _foods.add(item));
  }

  void _deleteFood(int index) {
    setState(() => _foods.removeAt(index));
  }

  Future<void> _showAddFoodDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final calorieController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Food'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Food Name',
                    prefixIcon: Icon(Icons.restaurant),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Food name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: calorieController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calories (kcal)',
                    prefixIcon: Icon(Icons.local_fire_department),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Calorie amount is required';
                    }
                    final cal = double.tryParse(value.trim());
                    if (cal == null) return 'Enter a valid number';
                    if (cal <= 0) return 'Calories must be greater than 0';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _addFood(
                    FoodItem(
                      name: nameController.text.trim(),
                      calories:
                          double.parse(calorieController.text.trim()).round(),
                    ),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    calorieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());
    final exceeded = _remaining < 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Calorie Tracker')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFoodDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Food'),
      ),
      body: Column(
        children: [
          // Today's date
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(
                  today,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // Summary cards: Total / Goal / Remaining
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Total Calories',
                    value: '$_totalCalories',
                    icon: Icons.local_fire_department,
                    color: Colors.orange.shade700,
                  ),
                ),
                Expanded(
                  child: SummaryCard(
                    title: 'Daily Goal',
                    value: '$dailyGoal',
                    icon: Icons.flag,
                    color: Colors.blue.shade700,
                  ),
                ),
                Expanded(
                  child: SummaryCard(
                    title: exceeded ? 'Over Goal' : 'Remaining Calories',
                    value: '${_remaining.abs()}',
                    icon: exceeded ? Icons.warning_amber : Icons.check_circle,
                    color:
                        exceeded ? Colors.red.shade700 : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (_totalCalories / dailyGoal).clamp(0.0, 1.0),
                minHeight: 10,
                color: exceeded ? Colors.red : Colors.green,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Food List (${_foods.length})',
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Food list
          Expanded(
            child: _foods.isEmpty
                ? const Center(
                    child: Text(
                      'No food added yet.\nTap "Add Food" to start.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: _foods.length,
                    itemBuilder: (context, index) {
                      final food = _foods[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade50,
                            child: Icon(Icons.fastfood,
                                color: Colors.green.shade700),
                          ),
                          title: Text(
                            food.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${food.calories} kcal'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete',
                            onPressed: () => _deleteFood(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
