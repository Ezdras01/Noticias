import 'package:flutter/material.dart';
import '../models/news_article.dart';

// Widget que representa una tarjeta de noticia con imagen, título y fuente
class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback? onTap; // Acción al tocar la tarjeta

  const NewsCard({super.key, required this.article, this.onTap});

@override
Widget build(BuildContext context) {
  return Card(
    elevation: 3,
    margin: const EdgeInsets.all(8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // 🔑 Hace que la tarjeta se ajuste al contenido
        children: [
          if (article.urlToImage.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                article.urlToImage,
                width: double.infinity,
                height: 180, // 🎯 Altura fija pero más baja que antes
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(
                      height: 180,
                      child: Center(child: Icon(Icons.broken_image)),
                    ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${article.sourceName} · ${article.publishedAt.substring(0, 10)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

}
