/*
Name: Akshath Jain
Date: 3/18/19
Purpose: defines the package: grouped_buttons
Copyright: © 2019, Akshath Jain. All rights reserved.
Licensing: More information can be found here: https://github.com/akshathjain/sliding_up_panel/blob/master/LICENSE
*/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

Future<TestGesture> _pumpPanelAndStartDrag(
  WidgetTester tester, {
  required PanelController controller,
  required bool Function() showPanel,
  required void Function(StateSetter) captureSetState,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setter) {
            captureSetState(setter);
            return Stack(
              children: [
                if (showPanel())
                  SlidingUpPanel(
                    controller: controller,
                    defaultPanelState: PanelState.OPEN,
                    minHeight: 100,
                    maxHeight: 300,
                    panelBuilder: (sc) =>
                        Container(key: const Key('panel'), color: Colors.blue),
                    body: Container(),
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );

  final gesture = await tester
      .startGesture(tester.getCenter(find.byKey(const Key('panel'))));
  await tester.pump(const Duration(milliseconds: 16));
  await gesture.moveBy(const Offset(0, -20));
  await tester.pump(const Duration(milliseconds: 16));
  return gesture;
}

void main() {
  testWidgets(
      'does not crash on pointer-up when the panel is removed from the tree mid-drag',
      (WidgetTester tester) async {
    final controller = PanelController();
    bool showPanel = true;
    late StateSetter setState;

    final gesture = await _pumpPanelAndStartDrag(
      tester,
      controller: controller,
      showPanel: () => showPanel,
      captureSetState: (setter) => setState = setter,
    );

    setState(() => showPanel = false);
    await tester.pump();

    await gesture.up();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'does not crash on pointer-move when the panel is removed from the tree mid-drag',
      (WidgetTester tester) async {
    final controller = PanelController();
    bool showPanel = true;
    late StateSetter setState;

    final gesture = await _pumpPanelAndStartDrag(
      tester,
      controller: controller,
      showPanel: () => showPanel,
      captureSetState: (setter) => setState = setter,
    );

    setState(() => showPanel = false);
    await tester.pump();

    await gesture.moveBy(const Offset(0, -20));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
