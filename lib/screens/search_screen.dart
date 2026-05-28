import 'package:flutter/material.dart';

import '../models/university.dart';
import '../services/search_history_service.dart';
import '../services/university_service.dart';
import '../widgets/uniguide_widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  var _query = '';
  var _showAll = false;
  var _loadedInitialQuery = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loadedInitialQuery) {
      return;
    }

    final initialQuery = ModalRoute.of(context)?.settings.arguments;
    if (initialQuery is String && initialQuery.trim().isNotEmpty) {
      _query = initialQuery.trim();
      _searchController.text = _query;
    }

    _loadedInitialQuery = true;
  }

  void _search(String query) {
    setState(() {
      _query = query;
      _showAll = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      bottomNavigationBar: const UniGuideBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            const UniGuideHeader(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: _search,
                    onSubmitted: SearchHistoryService.record,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search universities or majors...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: () {
                                _searchController.clear();
                                _search('');
                              },
                              icon: const Icon(Icons.close),
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD8DEE2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD8DEE2)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  StreamBuilder<List<University>>(
                    stream: UniversityService.universities(),
                    builder: (context, snapshot) {
                      final allUniversities =
                          snapshot.data ?? const <University>[];
                      final results =
                          UniversityService.filter(allUniversities, _query);
                      final visibleResults = _showAll
                          ? results
                          : results.take(5).toList(growable: false);
                      final canLoadMore = visibleResults.length < results.length;

                      if (snapshot.connectionState == ConnectionState.waiting &&
                          allUniversities.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${results.length} Universities\nFound',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                    height: 1.25,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const Text('Sort by:\nRelevance'),
                              const Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                          const SizedBox(height: 18),
                          if (results.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 80),
                              child: Center(
                                child: Text(
                                  'No universities found.',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                            )
                          else
                            ...visibleResults.map((university) {
                              return UniversityListCard(
                                university: university,
                                onDetails: () => Navigator.pushNamed(
                                  context,
                                  '/university-details',
                                  arguments: university,
                                ),
                              );
                            }),
                          if (canLoadMore) ...[
                            const SizedBox(height: 14),
                            Center(
                              child: OutlinedButton.icon(
                                onPressed: () => setState(() => _showAll = true),
                                icon: const Icon(Icons.keyboard_arrow_down),
                                label: const Text('Load More Universities'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: const BorderSide(color: primaryColor),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
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
