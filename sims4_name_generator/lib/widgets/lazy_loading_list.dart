import 'package:flutter/material.dart';

/// A lazy loading list widget that efficiently handles large datasets
class LazyLoadingList<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int pageSize) dataLoader;
  final Widget Function(T item, int index) itemBuilder;
  final Widget? Function(int index)? loadingBuilder;
  final Widget? Function(String error)? errorBuilder;
  final Widget? Function()? emptyBuilder;
  final int pageSize;
  final bool hasMoreData;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const LazyLoadingList({
    super.key,
    required this.dataLoader,
    required this.itemBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.pageSize = 20,
    this.hasMoreData = true,
    this.scrollController,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<LazyLoadingList<T>> createState() => _LazyLoadingListState<T>();
}

class _LazyLoadingListState<T> extends State<LazyLoadingList<T>> {
  final List<T> _items = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;
  int _currentPage = 0;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Load initial data
  Future<void> _loadInitialData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final items = await widget.dataLoader(0, widget.pageSize);

      setState(() {
        _items.clear();
        _items.addAll(items);
        _currentPage = 0;
        _hasMoreData = items.length >= widget.pageSize && widget.hasMoreData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Load more data for pagination
  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final items = await widget.dataLoader(nextPage, widget.pageSize);

      setState(() {
        _items.addAll(items);
        _currentPage = nextPage;
        _hasMoreData = items.length >= widget.pageSize && widget.hasMoreData;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoadingMore = false;
      });
    }
  }

  /// Handle scroll events for lazy loading
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  /// Refresh the list
  Future<void> refresh() async {
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_hasError) {
      return _buildErrorWidget();
    }

    if (_items.isEmpty) {
      return _buildEmptyWidget();
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.builder(
        controller: widget.scrollController ?? _scrollController,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        itemCount: _items.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            // Loading more indicator
            return _buildLoadingMoreWidget();
          }

          return widget.itemBuilder(_items[index], index);
        },
      ),
    );
  }

  /// Build loading widget
  Widget _buildLoadingWidget() {
    final customWidget = widget.loadingBuilder?.call(0);
    if (customWidget != null) {
      return customWidget;
    }

    return const Center(child: CircularProgressIndicator());
  }

  /// Build error widget
  Widget _buildErrorWidget() {
    final customWidget = widget.errorBuilder?.call(
      _errorMessage ?? 'Unknown error',
    );
    if (customWidget != null) {
      return customWidget;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading data',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Build empty widget
  Widget _buildEmptyWidget() {
    final customWidget = widget.emptyBuilder?.call();
    if (customWidget != null) {
      return customWidget;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try refreshing or check your filters',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build loading more widget
  Widget _buildLoadingMoreWidget() {
    final customWidget = widget.loadingBuilder?.call(_items.length);
    if (customWidget != null) {
      return customWidget;
    }

    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

/// A paginated list widget with manual pagination controls
class PaginatedList<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int pageSize) dataLoader;
  final Future<int> Function() totalCountLoader;
  final Widget Function(T item, int index) itemBuilder;
  final Widget? Function(int index)? loadingBuilder;
  final Widget? Function(String error)? errorBuilder;
  final Widget? Function()? emptyBuilder;
  final int pageSize;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const PaginatedList({
    super.key,
    required this.dataLoader,
    required this.totalCountLoader,
    required this.itemBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.pageSize = 20,
    this.scrollController,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  State<PaginatedList<T>> createState() => _PaginatedListState<T>();
}

class _PaginatedListState<T> extends State<PaginatedList<T>> {
  final List<T> _items = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalCount = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Load initial data
  Future<void> _loadInitialData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Load total count and first page in parallel
      final results = await Future.wait([
        widget.totalCountLoader(),
        widget.dataLoader(0, widget.pageSize),
      ]);

      final totalCount = results[0] as int;
      final items = results[1] as List<T>;

      setState(() {
        _items.clear();
        _items.addAll(items);
        _currentPage = 0;
        _totalCount = totalCount;
        _totalPages = (totalCount / widget.pageSize).ceil();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Load specific page
  Future<void> _loadPage(int page) async {
    if (_isLoading || page < 0 || page >= _totalPages) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final items = await widget.dataLoader(page, widget.pageSize);

      setState(() {
        _items.clear();
        _items.addAll(items);
        _currentPage = page;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Go to next page
  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _loadPage(_currentPage + 1);
    }
  }

  /// Go to previous page
  void _previousPage() {
    if (_currentPage > 0) {
      _loadPage(_currentPage - 1);
    }
  }

  /// Go to specific page
  void _goToPage(int page) {
    _loadPage(page);
  }

  /// Refresh the list
  Future<void> refresh() async {
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _items.isEmpty) {
      return _buildLoadingWidget();
    }

    if (_hasError && _items.isEmpty) {
      return _buildErrorWidget();
    }

    if (_items.isEmpty) {
      return _buildEmptyWidget();
    }

    return Column(
      children: [
        // Pagination controls
        _buildPaginationControls(),

        // List content
        Expanded(
          child: RefreshIndicator(
            onRefresh: refresh,
            child: ListView.builder(
              controller: widget.scrollController ?? _scrollController,
              padding: widget.padding,
              shrinkWrap: widget.shrinkWrap,
              physics: widget.physics,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return widget.itemBuilder(_items[index], index);
              },
            ),
          ),
        ),

        // Loading indicator for page changes
        if (_isLoading && _items.isNotEmpty) const LinearProgressIndicator(),
      ],
    );
  }

  /// Build pagination controls
  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page info
          Text(
            'Page ${_currentPage + 1} of $_totalPages ($_totalCount total)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          // Navigation buttons
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 0 ? _previousPage : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous page',
              ),

              // Page numbers
              ..._buildPageNumbers(),

              IconButton(
                onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next page',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build page number buttons
  List<Widget> _buildPageNumbers() {
    final widgets = <Widget>[];
    final maxVisiblePages = 5;

    if (_totalPages <= maxVisiblePages) {
      // Show all page numbers
      for (int i = 0; i < _totalPages; i++) {
        widgets.add(_buildPageButton(i));
      }
    } else {
      // Show limited page numbers with ellipsis
      if (_currentPage < 3) {
        // Show first few pages
        for (int i = 0; i < 3; i++) {
          widgets.add(_buildPageButton(i));
        }
        widgets.add(const Text('...'));
        widgets.add(_buildPageButton(_totalPages - 1));
      } else if (_currentPage > _totalPages - 4) {
        // Show last few pages
        widgets.add(_buildPageButton(0));
        widgets.add(const Text('...'));
        for (int i = _totalPages - 3; i < _totalPages; i++) {
          widgets.add(_buildPageButton(i));
        }
      } else {
        // Show current page with surrounding pages
        widgets.add(_buildPageButton(0));
        widgets.add(const Text('...'));
        for (int i = _currentPage - 1; i <= _currentPage + 1; i++) {
          widgets.add(_buildPageButton(i));
        }
        widgets.add(const Text('...'));
        widgets.add(_buildPageButton(_totalPages - 1));
      }
    }

    return widgets;
  }

  /// Build individual page button
  Widget _buildPageButton(int page) {
    final isCurrentPage = page == _currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: isCurrentPage ? null : () => _goToPage(page),
        borderRadius: BorderRadius.circular(4.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: isCurrentPage
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            '${page + 1}',
            style: TextStyle(
              color: isCurrentPage
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  /// Build loading widget
  Widget _buildLoadingWidget() {
    final customWidget = widget.loadingBuilder?.call(0);
    if (customWidget != null) {
      return customWidget;
    }

    return const Center(child: CircularProgressIndicator());
  }

  /// Build error widget
  Widget _buildErrorWidget() {
    final customWidget = widget.errorBuilder?.call(
      _errorMessage ?? 'Unknown error',
    );
    if (customWidget != null) {
      return customWidget;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading data',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Build empty widget
  Widget _buildEmptyWidget() {
    final customWidget = widget.emptyBuilder?.call();
    if (customWidget != null) {
      return customWidget;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try refreshing or check your filters',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
