import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import '../data_model/category_response.dart';
import '../screens/category_list_n_product/category_products.dart';
import 'device_info.dart';

class CategoryItemCardWidget extends StatelessWidget {
  final CategoryResponse categoryResponse;
  final int index;

  const CategoryItemCardWidget({
    Key? key,
    required this.categoryResponse,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return CategoryProducts(
                  slug: categoryResponse.categories![index].slug ?? "",
                );
              },
            ),
          );
        },
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(6),
                      topLeft: Radius.circular(6)),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/placeholder.png',
                    image: categoryResponse.categories![index].banner!,
                    fit: BoxFit.cover,
                    height: 85,
                    width: DeviceInfo(context).width,
                  ),
                ),
              ),
              GutterSmall(),
              Text(
                categoryResponse.categories![index].name!,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Spacer()
            ],
          ),
        ),
      ),
    );
  }
}
