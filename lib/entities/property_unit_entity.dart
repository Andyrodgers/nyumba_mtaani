import 'package:equatable/equatable.dart';

enum UnitStatus {
  vacant,
  occupied,
  maintenance,
  reserved
}

class PropertyUnitEntity extends Equatable {
  final String id;
  final String propertyId;
  final String unitNumber;
  final String? floor;
  final double? price;
  final UnitStatus status;
  final String? currentTenantId;

  const PropertyUnitEntity({
    required this.id,
    required this.propertyId,
    required this.unitNumber,
    this.floor,
    this.price,
    required this.status,
    this.currentTenantId,
  });

  @override
  List<Object?> get props => [id, propertyId, unitNumber, status, currentTenantId];
}
