// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iotchain/controllers/blockchain_adapter.dart';
import 'package:iotchain/model/asset_model.dart';

class AssetsTab extends StatefulWidget {
  static const title = 'Assets';
  static const icon = Icon(Icons.music_note);

  const AssetsTab({Key key}) : super(key: key);

  @override
  _AssetsTabState createState() => _AssetsTabState();
}

class _AssetsTabState extends State<AssetsTab> {
  static const _itemsLength = 50;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  List<Asset> assets = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() {
    return fetchAssets().then((value) => setState(() => assets = value));
  }

  Widget _listBuilder(BuildContext context, int index) {
    if (index >= _itemsLength) return null;
    return SafeArea(
      top: false,
      bottom: false,
      child: Hero(
        tag: index,
        child: _assetCard(assets[index]),
      ),
    );
  }

  Widget _assetCard(Asset asset) => Card(
        elevation: 5,
        child: Container(
          height: 100,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 5),
                  child: Row(
                    children: <Widget>[
                      Text(asset.name,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Spacer(),
                      Text(asset.value),
                      Spacer(),
                      Text(asset.owner),
                      SizedBox(
                        width: 20,
                      )
                    ],
                  )),
            ),
          ),
        ),
      );

  @override
  Widget build(context) => RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refreshData,
        child: ListView.builder(
          itemCount: assets.length,
          padding: EdgeInsets.symmetric(vertical: 12),
          itemBuilder: _listBuilder,
        ),
      );

  Future<List<Asset>> fetchAssets() async {
    String data = await Blockchain.evaluateTransaction("assets", "ListAssets");
    List<Asset> assets = List<Asset>.from(
        (json.decode(data) as List).map((model) => Asset.fromJson(model)));
    return assets;
    return <Asset>[];
  }
}
