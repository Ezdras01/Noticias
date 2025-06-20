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
  // Controlador para el campo de búsqueda
  TextEditingController _searchController = TextEditingController();

  // Historial de búsqueda y última consulta
  List<String> _searchHistory = [];
  String? _lastQuery;


  // Estado de carga
  bool _isLoading = true;

  // Método que se ejecuta cuando se inicializa el widget
  @override
  void initState() {
    super.initState();
    _loadNews(); // Cargar noticias al iniciar
  }

  // Función que llama al servicio y actualiza el estado
Future<void> _loadNews({String? query}) async {
  setState(() => _isLoading = true);

  try {
    final articles = query == null || query.isEmpty
        ? await _newsService.fetchTopHeadlines(country: 'us')
        : await _newsService.searchNews(query);

    setState(() {
      _articles = articles;
      _isLoading = false;
      _lastQuery = query;

      // Guardar la búsqueda si fue exitosa y no está vacía
      if (query != null && query.trim().isNotEmpty && !_searchHistory.contains(query)) {
        _searchHistory.insert(0, query); // Agrega al inicio
        if (_searchHistory.length > 10) _searchHistory.removeLast(); // Máximo 10
      }
    });
  } catch (e) {
    print('Error al cargar noticias: $e');
    setState(() => _isLoading = false);
  }
}



  // Método que construye la interfaz
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Noticias Hoy'), centerTitle: true),
    body: Column(
      children: [
        // Barra de búsqueda
        Padding(
          padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar noticias...',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _loadNews(); // Recarga titulares
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) =>
                        setState(() {}), // Para actualizar el botón de limpiar
                    onSubmitted: (value) => _loadNews(query: value),
                  ),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _loadNews(query: _searchController.text),
                child: const Icon(Icons.search),
              ),
            ],
          ),
        ),

        // Lista o loading
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _articles.isEmpty
                  ? const Center(child: Text('No se encontraron noticias.'))
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
                                builder: (_) =>
                                    ArticleDetailScreen(article: article),
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    ),
  );
}

}
