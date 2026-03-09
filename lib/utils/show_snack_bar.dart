import 'package:flutter/material.dart';
import 'package:pedometer_application/main.dart';

void showGlobalSnackBar(String message) {
  messengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating, 
    ),
  );
}