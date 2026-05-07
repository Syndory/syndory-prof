import 'package:flutter/material.dart';
import '../justification_controller.dart';
import '../../domain/justification_model.dart';
import '../widgets/justification_card.dart';
import '../widgets/justification_skeleton.dart';
import '../widgets/justification_states.dart';
import 'justification_detail_page.dart';
import '../../../notifications/notifications_screen.dart';

class JustificationListPage extends StatefulWidget {
  const JustificationListPage({super.key});

  @override
  State<JustificationListPage> createState() => _JustificationListPageState();
}

class _JustificationListPageState extends State<JustificationListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final JustificationController _controller = JustificationController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _controller.load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Justificatifs',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF092C4C),
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF092C4C)),
                onPressed: () => _controller.load(),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Color(0xFF092C4C)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NotificationsScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFF5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF092C4C),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF4F4F4F),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: 'À traiter'),
          Tab(text: 'Historique'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder<JustificationState>(
      valueListenable: _controller,
      builder: (context, state, child) {
        if (state.status == JustificationStateStatus.loading) {
          return const JustificationSkeletonList();
        }

        if (state.status == JustificationStateStatus.error) {
          return JustificationErrorState(
            error: state.error,
            onRetry: () => _controller.load(),
          );
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildList(_controller.pendingItems, 'Aucun justificatif en attente.'),
            _buildList(_controller.processedItems, 'Aucun justificatif traité pour le moment.'),
          ],
        );
      },
    );
  }

  Widget _buildList(List<Justification> items, String emptyMessage) {
    if (items.isEmpty) {
      return JustificationEmptyState(message: emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: () => _controller.load(),
      color: const Color(0xFF092C4C),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return JustificatifCard(
            item: item,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JustificationDetailPage(justification: item),
                ),
              );
              if (result == true) {
                _controller.load();
              }
            },
          );
        },
      ),
    );
  }
}
