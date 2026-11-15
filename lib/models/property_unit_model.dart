import 'package:nyumba_mtaani/entities/property_unit_entity.dart';

class PropertyUnitModel extends PropertyUnitEntity {
  const PropertyUnitModel({
    required super.id,
    required super.propertyId,
    required super.unitNumber,
    super.floor,
    super.price,
    required super.status,
    super.currentTenantId,
  });

  factory PropertyUnitModel.fromJson(Map<String, dynamic> json) {
    return PropertyUnitModel(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      unitNumber: json['unit_number'] as String,
      floor: json['floor'] as String?,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      status: UnitStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UnitStatus.vacant,
      ),
      currentTenantId: json['current_tenant_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'unit_number': unitNumber,
      'floor': floor,
      'price': price,
      'status': status.name,
      'current_tenant_id': currentTenantId,
    };
  }
}
