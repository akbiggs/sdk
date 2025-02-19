// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/src/protocol_server.dart';
import 'package:analysis_server/src/provisional/completion/dart/completion_dart.dart';
import 'package:analysis_server/src/services/completion/dart/label_contributor.dart';
import 'package:analysis_server/src/services/completion/dart/suggestion_builder.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'completion_contributor_util.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(LabelContributorTest);
  });
}

@reflectiveTest
class LabelContributorTest extends DartCompletionContributorTest {
  CompletionSuggestion assertSuggestLabel(String name,
      {CompletionSuggestionKind kind = CompletionSuggestionKind.IDENTIFIER}) {
    var cs = assertSuggest(name, csKind: kind);
    expect(cs.returnType, isNull);
    var element = cs.element!;
    expect(element.flags, 0);
    expect(element.kind, equals(ElementKind.LABEL));
    expect(element.name, equals(name));
    expect(element.parameters, isNull);
    expect(element.returnType, isNull);
    assertHasNoParameterInfo(cs);
    return cs;
  }

  @override
  DartCompletionContributor createContributor(
    DartCompletionRequest request,
    SuggestionBuilder builder,
  ) {
    return LabelContributor(request, builder);
  }

  Future<void> test_break_ignores_outer_functions_using_closure() async {
    addTestSource('''
void main() {
  foo: while (true) {
    var f = () {
      bar: while (true) { break ^ }
    };
  }
}
''');
    await computeSuggestions();
    // Labels in outer functions are never accessible.
    assertSuggestLabel('bar');
    assertNotSuggested('foo');
  }

  Future<void> test_break_ignores_outer_functions_using_local_function() async {
    addTestSource('''
void main() {
  foo: while (true) {
    void f() {
      bar: while (true) { break ^ }
    };
  }
}
''');
    await computeSuggestions();
    // Labels in outer functions are never accessible.
    assertSuggestLabel('bar');
    assertNotSuggested('foo');
  }

  Future<void> test_break_ignores_toplevel_variables() async {
    addTestSource('''
int x;
void main() {
  while (true) {
    break ^
  }
}
''');
    await computeSuggestions();
    assertNotSuggested('x');
  }

  Future<void> test_break_ignores_unrelated_statements() async {
    addTestSource('''
void main() {
  foo: while (true) {}
  while (true) { break ^ }
  bar: while (true) {}
}
''');
    await computeSuggestions();
    // The scope of the label defined by a labeled statement is just the
    // statement itself, so neither "foo" nor "bar" are in scope at the caret
    // position.
    assertNotSuggested('foo');
    assertNotSuggested('bar');
  }

  Future<void> test_break_to_enclosing_loop() async {
    addTestSource('''
void main() {
  foo: while (true) {
    bar: while (true) {
      break ^
    }
  }
}
''');
    await computeSuggestions();
    assertSuggestLabel('foo');
    assertSuggestLabel('bar');
  }

  Future<void> test_continue_from_loop_to_switch() async {
    addTestSource('''
void main() {
  switch (x) {
    foo: case 1:
      break;
    bar: case 2:
      while (true) {
        continue ^;
      }
      break;
    baz: case 3:
      break;
  }
}
''');
    await computeSuggestions();
    assertSuggestLabel('foo');
    assertSuggestLabel('bar');
    assertSuggestLabel('baz');
  }

  Future<void> test_continue_from_switch_to_loop() async {
    addTestSource('''
void main() {
  foo: while (true) {
    switch (x) {
      case 1:
        continue ^;
    }
  }
}
''');
    await computeSuggestions();
    assertSuggestLabel('foo');
  }

  Future<void>
      test_continue_ignores_outer_functions_using_closure_with_loop() async {
    addTestSource('''
void main() {
  foo: while (true) {
    var f = () {
      bar: while (true) { continue ^ }
    };
  }
}
''');
    await computeSuggestions();
    // Labels in outer functions are never accessible.
    assertSuggestLabel('bar');
    assertNotSuggested('foo');
  }

  Future<void>
      test_continue_ignores_outer_functions_using_closure_with_switch() async {
    addTestSource('''
void main() {
  switch (x) {
    foo: case 1:
      var f = () {
        bar: while (true) { continue ^ }
      };
  }
}
''');
    await computeSuggestions();
    // Labels in outer functions are never accessible.
    assertSuggestLabel('bar');
    assertNotSuggested('foo');
  }

  Future<void>
      test_continue_ignores_outer_functions_using_local_function_with_loop() async {
    addTestSource('''
void main() {
  foo: while (true) {
    void f() {
      bar: while (true) { continue ^ }
    };
  }
}
''');
    await computeSuggestions();
    // Labels in outer functions are never accessible.
    assertSuggestLabel('bar');
    assertNotSuggested('foo');
  }

  Future<void>
      test_continue_ignores_outer_functions_using_local_function_with_switch() async {
    addTestSource('''
void main() {
  switch (x) {
    foo: case 1:
      void f() {
        bar: while (true) { continue ^ }
      };
  }
}
''');
    await computeSuggestions();
    // Labels in outer functions are never accessible.
    assertSuggestLabel('bar');
    assertNotSuggested('foo');
  }

  Future<void> test_continue_ignores_unrelated_statements() async {
    addTestSource('''
void main() {
  foo: while (true) {}
  while (true) { continue ^ }
  bar: while (true) {}
}
''');
    await computeSuggestions();
    // The scope of the label defined by a labeled statement is just the
    // statement itself, so neither "foo" nor "bar" are in scope at the caret
    // position.
    assertNotSuggested('foo');
    assertNotSuggested('bar');
  }

  Future<void> test_continue_to_earlier_case() async {
    addTestSource('''
void main() {
  switch (x) {
    foo: case 1:
      break;
    case 2:
      continue ^;
    case 3:
      break;
''');
    await computeSuggestions();
    assertSuggestLabel('foo');
  }

  Future<void> test_continue_to_enclosing_loop() async {
    addTestSource('''
void main() {
  foo: while (true) {
    bar: while (true) {
      continue ^
    }
  }
}
''');
    await computeSuggestions();
    assertSuggestLabel('foo');
    assertSuggestLabel('bar');
  }

  Future<void> test_continue_to_enclosing_switch() async {
    addTestSource('''
void main() {
  switch (x) {
    foo: case 1:
      break;
    bar: case 2:
      switch (y) {
        case 1:
          continue ^;
      }
      break;
    baz: case 3:
      break;
  }
}
''');
    await computeSuggestions();
    assertSuggestLabel('foo');
    assertSuggestLabel('bar');
    assertSuggestLabel('baz');
  }

  Future<void> test_continue_to_later_case() async {
    addTestSource('''
void main() {
  switch (x) {
    case 1:
      break;
    case 2:
      continue ^;
    foo: case 3:
      break;
''');
    await computeSuggestions();
    assertSuggestLabel('foo');
  }

  Future<void> test_continue_to_same_case() async {
    addTestSource('''
void main() {
  switch (x) {
    case 1:
      break;
    foo: case 2:
      continue ^;
    case 3:
      break;
''');
    await computeSuggestions();
    assertSuggestLabel('foo');
  }
}
