import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/local/food_dataset.dart';
import '../../../data/local/isar_service.dart';
import '../../../data/local/entities/food_log.dart';

// Import the provider or redefine if not globally available
final isarProvider = Provider((ref) => IsarService());

class AddMealScreen extends ConsumerStatefulWidget {
  const AddMealScreen({super.key});

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  FoodItem? _selectedItem;
  File? _image;
  bool _isRecognizing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _saveMeal() async {
    if (_selectedItem == null) return;

    final newLog = FoodLog()
      ..foodName = _selectedItem!.name
      ..calories = _selectedItem!.calories
      ..protein = _selectedItem!.protein
      ..timestamp = DateTime.now(); // Image might have older timestamp? For now, use current.

    await ref.read(isarProvider).addFoodLog(newLog);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Meal Added!")));
      Navigator.pop(context); // Go back
    }
  }

  Future<void> _pickImage() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
        _isRecognizing = true;
      });

      // Simulate recognition delay
      await Future.delayed(const Duration(seconds: 2));

      // Simulate match
      final result = FoodDataset.recognizeFromImage();

      setState(() {
        _selectedItem = result;
        _isRecognizing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Meal 🥗"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Text Search"),
            Tab(text: "Scan Camera"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTextSearchTab(),
          _buildCameraTab(),
        ],
      ),
    );
  }

  Widget _buildTextSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }
              return FoodDataset.getMatchingNames(textEditingValue.text);
            },
            onSelected: (String selection) {
              setState(() {
                _selectedItem = FoodDataset.getByName(selection);
              });
            },
            fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                onEditingComplete: onEditingComplete,
                decoration: const InputDecoration(
                  labelText: "Search for food (e.g. Dosa)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          if (_selectedItem != null) _buildNutrientCard(_selectedItem!),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedItem == null ? null : _saveMeal,
              child: const Text("Add Meal"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _image == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Tap to take photo"),
                      ],
                    )
                  : Image.file(_image!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          if (_isRecognizing)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text("Analyzing food..."),
              ],
            )
          else if (_selectedItem != null)
            Column(
              children: [
                 const Text("Recognized:", style: TextStyle(fontWeight: FontWeight.bold)),
                _buildNutrientCard(_selectedItem!),
                 const SizedBox(height: 20),
                 SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveMeal,
                    child: const Text("Confirm & Add"),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNutrientCard(FoodItem item) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(item.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [
                  Text("${item.calories.toInt()}", style: const TextStyle(fontSize: 18, color: Colors.orange)),
                  const Text("Calories"),
                ]),
                Column(children: [
                  Text("${item.protein}", style: const TextStyle(fontSize: 18, color: Colors.blue)),
                  const Text("Protein (g)"),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
