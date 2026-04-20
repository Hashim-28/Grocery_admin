class PaymentAccount {
  final String id;
  final String accountName;
  final String holderName;
  final String accountNumber;
  final String? iban;
  final DateTime? createdAt;

  PaymentAccount({
    required this.id,
    required this.accountName,
    required this.holderName,
    required this.accountNumber,
    this.iban,
    this.createdAt,
  });

  factory PaymentAccount.fromJson(Map<String, dynamic> json) {
    return PaymentAccount(
      id: json['id'],
      accountName: json['account_name'],
      holderName: json['holder_name'],
      accountNumber: json['account_number'],
      iban: json['iban'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_name': accountName,
      'holder_name': holderName,
      'account_number': accountNumber,
      'iban': iban,
    };
  }
}
