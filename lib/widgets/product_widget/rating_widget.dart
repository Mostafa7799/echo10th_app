import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../data_model/product_details_response.dart';

class CustomRatingWidget extends StatefulWidget {
  const CustomRatingWidget({super.key, this.productDetails});
  final DetailedProduct? productDetails;

  @override
  State<CustomRatingWidget> createState() => _CustomRatingWidgetState();
}

class _CustomRatingWidgetState extends State<CustomRatingWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingBar(
          itemSize: 15.0,
          ignoreGestures: true,
          initialRating: double.parse(widget.productDetails!.rating.toString()),
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          ratingWidget: RatingWidget(
            full: Icon(Icons.star, color: Colors.amber),
            half: Icon(Icons.star_half, color: Colors.amber),
            empty: Icon(
              Icons.star,
              color: MyTheme.blue_grey,
              size: 20,
            ),
          ),
          itemPadding: EdgeInsets.only(right: 1.0),
          onRatingUpdate: (rating) {
            //print(rating);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            "(" + widget.productDetails!.rating_count.toString() + ")",
            style: TextStyle(
                color: Color.fromRGBO(152, 152, 153, 1), fontSize: 10),
          ),
        ),
      ],
    );
  }
}
