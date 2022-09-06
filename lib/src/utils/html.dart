class IFrameElement {
  String src;
  CssStyleDeclaration style;
  IFrameElement()
      : src = '',
        style = CssStyleDeclaration();
}

class CssStyleDeclaration {
  String border;
  String width;
  String height;
  CssStyleDeclaration({
    this.border = '',
    this.width = '',
    this.height = '',
  });
}

class PlatformViewRegistry {
  void registerViewFactory(
    String id,
    IFrameElement Function(int id) callBack,
  ) {}
}

final platformViewRegistry = PlatformViewRegistry();
