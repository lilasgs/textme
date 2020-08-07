import 'package:flutter/material.dart';

String getInitials(bank_account_name) {
  List<String> names = bank_account_name.split(" ");
  String initials = "";
  int numWords = 2;

  if (numWords < names.length) {
    numWords = 2;
  } else {
    numWords = 1;
  }

  for (var i = 0; i < numWords; i++) {
    initials += '${names[i][0]}';
  }
  return initials;
}
