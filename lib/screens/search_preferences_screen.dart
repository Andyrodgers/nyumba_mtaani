import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';
import 'package:nyumba_mtaani/core/constants/kenya_counties.dart';

class SearchPreferencesScreen extends ConsumerStatefulWidget {
  const SearchPreferencesScreen({super.key});

  @override
  ConsumerState<SearchPreferencesScreen> createState() => _SearchPreferencesScreenState();
}

class _SearchPreferencesScreenState extends ConsumerState<SearchPreferencesScreen> {
  final List<String> _selectedCounties = [];
  RangeValues _priceRange = const RangeValues(0, 500000);
  final List<String> _propertyTypes = ['Apartment', 'House', 'Studio', 'Office', 'Land'];
  final List<String> _selectedTypes = [];
  int _minBedrooms = 0;
  bool _mustHaveParking = false;
  bool _mustHaveSecurity = false;
  bool _mustHaveInternet = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SharedHeader(
            title: 'Preferences',
            subtitle: 'Search Criteria',
            showSearchBar: false,
            showBackButton: true,
            showGreeting: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Target Locations'),
                  Wrap(
                    spacing: 8,
                    children: _selectedCounties.map((county) => Chip(
                      label: Text(county),
                      onDeleted: () => setState(() => _selectedCounties.remove(county)),
                    )).toList(),
                  ),
                  TextButton.icon(
                    onPressed: _showCountyPicker,
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text('Add County'),
                  ),
                  
                  const Divider(height: 32),
                  _buildSectionTitle('Price Range (KSh)'),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000000,
                    divisions: 20,
                    labels: RangeLabels(
                      _priceRange.start.round().toString(),
                      _priceRange.end.round().toString(),
                    ),
                    onChanged: (values) => setState(() => _priceRange = values),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Min: KSh ${_priceRange.start.round()}'),
                      Text('Max: KSh ${_priceRange.end.round()}'),
                    ],
                  ),

                  const Divider(height: 32),
                  _buildSectionTitle('Property Types'),
                  Wrap(
                    spacing: 8,
                    children: _propertyTypes.map((type) => FilterChip(
                      label: Text(type),
                      selected: _selectedTypes.contains(type),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTypes.add(type);
                          } else {
                            _selectedTypes.remove(type);
                          }
                        });
                      },
                    )).toList(),
                  ),

                  const Divider(height: 32),
                  _buildSectionTitle('Bedrooms (Minimum)'),
                  Row(
                    children: List.generate(6, (index) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(index == 5 ? '5+' : index.toString()),
                        selected: _minBedrooms == index,
                        onSelected: (val) => setState(() => _minBedrooms = index),
                      ),
                    )),
                  ),

                  const Divider(height: 32),
                  _buildSectionTitle('Essential Amenities'),
                  SwitchListTile(
                    title: const Text('Parking Space'),
                    value: _mustHaveParking,
                    onChanged: (v) => setState(() => _mustHaveParking = v),
                  ),
                  SwitchListTile(
                    title: const Text('24/7 Security'),
                    value: _mustHaveSecurity,
                    onChanged: (v) => setState(() => _mustHaveSecurity = v),
                  ),
                  SwitchListTile(
                    title: const Text('Internet / Fiber Ready'),
                    value: _mustHaveInternet,
                    onChanged: (v) => setState(() => _mustHaveInternet = v),
                  ),
                  
                  const SizedBox(height: 40),
                  FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Search preferences saved!')),
                      );
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                    child: const Text('Apply Preferences'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showCountyPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Counties'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: kenyaCounties.length,
            itemBuilder: (context, index) {
              final county = kenyaCounties[index];
              final isSelected = _selectedCounties.contains(county);
              return CheckboxListTile(
                title: Text(county),
                value: isSelected,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedCounties.add(county);
                    } else {
                      _selectedCounties.remove(county);
                    }
                  });
                  Navigator.pop(context);
                  _showCountyPicker();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
        ],
      ),
    );
  }
}
