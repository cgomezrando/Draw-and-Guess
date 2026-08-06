import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'results_page_model.dart';
export 'results_page_model.dart';

class ResultsPageWidget extends StatefulWidget {
  const ResultsPageWidget({super.key});

  static String routeName = 'ResultsPage';
  static String routePath = '/resultsPage';

  @override
  State<ResultsPageWidget> createState() => _ResultsPageWidgetState();
}

class _ResultsPageWidgetState extends State<ResultsPageWidget> {
  late ResultsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResultsPageModel());
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
