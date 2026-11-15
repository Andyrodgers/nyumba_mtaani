import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/entities/user_entity.dart';

abstract class AgentRepository {
  Future<Either<Failure, List<UserEntity>>> searchAgents(String query);
  Future<Either<Failure, void>> assignAgentToProperty(String propertyId, String agentId);
  Future<Either<Failure, List<Map<String, dynamic>>>> getAgentLeads();
  Future<Either<Failure, Map<String, dynamic>>> getAgentPerformance();
}
