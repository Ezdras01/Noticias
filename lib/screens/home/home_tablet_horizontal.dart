import 'package:flutter/material.dart';
import '../../models/news_article.dart';
import '../../services/news_service.dart';
import '../../widgets/news_card.dart';
import '../article_detail_screen.dart';
import '../../controllers/theme_controller.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class HomeTabletHorizontal extends StatefulWidget {
  const HomeTabletHorizontal({super.key});

  @override
  State<HomeTabletHorizontal> createState() => _HomeTabletHorizontalState();
}

class _HomeTabletHorizontalState extends State<HomeTabletHorizontal> {
  final NewsService _newsService = NewsService();
  List<NewsArticle> _articles = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  final List<String> _searchHistory = [];
  String _selectedCountry = 'us';

  final Map<String, Map<String, String>> _countryOptions = {
    'us': {'label': '🇺🇸 USA', 'language': 'en'},
    'gb': {'label': '🇬🇧 Reino Unido', 'language': 'en'},
    'fr': {'label': '🇫🇷 Francia', 'language': 'fr'},
    'de': {'label': '🇩🇪 Alemania', 'language': 'de'},
    'it': {'label': '🇮🇹 Italia', 'language': 'it'},
    'es': {'label': '🇪🇸 España', 'language': 'es'},
  };

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews({String? query}) async {
    setState(() => _isLoading = true);

    try {
      final articles = query == null || query.isEmpty
          ? await _newsService.fetchTopHeadlines(country: _selectedCountry)
          : await _newsService.searchNews(
              query,
              _countryOptions[_selectedCountry]!['language']!,
            );

      setState(() {
        _articles = articles;
        _isLoading = false;
      });

      if (query != null && query.isNotEmpty && !_searchHistory.contains(query)) {
        setState(() => _searchHistory.insert(0, query));
      }
    } catch (e) {
      logger.e('Error al cargar noticias', error: e);
      setState(() => _isLoading = false);
    }
  }

  Widget _buildCountrySelector() {
    return DropdownButton<String>(
      value: _selectedCountry,
      items: _countryOptions.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value['label']!),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedCountry = value);
          _loadNews();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias Hoy'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
            ),
            onPressed: () => themeController.toggleTheme(),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar de búsqueda
          Container(
            width: 320,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selecciona un país:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildCountrySelector(),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar noticias...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _loadNews(query: _searchController.text),
                      ),
                    ),
                    onSubmitted: (value) => _loadNews(query: value),
                  ),
                  const SizedBox(height: 24),
                  if (_searchHistory.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Historial:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () =>
                                  setState(() => _searchHistory.clear()),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Borrar todo'),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _searchHistory.map((term) {
                            return InputChip(
                              label: Text(term),
                              onPressed: () => _loadNews(query: term),
                              onDeleted: () =>
                                  setState(() => _searchHistory.remove(term)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Contenido de noticias
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: _articles.length,
                    itemBuilder: (context, index) => NewsCard(
                      article: _articles[index],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ArticleDetailScreen(article: _articles[index]),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
