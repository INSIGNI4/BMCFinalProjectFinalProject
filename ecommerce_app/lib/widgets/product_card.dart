
import 'package:flutter/material.dart';

// 1. This is a simple StatelessWidget
class ProductCard extends StatelessWidget {

  // 2. We'll require the data we need to display
  final String productName;
  final num price;
  final String imageUrl;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? priceColor;

  // 3. The constructor takes this data
  const ProductCard({
    super.key,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.onTap,
    this.backgroundColor,
    this.priceColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // ← Add your navigation function here
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  );
                },
              ),
            ),
            Expanded(

              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.brown[600], // <-- Change to any color you want

                ),
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '\u20B1${price.toDouble().toStringAsFixed(2)}',
                      // '₱${price.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.green[100],
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto')
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


// @override
  // Widget build(BuildContext context) {
  //   // The UI will go here next
  //   return InkWell(
  //       onTap: onTap, // 2. Call the function we passed in
  //       child: Card(
  //         elevation: 3,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             // 2. This is for the Image
  //             Expanded(
  //               child: Image.network(
  //                 imageUrl, // 3. This loads the image from the URL!
  //                 fit: BoxFit.cover, // 4. This makes the image fill its box
  //
  //                 // 5. Show a loading spinner while the image downloads
  //                 loadingBuilder: (context, child, loadingProgress) {
  //                   if (loadingProgress == null) return child;
  //                   return const Center(child: CircularProgressIndicator());
  //                 },
  //
  //                 // 6. Show an error icon if the URL is bad
  //                 errorBuilder: (context, error, stackTrace) {
  //                   return const Center(
  //                     child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
  //                   );
  //                 },
  //               ),
  //             ),
  //
  //             // 7. A container for the text, with padding
  //             Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   // 8. The Product Name
  //                   Text(
  //                     productName,
  //                     style: const TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 16,
  //                     ),
  //                     maxLines: 1, // 9. Only one line
  //                     overflow: TextOverflow.ellipsis, // 10. Show "..." if too long
  //                   ),
  //                   const SizedBox(height: 4),
  //
  //                   // 11. The Price
  //                   Text(
  //                     // 12. Format the number to 2 decimal places
  //                     '₱${price.toStringAsFixed(2)}',
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       color: Colors.grey[700],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //   );
  // }

}

