import 'package:chainmetric/infrastructure/repositories/assets_fabric.dart';
import 'package:chainmetric/app/theme/theme.dart';
import 'package:chainmetric/models/assets/asset.dart';
import 'package:chainmetric/app/widgets/assets/card.dart';
import 'package:chainmetric/app/widgets/assets/search_delegate.dart';
import 'package:chainmetric/app/widgets/common/navigation_tab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AssetsTab extends NavigationTab {
  const AssetsTab({GlobalKey? key}) : super(key: key);

  _AssetsTabState? get _currentState =>
      (key as GlobalKey?)?.currentState as _AssetsTabState?;

  @override
  _AssetsTabState createState() => _AssetsTabState();

  @override
  Future refreshData() => _currentState!._refreshData();
}

class _AssetsTabState extends State<AssetsTab> {
  List<AssetPresenter> assets = [];
  String? scrollID;

  static const _itemsLength = 50;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Assets",
              style: AppTheme.title2
                  .override(fontFamily: "IBM Plex Mono", fontSize: 28)),
          centerTitle: false,
          elevation: 4,
          actionsIconTheme: Theme.of(context).iconTheme,
          actions: [
            IconButton(
                onPressed: () => showSearch<int>(
                      context: context,
                      delegate: AssetsSearchDelegate(),
                    ),
                icon: const Icon(Icons.search_sharp))
          ],
        ),
        body: RefreshIndicator(
          key: _refreshKey,
          onRefresh: _refreshData,
          child: ListView.builder(
            itemCount: assets.length,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemBuilder: _listBuilder,
          ),
        ),
      );

  Future<void> _refreshData() {
    _refreshKey.currentState?.show();
    return AssetsController.getAssets(limit: _itemsLength, scrollID: scrollID)
        .then((value) => setState(() {
              assets = value!.items;
              scrollID = value.scrollID;
            }));
  }

  Widget _listBuilder(BuildContext context, int index) {
    if (index >= _itemsLength) return const Center();
    return SafeArea(
      top: false,
      bottom: false,
      child: Hero(
        tag: assets[index].id,
        child: AssetCard(assets[index], refreshParent: _refreshData),
      ),
    );
  }
}
