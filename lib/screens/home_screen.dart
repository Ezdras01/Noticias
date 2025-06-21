import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';
import '../widgets/news_card.dart';
import 'article_detail_screen.dart'; // Importa la pantalla de detalle de artículo
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart'; // Importa el controlador de tema
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

// Mapa de países y sus nombres en español
final Map<String, String> _countries = {
  'us': 'Estados Unidos',
  'gb': 'Reino Unido',
  'in': 'India',
  'de': 'Alemania',
  'fr': 'Francia',
};

String _selectedCountry = 'us'; // País por defecto



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
    ? await _newsService.fetchTopHeadlines(country: _selectedCountry)
    : await _newsService.searchNews(query, _selectedCountry);

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
appBar: AppBar(
  title: const Text('Noticias Hoy'),
  centerTitle: true,
  actions: [
    IconButton(
      tooltip: 'Cambiar tema',
      icon: Icon(
        Theme.of(context).brightness == Brightness.dark
            ? Icons.wb_sunny // ☀️ si está en oscuro, muestra sol
            : Icons.nightlight_round, // 🌙 si está en claro, muestra luna
      ),
      onPressed: () {
        // Cambia el tema usando el ThemeController
        Provider.of<ThemeController>(context, listen: false).toggleTheme();
      },
    )
  ],
),
    body: Column(
      children: [
        // Selector de país
Padding(
  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
  child: Row(
    children: [
      const Text(
        'País:',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(width: 12),
      DropdownButton<String>(
        value: _selectedCountry,
        items: _countries.entries
            .map(
              (entry) => DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedCountry = value;
            });
            _loadNews(); // Recarga noticias al cambiar de país
          }
        },
      ),
    ],
  ),
),
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
if (_searchHistory.isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(left: 12, right: 12, bottom: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Historial:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchHistory.clear(); // Borrar todo
                });
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Borrar todo'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            )
          ],
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _searchHistory.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final term = _searchHistory[index];
              return InputChip(
                label: Text(term),
                onPressed: () {
                  _searchController.text = term;
                  _loadNews(query: term);
                },
                onDeleted: () {
                  setState(() {
                    _searchHistory.removeAt(index); // Borrar solo este
                  });
                },
              );
            },
          ),
        ),
      ],
    ),
  ),

        // Lista o loading
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _articles.isEmpty
                ? Center(
                    child: Text(
                      _lastQuery == null || _lastQuery!.isEmpty
                          ? 'No hay noticias disponibles.'
                          : 'No se encontraron noticias para "${_lastQuery!}".',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
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
