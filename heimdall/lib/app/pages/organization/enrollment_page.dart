import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chainmetric/app/theme/theme.dart';
import 'package:chainmetric/app/utils/utils.dart' as utils;
import 'package:chainmetric/app/widgets/common/form_button_widget.dart';
import 'package:chainmetric/app/widgets/common/form_dropdown_widget.dart';
import 'package:chainmetric/infrastructure/repositories/certificates_vault.dart';
import 'package:chainmetric/infrastructure/services/admin_grpc.dart';
import 'package:chainmetric/models/generated/google/protobuf/timestamp.pb.dart';
import 'package:chainmetric/models/identity/admin.pb.dart';
import 'package:chainmetric/models/identity/user.dart';
import 'package:chainmetric/models/identity/user.pb.dart';
import 'package:chainmetric/platform/repositories/identities_shared.dart';
import 'package:chainmetric/platform/repositories/localdata_json.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';

class EnrollUserPage extends StatefulWidget {
  final User user;
  final Function(BuildContext)? onEnroll;

  const EnrollUserPage(this.user, {Key? key, this.onEnroll}) : super(key: key);

  @override
  _EnrollUserPageState createState() => _EnrollUserPageState();
}

class _EnrollUserPageState extends State<EnrollUserPage> {
  EnrollUserRequest request = EnrollUserRequest();
  bool isTransient = false;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final AppUser adminIdentity;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Scaffold(
        key: scaffoldKey,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                height:
                    max(100, 250 - MediaQuery.of(context).viewInsets.bottom),
                alignment: Alignment.center,
                decoration: const BoxDecoration(),
                child: AutoSizeText(
                  "Enroll\n${widget.user.firstname} ${widget.user.lastname}",
                  textAlign: TextAlign.center,
                  style: AppTheme.title1
                      .override(fontFamily: "IBM Plex Mono", fontSize: 44),
                ),
              ),
              Expanded(
                child: Column(children: [
                  ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: FormDropDownWidget(
                        height: 50,
                        icon: const Icon(
                          Icons.corporate_fare_sharp,
                        ),
                        initialOption: request.role,
                        elevation: 2,
                        borderColor: Colors.transparent,
                        borderWidth: 0,
                        borderRadius: 8,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        items: LocalDataRepo.userRoles!
                            .map<DropdownMenuItem<String>>(
                                (role) => DropdownMenuItem<String>(
                                      value: role,
                                      child: Text(role),
                                    ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => request.role = value!);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text("Temporary contractor"),
                          Checkbox(
                            value: isTransient,
                            activeColor: Theme.of(context).primaryColor,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6))),
                            onChanged: (value) {
                              setState(() {
                                isTransient = value!;
                                if (!isTransient) {
                                  request.clearExpireAt();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: isTransient,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            filled: true,
                            hintText: "Enter your expiry date",
                            labelText: "Expiry date",
                            enabledBorder: UnderlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                          ),
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (isTransient && value!.isEmpty) {
                              return "You must provide your expiry date for temporary contractors";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() => request.expireAt = Timestamp(
                                seconds: Int64(DateTime.parse(value).second)));
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: FormButtonWidget(
                        onPressed: submitRegistration,
                        text: "CONFIRM",
                        options: FormButtonOptions(
                          width: 200,
                          height: 50,
                          color: AppTheme.primaryColor,
                          textStyle: AppTheme.subtitle2.override(
                            fontFamily: 'Roboto Mono',
                            color: AppTheme.inputBG,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 3,
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                          borderRadius: 12,
                        ),
                      ),
                    )
                  ].expand((widget) => [
                        widget,
                        const SizedBox(
                          height: 12,
                        )
                      ])
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    adminIdentity = IdentitiesRepo.current!;
    request
      ..role = "Engineer"
        ..userID = widget.user.id;
  }

  Future<void> submitRegistration() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      await AdminService(adminIdentity.organization,
              certificate: await CertificatesResolver(adminIdentity.organization)
                  .resolveBytes("identity-client"),
          accessToken: adminIdentity.accessToken)
          .enrollUser(request);
    } on Exception catch (e) {
      utils.displayError(context, e);
    }

    widget.onEnroll?.call(context);
  }
}
