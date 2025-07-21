import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/news_article.dart';
import '../../services/news_service.dart';
import '../../widgets/news_card.dart';
import '../../controllers/theme_controller.dart';
import '../article_detail_screen.dart';

/// Pantalla principal adaptada para celulares.
class HomePhone extends StatefulWidget {
  const HomePhone({super.key});

  @override
  State<HomePhone> createState() => _HomePhoneState();
}

class _HomePhoneState extends State<HomePhone> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNews());
  }

  Future<void> _loadNews({String? query}) async {
    setState(() => _isLoading = true);
    try {
      final articles = query == null || query.isEmpty
          ? await _newsService.fetchTopHeadlines(country: _selectedCountry)
          : await _newsService.searchNews(query, _countryOptions[_selectedCountry]!['language']!);
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
      if (query != null && query.isNotEmpty && !_searchHistory.contains(query)) {
        setState(() => _searchHistory.insert(0, query));
      }
    } catch (e) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias Hoy'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Cambiar tema',
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
            ),
            onPressed: () {
              Provider.of<ThemeController>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar noticias...',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _loadNews();
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (_) => setState(() {}),
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
                  const SizedBox(height: 12),
                  _buildCountrySelector(),
                  const SizedBox(height: 12),
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
                              onPressed: () => setState(() => _searchHistory.clear()),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Borrar todo'),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                            ),
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
                                onDeleted: () => setState(() => _searchHistory.removeAt(index)),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  Expanded(
                    child: ListView.builder(
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
            ),
    );
  }
}
