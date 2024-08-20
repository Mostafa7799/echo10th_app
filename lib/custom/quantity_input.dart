import 'package:active_ecommerce_flutter/custom/only_number_formatter.dart';
import 'package:flutter/material.dart';

class QuantityInputField {
  static TextField show(TextEditingController controller,
      {required VoidCallback onSubmitted, bool isDisable = false}) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      readOnly: isDisable,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      inputFormatters: [OnlyNumberFormatter()],
      onSubmitted: (str) {
        onSubmitted();
      },
      decoration: InputDecoration.collapsed(hintText: "0"),
    );
  }
}
