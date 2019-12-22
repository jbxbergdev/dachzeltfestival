
import 'package:dachzeltfestival/view/legal/legal_viewmodel.dart';
import 'package:dachzeltfestival/view/markdown_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:inject/inject.dart';

typedef Provider<T> = T Function();

@provide
class LegalBuilder {
  final Provider<LegalViewModel> _vmProvider;

  LegalBuilder(this._vmProvider);

  Legal build(Key key) => Legal(_vmProvider());
}

class Legal extends StatelessWidget {

  final LegalViewModel _legalViewModel;

  Legal(this._legalViewModel);

  @override
  Widget build(BuildContext context) => MarkdownView(_legalViewModel.legalMarkdown());

}