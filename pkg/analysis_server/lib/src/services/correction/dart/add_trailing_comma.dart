// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/src/services/correction/dart/abstract_producer.dart';
import 'package:analysis_server/src/services/correction/fix.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

class AddTrailingComma extends CorrectionProducer {
  @override
  bool get canBeAppliedInBulk => true;

  @override
  bool get canBeAppliedToFile => true;

  @override
  FixKind get fixKind => DartFixKind.ADD_TRAILING_COMMA;

  @override
  FixKind get multiFixKind => DartFixKind.ADD_TRAILING_COMMA_MULTI;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node;
    if (node is! ArgumentList) return;
    final parent = node.parent;
    if (parent == null) return;

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleInsertion(node.arguments.last.end, ',');
    });
  }

  /// Return an instance of this class. Used as a tear-off in `FixProcessor`.
  static AddTrailingComma newInstance() => AddTrailingComma();
}
