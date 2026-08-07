import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'online_game_page_model.dart';
export 'online_game_page_model.dart';

class OnlineGamePageWidget extends StatefulWidget {
  const OnlineGamePageWidget({super.key});

  static String routeName = 'OnlineGamePage';
  static String routePath = '/onlineGamePage';

  @override
  State<OnlineGamePageWidget> createState() => _OnlineGamePageWidgetState();
}

class _OnlineGamePageWidgetState extends State<OnlineGamePageWidget> {
  late OnlineGamePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OnlineGamePageModel());
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
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: custom_widgets.OnlineGame(
              width: double.infinity,
              height: double.infinity,
              onFinish: () async {
                context.pushNamed(ResultsPageWidget.routeName);
              },
            ),
          ),
        ),
      ),
    );
  }
}
