import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';
import 'package:nyumba_mtaani/entities/user_entity.dart';
import 'package:nyumba_mtaani/models/user_model.dart';
import 'package:nyumba_mtaani/repositories/agent_repository.dart';

class AgentRepositoryImpl implements AgentRepository {
  final SupabaseClient _client;

  AgentRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<UserEntity>>> searchAgents(String query) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('account_type', 'agent')
          .ilike('full_name', '%$query%')
          .eq('verification_status', 'verified');

      final agents = (response as List<dynamic>)
          .map((e) => UserModel.fromJson(e))
          .toList();

      return Right(agents);
    } catch (e, st) {
      AppLogger.error('searchAgents error', e, st);
      return const Left(ServerFailure('Failed to search agents'));
    }
  }

  @override
  Future<Either<Failure, void>> assignAgentToProperty(String propertyId, String agentId) async {
    try {
      await _client
          .from('properties')
          .update({'agent_id': agentId})
          .eq('id', propertyId);
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('assignAgentToProperty error', e, st);
      return const Left(ServerFailure('Failed to assign agent'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAgentLeads() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      // Leads can be viewings or enquiries for properties assigned to the agent
      final response = await _client
          .from('viewings')
          .select('*, properties!inner(*), profiles!guest_id(*)')
          .eq('properties.agent_id', userId)
          .order('created_at', ascending: false);

      return Right(List<Map<String, dynamic>>.from(response));
    } catch (e, st) {
      AppLogger.error('getAgentLeads error', e, st);
      return const Left(ServerFailure('Failed to load leads'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAgentPerformance() async {
    try {
      final userId = _client.auth.currentUser?.id;
      
      final listingsRes = await _client.from('properties').select('id').eq('agent_id', userId as Object).count(CountOption.exact);
      final dealsRes = await _client.from('properties').select('id').eq('agent_id', userId as Object).inFilter('status', ['sold', 'rented']).count(CountOption.exact);
      
      return Right({
        'active_listings': listingsRes.count,
        'completed_deals': dealsRes.count,
      });
    } catch (e) {
      return const Left(ServerFailure('Failed to load performance stats'));
    }
  }
}
