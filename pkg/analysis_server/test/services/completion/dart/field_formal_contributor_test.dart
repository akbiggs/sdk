// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/src/provisional/completion/dart/completion_dart.dart';
import 'package:analysis_server/src/services/completion/dart/field_formal_contributor.dart';
import 'package:analysis_server/src/services/completion/dart/suggestion_builder.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'completion_contributor_util.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FieldFormalContributorTest);
  });
}

@reflectiveTest
class FieldFormalContributorTest extends DartCompletionContributorTest {
  @override
  DartCompletionContributor createContributor(
    DartCompletionRequest request,
    SuggestionBuilder builder,
  ) {
    return FieldFormalContributor(request, builder);
  }

  /// https://github.com/dart-lang/sdk/issues/39028
  Future<void> test_mixin_constructor() async {
    addTestSource('''
mixin M {
  M(this.^);
}
''');
    await computeSuggestions();
    expect(suggestions, isEmpty);
  }

  Future<void> test_ThisExpression_constructor_param() async {
    // SimpleIdentifier  FieldFormalParameter  FormalParameterList
    addTestSource('''
        main() { }
        class I {X get f => new A();get _g => new A();}
        class A implements I {
          A(this.^) {}
          A.z() {}
          var b; X _c; static sb;
          X get d => new A();get _e => new A();
          // no semicolon between completion point and next statement
          set s1(I x) {} set _s2(I x) {m(null);}
          m(X x) {} I _n(X x) {}}
        class X{}''');
    await computeSuggestions();
    expect(replacementOffset, completionOffset);
    expect(replacementLength, 0);
    assertSuggestField('b', null);
    assertSuggestField('_c', 'X');
    assertNotSuggested('sb');
    assertNotSuggested('d');
    assertNotSuggested('_e');
    assertNotSuggested('f');
    assertNotSuggested('_g');
    assertNotSuggested('m');
    assertNotSuggested('_n');
    assertNotSuggested('s1');
    assertNotSuggested('_s2');
    assertNotSuggested('z');
    assertNotSuggested('I');
    assertNotSuggested('A');
    assertNotSuggested('X');
    assertNotSuggested('Object');
    assertNotSuggested('==');
  }

  Future<void> test_ThisExpression_constructor_param2() async {
    // SimpleIdentifier  FieldFormalParameter  FormalParameterList
    addTestSource('''
        main() { }
        class I {X get f => new A();get _g => new A();}
        class A implements I {
          A(this.b^) {}
          A.z() {}
          var b; X _c;
          X get d => new A();get _e => new A();
          // no semicolon between completion point and next statement
          set s1(I x) {} set _s2(I x) {m(null);}
          m(X x) {} I _n(X x) {}}
        class X{}''');
    await computeSuggestions();
    expect(replacementOffset, completionOffset - 1);
    expect(replacementLength, 1);
    assertSuggestField('b', null);
    assertSuggestField('_c', 'X');
    assertNotSuggested('d');
    assertNotSuggested('_e');
    assertNotSuggested('f');
    assertNotSuggested('_g');
    assertNotSuggested('m');
    assertNotSuggested('_n');
    assertNotSuggested('s1');
    assertNotSuggested('_s2');
    assertNotSuggested('z');
    assertNotSuggested('I');
    assertNotSuggested('A');
    assertNotSuggested('X');
    assertNotSuggested('Object');
    assertNotSuggested('==');
  }

  Future<void> test_ThisExpression_constructor_param3() async {
    // SimpleIdentifier  FieldFormalParameter  FormalParameterList
    addTestSource('''
        main() { }
        class I {X get f => new A();get _g => new A();}
        class A implements I {
          A(this.^b) {}
          A.z() {}
          var b; X _c;
          X get d => new A();get _e => new A();
          // no semicolon between completion point and next statement
          set s1(I x) {} set _s2(I x) {m(null);}
          m(X x) {} I _n(X x) {}}
        class X{}''');
    await computeSuggestions();
    expect(replacementOffset, completionOffset);
    expect(replacementLength, 1);
    assertSuggestField('b', null);
    assertSuggestField('_c', 'X');
    assertNotSuggested('d');
    assertNotSuggested('_e');
    assertNotSuggested('f');
    assertNotSuggested('_g');
    assertNotSuggested('m');
    assertNotSuggested('_n');
    assertNotSuggested('s1');
    assertNotSuggested('_s2');
    assertNotSuggested('z');
    assertNotSuggested('I');
    assertNotSuggested('A');
    assertNotSuggested('X');
    assertNotSuggested('Object');
    assertNotSuggested('==');
  }

  Future<void> test_ThisExpression_constructor_param4() async {
    // SimpleIdentifier  FieldFormalParameter  FormalParameterList
    addTestSource('''
        main() { }
        class I {X get f => new A();get _g => new A();}
        class A implements I {
          A(this.b, this.^) {}
          A.z() {}
          var b; X _c;
          X get d => new A();get _e => new A();
          // no semicolon between completion point and next statement
          set s1(I x) {} set _s2(I x) {m(null);}
          m(X x) {} I _n(X x) {}}
        class X{}''');
    await computeSuggestions();
    expect(replacementOffset, completionOffset);
    expect(replacementLength, 0);
    assertNotSuggested('b');
    assertSuggestField('_c', 'X');
    assertNotSuggested('d');
    assertNotSuggested('_e');
    assertNotSuggested('f');
    assertNotSuggested('_g');
    assertNotSuggested('m');
    assertNotSuggested('_n');
    assertNotSuggested('s1');
    assertNotSuggested('_s2');
    assertNotSuggested('z');
    assertNotSuggested('I');
    assertNotSuggested('A');
    assertNotSuggested('X');
    assertNotSuggested('Object');
    assertNotSuggested('==');
  }

  Future<void> test_ThisExpression_constructor_param_optional() async {
    // SimpleIdentifier  FieldFormalParameter  FormalParameterList
    addTestSource('''
        main() { }
        class Point {
          int x;
          int y;
          Point({this.x, this.^}) {}
          ''');
    await computeSuggestions();
    expect(replacementOffset, completionOffset);
    expect(replacementLength, 0);
    assertSuggestField('y', 'int');
    assertNotSuggested('x');
  }

  Future<void> test_ThisExpression_constructor_param_positional() async {
    // SimpleIdentifier  FieldFormalParameter  FormalParameterList
    addTestSource('''
        main() { }
        class Point {
          int x;
          int y;
          Point({this.x, this.^}) {}
          ''');
    await computeSuggestions();
    expect(replacementOffset, completionOffset);
    expect(replacementLength, 0);
    assertSuggestField('y', 'int');
    assertNotSuggested('x');
  }
}
