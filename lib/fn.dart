import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

var values = [
  "Don't say bye to FREE Xstream box & ZERO COST installation! Just add DTH to your Airtel Fiber plan & get 350+ channels, 18+ OTTs and unlimited data with plans starting at just Rs.699. i.airtel.in/BBFreeBox, Time's ticking!",
  "Only a few days left to claim your HDFC Bank Loan on Credit Card XX5438. Grab now: hdfcbk.io/a/Nw62j0O0 -HDFC BANK",
  "<#> 959704 is the OTP to view your Axis Bank Credit Card details. Valid for 5 mins. Do not share with anyone.",
  "Reignite the magic with a Loan on your Credit Card x5438. Pay the lowest rate. Hurry, check offer: hdfcbk.io/a/oPneG0M5 - HDFC Bank",
  "Dear SBI Customer, SBI Mobile apps should always be downloaded from official app stores. Never download by clicking on link received on SMS."
      "Dear SBI Customer, SBI Mobile have credited with INR 5,000 Never download by clicking on link received on SMS."
];

Iterable<SmsMessage> mockSms() {
  return values.map((e) => SmsMessage.fromJson({"body": e})).toList();
}

Iterable<MoneyTransaction> processAndAnalyzeSMS(Iterable<SmsMessage> messages) {
  return messages
      .where((message) => isFinancialTransaction(message.body))
      .map((message) => analyzeFinancialTransaction(message.body, message));
}

bool isFinancialTransaction(String? content) {
  if (content == null) {
    return false;
  }

  // Check if any financial keywords are present in the tokens
  List<String> financialKeywords = [
    'payment',
    'transfer',
    'purchase',
    'debit',
    'credit',
    'spent',
    'paid',
    'txn',
  ];

  // list of all keywords which are not financial transactions
  var exclude = [
    'exclusive',
    'limited period',
    'offer',
    'discount',
    'cashback',
    'reward',
    'coupon',
    'promo',
    'code',
    'voucher',
    'sale',
    'otp',
    'welcome to',
    'activate your',
    'disburment',
    'claim',
    'grab now',
    'loan',
    'recharge',
    'csdl',
    'upto',
    'complete kyc',
    'get your',
    'make the payment',
    'gift',
    'win',
  ];

  return financialKeywords
          .any((element) => content.toLowerCase().contains(element)) &&
      !exclude.any((element) => content.toLowerCase().contains(element)) &&
      containAmount(content);
}

MoneyTransaction analyzeFinancialTransaction(
    String? content, SmsMessage message) {
  if (content == null) {
    return MoneyTransaction(
        amount: 0,
        title: 'Unknown',
        body: content,
        date: message.date ?? DateTime.now());
  }
  double amount = extractAmount(content);
  // String type = extractTransactionType(content);

  return MoneyTransaction(
      amount: amount,
      title: message.sender,
      body: content,
      date: message.date ?? DateTime.now());
}

bool containAmount(String content) {
  RegExp regex = RegExp(
      r'(Rs\.|INR|\₹)\s*([\d,]+(?:\.\d{2})?)|([\d,]+(?:\.\d{2})?)\s*(Rs\.|INR|\₹)');
  Iterable<RegExpMatch> matches = regex.allMatches(content);
  return matches.isNotEmpty;
}

double extractAmount(String content) {
  RegExp regex = RegExp(
      r'(Rs\.|INR|\₹)\s*([\d,]+(?:\.\d{2})?)|([\d,]+(?:\.\d{2})?)\s*(Rs\.|INR|\₹)');
  Iterable<RegExpMatch> matches = regex.allMatches(content);

  if (matches.isNotEmpty) {
    try {
      var amount = matches.first.group(2) ?? matches.last.group(3)!;
      return double.parse(amount.replaceAll(',', '').trim());
    } catch (e) {
      return double.parse('0');
    }
  }
  return double.parse('0');
}

String extractTransactionType(String? content) {
  if (content == null) {
    return 'Unknown';
  }
  // Use NLP techniques for more advanced processing
  // In this example, we'll use a basic mapping of keywords
  Map<String, String> transactionTypeMap = {
    'payment': 'Payment',
    'transfer': 'Transfer',
    'purchase': 'Purchase',
    'debit': 'Debit',
    'credit': 'Credit',
    'spent': 'Purchase',
  };

  for (String token in transactionTypeMap.keys.toList()) {
    if (content.toLowerCase().contains(token)) {
      return transactionTypeMap[token]!;
    }
  }

  return 'Unknown';
}

class MoneyTransaction {
  final double amount;
  final String? title;
  final String? body;
  final DateTime date;

  MoneyTransaction(
      {required this.amount,
      required this.title,
      required this.body,
      required this.date});
}
