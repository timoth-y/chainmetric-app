import 'package:chainmetric/infrastructure/repositories/assets_fabric.dart';
import 'package:chainmetric/platform/repositories/identities_shared.dart';
import 'package:chainmetric/platform/repositories/localdata_json.dart';
import 'package:chainmetric/models/assets/asset.dart';
import 'package:chainmetric/models/common/location.dart';
import 'package:chainmetric/app/utils/utils.dart';
import 'package:chainmetric/usecase/notifications/notifications_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';

class AssetForm extends StatefulWidget {
  final Asset? model;

  const AssetForm({this.model});

  @override
  _AssetFormState createState() => _AssetFormState();
}

class _AssetFormState extends State<AssetForm> {
  final _formKey = GlobalKey<FormState>();
  Asset asset = Asset();

  _AssetFormState();

  @override
  void initState() {
    super.initState();
    asset = widget.model ?? Asset.empty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Input asset"),
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...[
                        TextFormField(
                          initialValue: asset.name,
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: "Enter an asset name",
                            labelText: "Name",
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return "Please provide name for new asset";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() => asset.name = value);
                          },
                        ),
                        TextFormField(
                          initialValue: asset.sku,
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: "Enter an SKU code",
                            labelText: "SKU code",
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return "Please provide SKU code for new asset";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() => asset.sku = value);
                          },
                        ),
                        DropdownButtonFormField(
                          value: asset.type,
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: "Choose asset type",
                            labelText: "Asset type",
                          ),
                          items: LocalDataRepo.assetTypes!
                              .map<DropdownMenuItem<String>>(
                                  (type) => DropdownMenuItem<String>(
                                        value: type.type,
                                        child: Text(type.name),
                                      ))
                              .toList(),
                          validator: (dynamic value) {
                            if (value == null || value.isEmpty as bool) {
                              return "Please choose an asset type";
                            }
                            return null;
                          },
                          onChanged: (String? value) {
                            setState(() => asset.type = value!);
                          },
                        ),
                        TextFormField(
                          initialValue: asset.cost.toString(),
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: "Enter an cost",
                            labelText: "Cost",
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return "Please provide cost for new asset";
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(
                                () => asset.cost = num.tryParse(value) ?? 0);
                          },
                        ),
                        Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .inputDecorationTheme
                                  .fillColor,
                              boxShadow: kElevationToShadow[1],
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            width: double.infinity,
                            padding: const EdgeInsets.only(left: 10, top: 10),
                            child: Stack(children: [
                              Text("Amount",
                                  style: TextStyle(
                                      color: Theme.of(context).hintColor,
                                      fontSize: 16)),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: NumberPicker(
                                  axis: Axis.horizontal,
                                  value: asset.amount,
                                  minValue: 1,
                                  maxValue: 100,
                                  haptics: true,
                                  onChanged: (value) =>
                                      setState(() => asset.amount = value),
                                ),
                              )
                            ])),
                        TextFormField(
                          initialValue: asset.info,
                          decoration: const InputDecoration(
                            hintText: "Enter asset description",
                            labelText: "Description",
                            filled: true,
                          ),
                          onChanged: (value) {
                            setState(() => asset.info = value);
                          },
                          maxLines: 5,
                        ),
                        DropdownButtonFormField(
                          value: asset.holder,
                          decoration: const InputDecoration(
                            hintText: "Choose the owner organization",
                            labelText: "Owned by",
                            filled: true,
                          ),
                          items: LocalDataRepo.organizations!
                              .map<DropdownMenuItem<String>>(
                                  (org) => DropdownMenuItem<String>(
                                        value: org.mspID,
                                        child: Text(org.name),
                                      ))
                              .toList(),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Please choose an owner organization";
                            }
                            return null;
                          },
                          onChanged: (String? value) {
                            setState(() => asset.holder = value);
                          },
                        ),
                        SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _showLocationPicker,
                              style: ElevatedButton.styleFrom(
                                primary: Theme.of(context)
                                    .inputDecorationTheme
                                    .fillColor,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_pin,
                                    color: Theme.of(context).hintColor,
                                    size: 26,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Pick location",
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: Theme.of(context).hintColor),
                                  ),
                                ],
                              ),
                            )),
                        Column(
                          children: [
                            TextFormField(
                                initialValue: asset.tags.join(' '),
                                decoration: const InputDecoration(
                                  filled: true,
                                  hintText: "Separate tags with [space]",
                                  labelText: "Tags",
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please specify the device location";
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    if (value.trim().isEmpty) {
                                      asset.tags = [];
                                      return;
                                    }
                                    asset.tags = value.trim().split(' ');
                                  });
                                }),
                            MultiSelectChipDisplay(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                              ),
                              chipColor: Colors.teal,
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              items: asset.tags
                                  .map((tag) => MultiSelectItem(
                                        tag,
                                        "#$tag",
                                      ))
                                  .toList(),
                              onTap: (dynamic value) {
                                setState(() => asset.tags.remove(value));
                              },
                            )
                          ],
                        ),
                        SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed:
                                  decorateWithLoading(context, _submitAsset),
                              child: const Text("SUBMIT ASSET",
                                  style: TextStyle(fontSize: 20)),
                            )),
                      ].expand((widget) => [
                            widget,
                            const SizedBox(
                              height: 24,
                            )
                          ])
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitAsset() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (await AssetsController.upsertAsset(asset)) {
          NotificationsManager(IdentitiesRepo.organization!).
            subscribeToRequirementsViolationOf(asset.id);
          Navigator.pop(context);
        }
      } on Exception catch (e) {
        displayError(context, e);
      }
    }
  }

  Future<void> _showLocationPicker() async {
    final LocationResult? result =
        await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PlacePicker(
                  GlobalConfiguration().getValue("geo_location_api_key"),
                )));

    if (result != null) {
      setState(() {
        asset.location = Location()
          ..latitude = result.latLng!.latitude
          ..longitude = result.latLng!.longitude
          ..name = result.name;
      });
    } else {
      displayError(context, Exception("Location wasn't picked, please try again"));
    }
  }
}
