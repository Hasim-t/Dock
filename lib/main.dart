import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> with TickerProviderStateMixin {
  late final List<T> _items = widget.items.toList();
  int? draggedIndex;
  double? dragPosition;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _buildDockItems(),
      ),
    );
  }

  List<Widget> _buildDockItems() {
    return List.generate(_items.length, (index) {
      return DragTarget<int>(
        onWillAccept: (receivedIndex) =>
            receivedIndex != null && receivedIndex != index,
        onAccept: (oldIndex) {
          setState(() {
            final item = _items[oldIndex];
            _items.removeAt(oldIndex);
            _items.insert(index, item);
            draggedIndex = null;
            dragPosition = null;
          });
        },
        builder: (context, candidateData, rejectedData) {
          return Draggable<int>(
            data: index,
            feedback: Material(
              color: Colors.transparent,
              child: MouseRegion(
                child: _buildDockItem(index, true),
              ),
            ),
            onDragStarted: () {
              setState(() => draggedIndex = index);
            },
            onDragEnd: (_) {
              setState(() {
                draggedIndex = null;
                dragPosition = null;
              });
            },
            onDragUpdate: (details) {
              setState(() {
                dragPosition = details.localPosition.dx;
              });
            },
            childWhenDragging: SizedBox(
              width: 64,
              child: Opacity(
                opacity: 0.3,
                child: _buildDockItem(index, false),
              ),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: _getItemWidth(index).toDouble(),
              child: MouseRegion(
                onEnter: (_) => setState(() => draggedIndex = index),
                onExit: (_) => setState(() {
                  if (draggedIndex == index) {
                    draggedIndex = null;
                  }
                }),
                child: _buildDockItem(index, false),
              ),
            ),
          );
        },
      );
    });
  }

  num _getItemWidth(int index) {
    if (draggedIndex == null) {
      return 64; // Default width
    }

    const maxWidth = 76;
    const minWidth = 48;
    const distanceFactor = 12; // Difference in size between adjacent items

    final distance = (index - draggedIndex!).abs();
    final width = maxWidth - distance * distanceFactor;

    // Ensure the width is within the min and max bounds
    return width.clamp(minWidth, maxWidth);
  }

  Widget _buildDockItem(int index, bool isDragging) {
    final scale = isDragging ? 1.2 : (draggedIndex == index ? 1.2 : 1.0);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 1.0, end: scale),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: widget.builder(_items[index]),
    );
  }
}
