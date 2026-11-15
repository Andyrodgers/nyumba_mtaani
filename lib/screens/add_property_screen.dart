import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nyumba_mtaani/models/property_model.dart';
import 'package:nyumba_mtaani/providers/auth_provider.dart';
import 'package:nyumba_mtaani/providers/property_management_provider.dart';
import 'package:uuid/uuid.dart';

class AddPropertyScreen extends ConsumerStatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  ConsumerState<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  
  // Controllers
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _sizeController = TextEditingController();
  
  String _propertyType = 'Apartment';
  String _listingPurpose = 'Rent';
  final List<File> _selectedImages = [];
  final List<File> _selectedVideos = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedVideos.add(File(video.path));
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    final authState = ref.read(authProvider);
    final userId = authState.user?.id;

    final property = PropertyModel(
      id: const Uuid().v4(),
      title: _titleController.text,
      slug: _titleController.text.toLowerCase().replaceAll(' ', '-'),
      propertyType: _propertyType,
      listingPurpose: _listingPurpose.toLowerCase(),
      price: double.parse(_priceController.text),
      bedrooms: int.tryParse(_bedroomsController.text),
      bathrooms: int.tryParse(_bathroomsController.text),
      sizeSqm: double.tryParse(_sizeController.text),
      description: _descriptionController.text,
      status: 'pending',
      locationText: _locationController.text,
      createdAt: DateTime.now(),
      ownerId: userId,
    );

    await ref.read(propertyManagementProvider.notifier).createProperty(property, _selectedImages);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Available Property'),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Form(
            key: _formKey,
            child: Stepper(
              type: isWide ? StepperType.horizontal : StepperType.vertical,
              physics: const ClampingScrollPhysics(),
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 2) {
                  setState(() => _currentStep++);
                } else {
                  _submit();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              steps: [
                Step(
                  title: const Text('Basic Info'),
                  isActive: _currentStep >= 0,
                  content: Card(
                    elevation: isWide ? 0 : null,
                    shape: isWide ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)) : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(labelText: 'Listing Title', border: OutlineInputBorder()),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _listingPurpose,
                            items: const [
                              DropdownMenuItem(value: 'Rent', child: Text('Rent')),
                              DropdownMenuItem(value: 'Buy', child: Text('Buy')),
                              DropdownMenuItem(value: 'Lease', child: Text('Lease')),
                            ],
                            onChanged: (v) => setState(() => _listingPurpose = v!),
                            decoration: const InputDecoration(labelText: 'Listing Purpose', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _propertyType,
                            items: const [
                              DropdownMenuItem(value: 'Apartment', child: Text('Apartment')),
                              DropdownMenuItem(value: 'House', child: Text('House')),
                              DropdownMenuItem(value: 'Commercial', child: Text('Commercial')),
                              DropdownMenuItem(value: 'Land', child: Text('Land')),
                              DropdownMenuItem(value: 'Office', child: Text('Office')),
                            ],
                            onChanged: (v) => setState(() => _propertyType = v!),
                            decoration: const InputDecoration(labelText: 'Property Type', border: OutlineInputBorder()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Step(
                  title: const Text('Details & Price'),
                  isActive: _currentStep >= 1,
                  content: Card(
                    elevation: isWide ? 0 : null,
                    shape: isWide ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)) : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(labelText: 'Price (KES)', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(labelText: 'Exact Location', border: OutlineInputBorder()),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _bedroomsController,
                                  decoration: const InputDecoration(labelText: 'Bedrooms', border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _bathroomsController,
                                  decoration: const InputDecoration(labelText: 'Bathrooms', border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Step(
                  title: const Text('Media'),
                  isActive: _currentStep >= 2,
                  content: Card(
                    elevation: isWide ? 0 : null,
                    shape: isWide ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)) : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(labelText: 'Property Description', border: OutlineInputBorder()),
                            maxLines: 4,
                          ),
                          const SizedBox(height: 20),
                          const Text('Photos & Videos', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _pickImages,
                                  icon: const Icon(Icons.add_a_photo),
                                  label: const Text('Photos'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _pickVideo,
                                  icon: const Icon(Icons.video_library),
                                  label: const Text('Video'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_selectedImages.isNotEmpty) ...[
                            SizedBox(
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(_selectedImages[index], width: 80, height: 80, fit: BoxFit.cover),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: GestureDetector(
                                            onTap: () => setState(() => _selectedImages.removeAt(index)),
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
