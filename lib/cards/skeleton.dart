import 'package:flutter/material.dart';
import 'package:genome_2133/cards/region.dart';
import 'dart:ui';

import '../home.dart';

class Window extends StatefulWidget {
  final Function updateParent;
  final String title;
  final Widget body;

  const Window({Key? key, required this.updateParent, required this.title, required this.body}) : super(key: key);

  @override
  State<Window> createState() => _Window();

  Offset getPosition() => const Offset(0, 0);

  void updatePosition(Offset newPosition) {}
}

class _Window extends State<Window> {
  bool isClosed = false;

  // turned off random placement so that it sits to right
  Offset position = Offset(
      ((window.physicalSize / window.devicePixelRatio).width -
          (window.physicalSize / window.devicePixelRatio).width / 3),
      ((window.physicalSize / window.devicePixelRatio).height -
          (window.physicalSize / window.devicePixelRatio).height / 2 - 225));

  getPosition() => position;

  void updatePosition(Offset newPosition) =>
      setState(() => position = newPosition);

  @override
  Widget build(BuildContext context) {
    if (isClosed) return Container();

    void riseStack() {
      // Change stack function
      if (widget == windows.last) return;

      // TODO: fix position swap bug
      /*windows.remove(widget);
      windows.add(widget);

      widget.updateParent();*/
    }

    Widget content = SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.height / 3,
      child: GestureDetector(
        onTap: () {
          riseStack();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Container(
                height: 40,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20
                        ),
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            onTap: () {
                              // TODO: add cleanup to home array
                              setState(() {
                                // need to handle cases where multiple cards?
                                if (widget.body is RegionCard) {
                                  (widget.body as RegionCard).centerMap();
                                }
                                isClosed = true;
                              });
                            },
                          )
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: widget.body,
                ),
              )
            ],
          ),
        ),
      ),
    );

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
          maxSimultaneousDrags: 1,
          feedback: Material(type: MaterialType.transparency, child: content),
          childWhenDragging: Container(),
          onDragEnd: (details) {
            updatePosition(details.offset);
            riseStack();
          },
          child: content),
    );
  }
}

extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}