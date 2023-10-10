import 'package:flutter/widgets.dart' hide InteractiveViewer;

@immutable
class PainterTransformer extends StatefulWidget {
  const PainterTransformer({
    Key? key,
    this.maxScale = 3,
    this.minScale = 0.8,
    this.onInteractionEnd,
    this.onInteractionStart,
    this.onInteractionUpdate,
    required this.child,
  }) : super(key: key);

  final Widget child;

  final double maxScale;
  final double minScale;

  final GestureScaleEndCallback? onInteractionEnd;
  final GestureScaleStartCallback? onInteractionStart;
  final GestureScaleUpdateCallback? onInteractionUpdate;

  @override
  State<PainterTransformer> createState() => _PainterTransformerState();
}

class _PainterTransformerState extends State<PainterTransformer> {
  TransformationController? _transformationController;

  final GlobalKey _childKey = GlobalKey();
  final GlobalKey _parentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      key: _parentKey,
      child: GestureDetector(
        onScaleEnd: _onScaleEnd,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        child: Transform(
          transform: _transformationController!.value,
          child: KeyedSubtree(
            key: _childKey,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (widget.onInteractionStart != null) {
      widget.onInteractionStart!(details);
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (widget.onInteractionUpdate != null) {
      widget.onInteractionUpdate!(ScaleUpdateDetails(
        focalPoint: _transformationController!.toScene(
          details.localFocalPoint,
        ),
        scale: details.scale,
        rotation: details.rotation,
      ));
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (widget.onInteractionEnd != null) {
      widget.onInteractionEnd!(details);
    }
  }
}
