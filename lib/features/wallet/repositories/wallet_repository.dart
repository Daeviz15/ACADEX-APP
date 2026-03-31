import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/transaction_model.dart';

final walletRepositoryProvider = Provider((ref) => WalletRepository(ref.watch(dioProvider)));
class WalletRepository {
  final Dio _dio;
  WalletRepository(this._dio);

  Future<int> getBalance() async {
    try {
      final response = await _dio.get('/wallet/balance');
      return response.data['balance'] as int;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final response = await _dio.get('/wallet/transactions');
      return (response.data as List).map((x) => TransactionModel.fromJson(x)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<TransactionModel> simulateDeposit(int amount, String reference) async {
    try {
      final response = await _dio.post('/wallet/deposit', queryParameters: {
        'amount': amount,
        'reference': reference,
      });
      return TransactionModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
