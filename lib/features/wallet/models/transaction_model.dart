class TransactionModel {
  final String id;
  final String userId;
  final int amount;
  final String transactionType;
  final String status;
  final String? description;
  final String? reference;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.transactionType,
    required this.status,
    this.description,
    this.reference,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      userId: json['user_id'],
      amount: json['amount'],
      transactionType: json['transaction_type'],
      status: json['status'],
      description: json['description'],
      reference: json['reference'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
