import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';

class WindowsTitleBar extends StatelessWidget {
  const WindowsTitleBar({
    super.key,
    required this.onAboutPressed,
    required this.backgroundColor,
    this.wrapWithWindowFrame = true,
    this.showWindowButtons = true,
  });

  final VoidCallback onAboutPressed;
  final Color backgroundColor;
  final bool wrapWithWindowFrame;
  final bool showWindowButtons;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: 46,
      color: backgroundColor,
      child: Row(
        children: <Widget>[
          const SizedBox(width: 12),
          const Icon(FluentIcons.lightning_bolt, size: 18),
          const SizedBox(width: 8),
          const Text('ZapTweaks'),
          const SizedBox(width: 6),
          Text(
            'by PrimeBuild',
            style: FluentTheme.of(context).typography.caption?.copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w100,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: MoveWindow(child: const SizedBox.expand())),
          IconButton(
            icon: const Icon(FluentIcons.info),
            onPressed: onAboutPressed,
          ),
          if (showWindowButtons)
            MinimizeWindowButton(colors: _windowButtonColors()),
          if (showWindowButtons)
            MaximizeWindowButton(colors: _windowButtonColors()),
          if (showWindowButtons)
            CloseWindowButton(colors: _windowButtonColors()),
        ],
      ),
    );

    if (!wrapWithWindowFrame) {
      return content;
    }

    return WindowTitleBarBox(child: content);
  }

  WindowButtonColors _windowButtonColors() {
    return WindowButtonColors(
      iconNormal: Colors.white,
      iconMouseOver: Colors.white,
      iconMouseDown: Colors.white,
      mouseOver: const Color(0x1FFFFFFF),
      mouseDown: const Color(0x26FFFFFF),
      normal: Colors.transparent,
    );
  }
}
