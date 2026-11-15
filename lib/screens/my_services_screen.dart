import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';
import 'package:nyumba_mtaani/entities/service_entity.dart';
import 'package:nyumba_mtaani/models/service_model.dart';
import 'package:nyumba_mtaani/providers/auth_provider.dart';
import 'package:nyumba_mtaani/providers/services_provider.dart';
import 'package:uuid/uuid.dart';

class MyServicesScreen extends ConsumerStatefulWidget {
  const MyServicesScreen({super.key});

  @override
  ConsumerState<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends ConsumerState<MyServicesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(servicesProvider.notifier).loadMyServices());
  }

  void _showAddServiceDialog(BuildContext context, [ServiceEntity? service]) {
    final nameController = TextEditingController(text: service?.name);
    final descController = TextEditingController(text: service?.description);
    final priceController = TextEditingController(text: service?.startingPrice?.toString());
    final areasController = TextEditingController(text: service?.serviceAreas.join(', '));
    final phoneController = TextEditingController(text: service?.phone);
    String selectedCategory = service?.category ?? 'Plumbing';
    File? pickedImage;

    final categories = ['Plumbing', 'Electrical', 'Cleaning', 'Security', 'Internet', 'Health', 'Moving', 'Painting', 'Carpentry'];
    final isWide = MediaQuery.of(context).size.width > 700;

    final form = StatefulBuilder(
      builder: (context, setModalState) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(service == null ? 'Add New Service' : 'Edit Service', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setModalState(() => pickedImage = File(image.path));
                    }
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: pickedImage != null ? FileImage(pickedImage!) : null,
                    child: pickedImage == null ? const Icon(Icons.add_a_photo, size: 30) : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: categories.contains(selectedCategory) ? selectedCategory : categories.first,
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setModalState(() => selectedCategory = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Business/Service Name')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Starting Price (KSh)'), keyboardType: TextInputType.number),
              TextField(controller: areasController, decoration: const InputDecoration(labelText: 'Service Areas (comma separated)')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Contact Phone')),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final user = ref.read(authProvider).user;
                    if (user == null) return;

                    final newService = ServiceModel(
                      id: service?.id ?? const Uuid().v4(),
                      providerId: user.id,
                      name: nameController.text,
                      category: selectedCategory,
                      description: descController.text,
                      serviceAreas: areasController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                      startingPrice: double.tryParse(priceController.text),
                      phone: phoneController.text,
                      profileImageUrl: service?.profileImageUrl,
                    );

                    bool success;
                    if (service == null) {
                      success = await ref.read(servicesProvider.notifier).addService(newService, pickedImage);
                    } else {
                      success = await ref.read(servicesProvider.notifier).updateService(newService);
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? 'Service saved!' : 'Failed to save service')),
                      );
                    }
                  },
                  child: const Text('Save Service'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );

    if (isWide) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: form,
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => form,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(servicesProvider);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(title: const Text('My Services')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.myServices.isEmpty
                  ? const EmptyStateWidget(
                      title: 'No services yet',
                      subtitle: 'Add your professional services to start getting jobs.',
                      icon: Icons.business_center_outlined,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.myServices.length,
                      itemBuilder: (context, index) {
                        final service = state.myServices[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: isWide ? 0 : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: service.profileImageUrl != null ? NetworkImage(service.profileImageUrl!) : null,
                              child: service.profileImageUrl == null ? const Icon(Icons.engineering) : null,
                            ),
                            title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${service.category} • ${service.serviceAreas.join(", ")}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit), onPressed: () => _showAddServiceDialog(context, service)),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => ref.read(servicesProvider.notifier).deleteService(service.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddServiceDialog(context),
        label: const Text('Add Service'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
