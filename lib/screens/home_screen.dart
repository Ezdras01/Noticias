import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';
import '../widgets/news_card.dart';
import 'article_detail_screen.dart'; // Importa la pantalla de detalle de artículo

// Pantalla principal que muestra los titulares de noticias
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Instancia del servicio que se encarga de obtener las noticias
  final NewsService _newsService = NewsService();

  // Lista de artículos obtenidos de la API
  List<NewsArticle> _articles = [];

  // Estado de carga
  bool _isLoading = true;

  // Método que se ejecuta cuando se inicializa el widget
  @override
  void initState() {
    super.initState();
    _loadNews(); // Cargar noticias al iniciar
  }

  // Función que llama al servicio y actualiza el estado
  Future<void> _loadNews() async {
    try {
      final articles = await _newsService.fetchTopHeadlines(country: 'us');
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar noticias: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método que construye la interfaz
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Noticias Hoy'), centerTitle: true),
      body: _isLoading
          // Mostrar indicador de carga mientras se obtienen datos
          ? const Center(child: CircularProgressIndicator())
          // Mostrar lista de noticias
          : ListView.builder(
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                final article = _articles[index];
                return NewsCard(
                  article: article,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArticleDetailScreen(article: article),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
