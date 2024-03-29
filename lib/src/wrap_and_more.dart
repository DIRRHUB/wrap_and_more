part of wrap_and_more;

/// A custom widget that extends Flutter's StatelessWidget and provides
/// a wrapped layout with an option to show an "overflow" widget when the
/// number of children exceeds a certain limit (maxRow).
///
/// The `WrapAndMore` widget lays out its children in a Wrap widget and
/// displays the specified `overflowWidget` when the children exceed the
/// maximum number of rows specified by the `maxRow` parameter. The number
/// of children to display is automatically determined based on the available
/// space within the Wrap.
///
/// The `overflowWidget` parameter is a function that takes an integer as input,
/// representing the number of remaining children beyond the `maxRow`, and
/// returns a widget to display as the "overflow" representation.
///
/// The `spacing` and `runSpacing` parameters control the spacing between
/// children in the Wrap.
///
/// The `children` parameter is a list of widgets to display within the Wrap.
///
/// Example Usage:
///
/// ```dart
/// WrapAndMore(
///   maxRow: 2,
///   spacing: 8.0,
///   runSpacing: 8.0,
///   overflowWidget: (restChildrenCount) {
///     return Text(
///       '+ $restChildrenCount more',
///       style: TextStyle(color: Colors.grey),
///     );
///   },
///   children: [
///     // Add your widgets here
///   ],
/// )
/// ```
class WrapAndMore extends StatelessWidget {
  /// The maximum number of rows to show within the Wrap.
  final int maxRow;

  /// The spacing between children in the Wrap.
  final double spacing;

  /// The run spacing between rows of children in the Wrap.
  final double runSpacing;

  /// A function that takes the number of remaining children beyond `maxRow`
  /// as input and returns a widget to represent the "overflow" children.
  final Widget Function(int restChildrenCount) overflowWidget;

  /// The list of widgets to display within the Wrap.
  final List<Widget> children;

  final EdgeInsets? contentPadding;

  /// Creates a WrapAndMore widget.
  ///
  /// The `maxRow` parameter specifies the maximum number of rows to display
  /// in the Wrap. The `spacing` and `runSpacing` parameters control the
  /// spacing between children in the Wrap.
  ///
  /// The `overflowWidget` parameter is a function that takes an integer as
  /// input, representing the number of remaining children beyond the `maxRow`,
  /// and returns a widget to display as the "overflow" representation.
  ///
  /// The `children` parameter is a list of widgets to display within the Wrap.
  const WrapAndMore({
    Key? key,
    required this.maxRow,
    this.spacing = 0.0,
    this.runSpacing = 0.0,
    required this.overflowWidget,
    required this.children,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey rowKey = GlobalKey();
    return GetBuilder(
      key: ObjectKey(children),
      init: WrapAndMoreController()..initData(children: children, key: rowKey, maxRow: maxRow, spacing: spacing),
      builder: (controller) {
        return Obx(() {
          if (controller.isCounted.value) {
            return MeasureSize(
              onChange: (size) {
                controller.updateWrapArea(size);
                overflowWidget(controller.showChildCount.value);
              },
              child: SizedBox(
                height: (controller.overflowSize.height * maxRow) +
                    (runSpacing * (maxRow - 1)) +
                    (contentPadding?.vertical ?? 0) * 2,
                child: Column(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: spacing,
                        runSpacing: runSpacing,
                        children: controller.isRendered.value
                            ? children.take(controller.showChildCount.value).toList()
                            : children.toList(),
                      ),
                    ),
                    if (children.length - controller.showChildCount.value > 0 && controller.isRendered.value)
                      overflowWidget(children.length - controller.showChildCount.value)
                  ],
                ),
              ),
            );
          }
          return SizedBox(
            width: 100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                key: rowKey,
                children: [
                  ...children
                      .asMap()
                      .map((index, Widget value) {
                        return MapEntry(
                            index,
                            MeasureSize(
                              onChange: (Size size) {
                                controller.updateChildrenSize(index, size);
                              },
                              child: Padding(
                                padding: contentPadding ?? EdgeInsets.zero,
                                child: value,
                              ),
                            ));
                      })
                      .values
                      .toList(),
                  MeasureSize(
                    child: overflowWidget(0),
                    onChange: (p0) {
                      controller.updateOverflowSize(p0);
                    },
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
