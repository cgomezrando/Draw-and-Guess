import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'local_game_page_model.dart';
export 'local_game_page_model.dart';

class LocalGamePageWidget extends StatefulWidget {
  const LocalGamePageWidget({super.key});

  static String routeName = 'LocalGamePage';
  static String routePath = '/localGamePage';

  @override
  State<LocalGamePageWidget> createState() => _LocalGamePageWidgetState();
}

class _LocalGamePageWidgetState extends State<LocalGamePageWidget> {
  late LocalGamePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LocalGamePageModel());
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
        backgroundColor: Colors.white,
        body: Align(
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: custom_widgets.LocalGame(
                width: double.infinity,
                height: double.infinity,
                onGameEnd: () async {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}
