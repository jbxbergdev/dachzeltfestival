
import 'package:dachzeltfestival/di/injector.dart';
import 'package:dachzeltfestival/view/legal/legal_viewmodel.dart';
import 'package:dachzeltfestival/view/markdown_view.dart';
import 'package:flutter/cupertino.dart';

class Legal extends StatelessWidget {

  Legal(Key key): super(key: key);

  @override
  Widget build(BuildContext context) => MarkdownView(inject<LegalViewModel>().legalMarkdown());

}