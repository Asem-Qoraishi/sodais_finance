import 'package:flutter/material.dart';
import 'package:sodais_finance/features/products/domain/product.dart';
import 'package:sodais_finance/features/products/presentation/widgets/product_card.dart';

class ProductsList extends StatelessWidget {
  const ProductsList({super.key});

  @override
  Widget build(BuildContext context) {
    final productList = [
      Product(
        id: "prod_001",
        name: "ساعت هوشمند شیک (رزگلد)",
        description:
            "ساعت هوشمند با طراحی گرد، بدنه فلزی رزگلد و بند سیلیکونی صورتی. دارای نمایشگر دیجیتال با نمایش ساعت، تاریخ و روز هفته.",
        price: 129,
        stock: 50,
      ),
      Product(
        id: "prod_002",
        name: 'ست مراقبت پوستی گیاهی',
        description:
            "descriptionست مراقبت پوستی طبیعی با عصاره‌های گیاهی. شامل بطری سرم و ظروف کرم مناسب روتین مراقبت از پوست و مو.",
        stock: 0,
        price: 79.99,
      ),
    ];

    return ListView.builder(
      itemCount: productList.length,
      itemBuilder: (context, index) => ProductCard(product: productList[index]),
    );
  }
}
