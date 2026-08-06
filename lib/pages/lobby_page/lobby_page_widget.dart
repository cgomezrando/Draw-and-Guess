import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'lobby_page_model.dart';
export 'lobby_page_model.dart';

class LobbyPageWidget extends StatefulWidget {
  const LobbyPageWidget({super.key});

  static String routeName = 'LobbyPage';
  static String routePath = '/lobbyPage';

  @override
  State<LobbyPageWidget> createState() => _LobbyPageWidgetState();
}

class _LobbyPageWidgetState extends State<LobbyPageWidget> {
  late LobbyPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LobbyPageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [],
        ),
      ),
    );
  }
}
