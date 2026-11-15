import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';
import 'package:nyumba_mtaani/entities/user_entity.dart';
import 'package:nyumba_mtaani/models/user_model.dart';
import 'package:nyumba_mtaani/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final SupabaseClient _client;

  AdminRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers() async {
    try {
      final response = await _client
          .from('profiles')
          .select('*, roles:user_roles(role_id(roles(name)))')
          .order('created_at', ascending: false);

      final users = (response as List<dynamic>).map((profile) {
        final roles = <String>[];
        final rolesData = profile['roles'] as List<dynamic>?;
        if (rolesData != null) {
          for (final r in rolesData) {
            final roleName = r['role_id']?['roles']?['name'] as String?;
            if (roleName != null) roles.add(roleName);
          }
        }
        return UserModel.fromJson({
          ...profile,
          'roles': roles,
        });
      }).toList();

      return Right(users);
    } catch (e, st) {
      AppLogger.error('getAllUsers error', e, st);
      return const Left(ServerFailure('Failed to load users'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleUserActiveStatus(String userId, bool isActive) async {
    try {
      await _client.from('profiles').update({'is_active': isActive}).eq('id', userId);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to update user status'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getVerificationQueue() async {
    try {
      final agentRes = await _client
          .from('agent_verifications')
          .select('*, profiles(*)')
          .eq('status', 'pending');
          
      final providerRes = await _client
          .from('provider_verifications')
          .select('*, profiles(*)')
          .eq('status', 'pending');

      final List<Map<String, dynamic>> queue = [];
      for (var item in agentRes) {
        queue.add({...item, 'account_type': 'agent'});
      }
      for (var item in providerRes) {
        queue.add({...item, 'account_type': 'service_provider'});
      }
      
      return Right(queue);
    } catch (e) {
      return const Left(ServerFailure('Failed to load verification queue'));
    }
  }

  @override
  Future<Either<Failure, void>> approveUser(String userId, String accountType) async {
    try {
      final table = accountType == 'agent' ? 'agent_verifications' : 'provider_verifications';
      
      await _client.from(table)
          .update({'status': 'approved'})
          .eq('user_id', userId);
      
      await _client.from('profiles')
          .update({'verification_status': 'verified'})
          .eq('id', userId);
      
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to approve user'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectUser(String userId, String accountType, String reason) async {
    try {
      final table = accountType == 'agent' ? 'agent_verifications' : 'provider_verifications';
      
      await _client.from(table)
          .update({'status': 'rejected', 'rejection_reason': reason})
          .eq('user_id', userId);
          
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to reject user'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSystemStats() async {
    try {
      final usersRes = await _client.from('profiles').select('account_type');
      final users = usersRes as List<dynamic>;
      
      final Map<String, int> roleBreakdown = {
        'seeker': 0,
        'landlord': 0,
        'agent': 0,
        'service_provider': 0,
      };
      
      for (var user in users) {
        final type = user['account_type'] as String?;
        if (type != null && roleBreakdown.containsKey(type)) {
          roleBreakdown[type] = (roleBreakdown[type] ?? 0) + 1;
        }
      }

      final propertiesRes = await _client.from('properties').select('id').count(CountOption.exact);
      final pendingRes = await _client.from('properties').select('id').eq('status', 'pending').count(CountOption.exact);
      final reportsRes = await _client.from('reports').select('id').eq('status', 'pending').count(CountOption.exact);
      final revenueRes = await _client.from('transactions').select('amount').eq('status', 'completed');
      
      double totalRevenue = 0;
      for (var item in (revenueRes as List)) {
        totalRevenue += (item['amount'] as num).toDouble();
      }

      return Right({
        'users': users.length,
        'roleBreakdown': roleBreakdown,
        'properties': propertiesRes.count,
        'pending': pendingRes.count,
        'reports': reportsRes.count,
        'revenue': totalRevenue,
      });
    } catch (e, st) {
      AppLogger.error('getSystemStats error', e, st);
      return const Left(ServerFailure('Failed to fetch stats'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPendingReports() async {
    try {
      final response = await _client
          .from('reports')
          .select('*, properties(*), reporter:profiles!reporter_id_fkey(*)')
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      return Right(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      return const Left(ServerFailure('Failed to load reports'));
    }
  }

  @override
  Future<Either<Failure, void>> resolveReport(String reportId, String resolution) async {
    try {
      await _client.from('reports').update({
        'status': 'resolved',
        'resolution': resolution,
        'resolved_at': DateTime.now().toIso8601String(),
      }).eq('id', reportId);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to resolve report'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getDisputes() async {
    try {
      final response = await _client
          .from('job_disputes')
          .select('*, jobs:job_requests(*), reporter:profiles!reporter_id(*)')
          .order('created_at', ascending: false);
      return Right(List<Map<String, dynamic>>.from(response));
    } catch (e, st) {
      AppLogger.error('getDisputes error', e, st);
      return const Left(ServerFailure('Failed to load disputes'));
    }
  }

  @override
  Future<Either<Failure, void>> resolveDispute(String disputeId, String resolution) async {
    try {
      await _client.from('job_disputes').update({
        'status': 'resolved',
        'resolution': resolution,
        'resolved_at': DateTime.now().toIso8601String(),
      }).eq('id', disputeId);
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('resolveDispute error', e, st);
      return const Left(ServerFailure('Failed to resolve dispute'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAuditLogs({int limit = 50}) async {
    try {
      final response = await _client
          .from('audit_logs')
          .select('*, profiles(full_name, email)')
          .order('created_at', ascending: false)
          .limit(limit);
      return Right(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      return const Left(ServerFailure('Failed to load audit logs'));
    }
  }
}
