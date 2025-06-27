import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_article.dart';
import 'package:share_plus/share_plus.dart';

// Pantalla que muestra los detalles de una noticia
class ArticleDetailScreen extends StatelessWidget {
  final NewsArticle article;

  const ArticleDetailScreen({super.key, required this.article});

  // Método que abre la URL de la noticia en el navegador
Future<void> _launchURL(BuildContext context) async {
  final Uri url = Uri.parse(article.url);
  final success = await launchUrl(url);

  // ✅ Verifica si el contexto sigue montado antes de usarlo
  if (!success) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.sourceName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen destacada
            if (article.urlToImage.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  article.urlToImage,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),

            // Título
            Text(
              article.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            // Fecha
            Text(
              'Publicado el ${article.publishedAt.substring(0, 10)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Descripción
            Text(
              article.description.isNotEmpty ? article.description : 'Sin descripción disponible.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Botón para leer más
            Center(
              child: ElevatedButton(
                onPressed: () => _launchURL(context),
                child: const Text('Leer noticia completa'),
              ),
            ),
            //botón de compartir
            const SizedBox(height: 16),// Espacio entre botones
          if(article.url.isNotEmpty)
            Center(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Compartir'),
                onPressed: () {
                  Share.share('${article.title}\n${article.url}');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
