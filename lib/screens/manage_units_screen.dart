import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/entities/property_entity.dart';
import 'package:nyumba_mtaani/entities/property_unit_entity.dart';
import 'package:nyumba_mtaani/models/property_unit_model.dart';
import 'package:nyumba_mtaani/providers/property_management_provider.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';
import 'package:uuid/uuid.dart';

class ManageUnitsScreen extends ConsumerStatefulWidget {
  final PropertyEntity property;
  const ManageUnitsScreen({super.key, required this.property});

  @override
  ConsumerState<ManageUnitsScreen> createState() => _ManageUnitsScreenState();
}

class _ManageUnitsScreenState extends ConsumerState<ManageUnitsScreen> {
  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(propertyUnitsProvider(widget.property.id));
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Units - ${widget.property.title}'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: unitsAsync.when(
            data: (units) {
              if (units.isEmpty) {
                return const EmptyStateWidget(
                  title: 'No units added',
                  subtitle: 'Add individual units/apartments for this property.',
                  icon: Icons.meeting_room_outlined,
                );
              }

              if (isWide) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 450,
                    mainAxisExtent: 100,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: units.length,
                  itemBuilder: (context, index) => _buildUnitCard(units[index], isWide),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: units.length,
                itemBuilder: (context, index) => _buildUnitCard(units[index], isWide),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUnitDialog(),
        label: const Text('Add Unit'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUnitCard(PropertyUnitEntity unit, bool isWide) {
    return Card(
      margin: isWide ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      elevation: isWide ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
      ),
      child: ListTile(
        title: Text('Unit ${unit.unitNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Floor: ${unit.floor ?? "N/A"} • Price: KSh ${unit.price?.toInt() ?? widget.property.price.toInt()}'),
        trailing: _buildStatusChip(unit.status),
        onTap: () => _showUnitDialog(unit: unit),
      ),
    );
  }

  Widget _buildStatusChip(UnitStatus status) {
    Color color;
    switch (status) {
      case UnitStatus.vacant: color = Colors.green; break;
      case UnitStatus.occupied: color = Colors.blue; break;
      case UnitStatus.maintenance: color = Colors.orange; break;
      case UnitStatus.reserved: color = Colors.purple; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showUnitDialog({PropertyUnitEntity? unit}) {
    final isWide = MediaQuery.of(context).size.width > 700;

    final form = _UnitFormContent(
      unit: unit,
      propertyId: widget.property.id,
      onSave: (newUnit) async {
        bool success;
        if (unit == null) {
          success = await ref.read(propertyUnitsProvider(widget.property.id).notifier).addUnit(newUnit);
        } else {
          await ref.read(propertyUnitsProvider(widget.property.id).notifier).updateUnit(newUnit);
          success = true;
        }

        if (mounted) {
          Navigator.pop(context);
          if (!success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save unit')));
          }
        }
      },
    );

    if (isWide) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
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
}

class _UnitFormContent extends StatefulWidget {
  final PropertyUnitEntity? unit;
  final String propertyId;
  final Function(PropertyUnitModel) onSave;

  const _UnitFormContent({
    this.unit,
    required this.propertyId,
    required this.onSave,
  });

  @override
  State<_UnitFormContent> createState() => _UnitFormContentState();
}

class _UnitFormContentState extends State<_UnitFormContent> {
  late final TextEditingController numberController;
  late final TextEditingController floorController;
  late final TextEditingController priceController;
  late UnitStatus selectedStatus;

  @override
  void initState() {
    super.initState();
    numberController = TextEditingController(text: widget.unit?.unitNumber);
    floorController = TextEditingController(text: widget.unit?.floor);
    priceController = TextEditingController(text: widget.unit?.price?.toString());
    selectedStatus = widget.unit?.status ?? UnitStatus.vacant;
  }

  @override
  void dispose() {
    numberController.dispose();
    floorController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.unit == null ? 'Add Unit' : 'Edit Unit', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: numberController, decoration: const InputDecoration(labelText: 'Unit Number/Name (e.g. A1)')),
            TextField(controller: floorController, decoration: const InputDecoration(labelText: 'Floor')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price (KSh)'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            DropdownButtonFormField<UnitStatus>(
              initialValue: selectedStatus,
              items: UnitStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => selectedStatus = v!),
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (numberController.text.isEmpty) return;
                  final newUnit = PropertyUnitModel(
                    id: widget.unit?.id ?? const Uuid().v4(),
                    propertyId: widget.propertyId,
                    unitNumber: numberController.text,
                    floor: floorController.text,
                    price: double.tryParse(priceController.text),
                    status: selectedStatus,
                  );
                  widget.onSave(newUnit);
                },
                child: const Text('Save Unit'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
