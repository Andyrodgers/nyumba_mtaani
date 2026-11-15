import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nyumba_mtaani/entities/property_entity.dart';
import 'package:nyumba_mtaani/models/property_model.dart';
import 'package:nyumba_mtaani/providers/property_management_provider.dart';

class EditPropertyScreen extends ConsumerStatefulWidget {
  final PropertyEntity property;
  const EditPropertyScreen({super.key, required this.property});

  @override
  ConsumerState<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends ConsumerState<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _bedroomsController;
  late final TextEditingController _bathroomsController;
  
  late String _propertyType;
  late String _listingPurpose;
  late String _status;
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.property.title);
    _priceController = TextEditingController(text: widget.property.price.toString());
    _descriptionController = TextEditingController(text: widget.property.description);
    _locationController = TextEditingController(text: widget.property.locationText);
    _bedroomsController = TextEditingController(text: widget.property.bedrooms?.toString() ?? '');
    _bathroomsController = TextEditingController(text: widget.property.bathrooms?.toString() ?? '');
    _propertyType = widget.property.propertyType;
    _listingPurpose = widget.property.listingPurpose;
    _status = widget.property.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedProperty = PropertyModel(
      id: widget.property.id,
      title: _titleController.text,
      slug: widget.property.slug,
      propertyType: _propertyType,
      listingPurpose: _listingPurpose,
      price: double.parse(_priceController.text),
      bedrooms: int.tryParse(_bedroomsController.text),
      bathrooms: int.tryParse(_bathroomsController.text),
      description: _descriptionController.text,
      status: _status,
      locationText: _locationController.text,
      createdAt: widget.property.createdAt,
      ownerId: widget.property.ownerId,
      coverImageUrl: widget.property.coverImageUrl,
      features: widget.property.features,
    );

    await ref.read(propertyManagementProvider.notifier).updateProperty(updatedProperty);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property updated successfully')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Property'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showDeleteDialog(context),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
                children: [
                  _buildFormCard(
                    isWide: isWide,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        items: ['draft', 'pending', 'published', 'sold', 'rented']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())))
                            .toList(),
                        onChanged: (v) => setState(() => _status = v!),
                        decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFormCard(
                    isWide: isWide,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _propertyType,
                              items: ['Apartment', 'House', 'Commercial', 'Land']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => _propertyType = v!),
                              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _listingPurpose,
                              items: ['For Rent', 'For Sale']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (v) => setState(() => _listingPurpose = v!),
                              decoration: const InputDecoration(labelText: 'Purpose', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFormCard(
                    isWide: isWide,
                    children: [
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                        maxLines: 5,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard({required bool isWide, required List<Widget> children}) {
    return Card(
      elevation: isWide ? 0 : null,
      shape: isWide
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    
    final dialog = AlertDialog(
      title: const Text('Delete Listing?'),
      content: const SingleChildScrollView(child: Text('This action cannot be undone. All property data will be removed.')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            await ref.read(propertyManagementProvider.notifier).deleteProperty(widget.property.id);
            if (context.mounted) {
              Navigator.pop(context); // dialog
              context.pop(); // screen
            }
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => isWide
          ? Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400), child: dialog))
          : dialog,
    );
  }
}
