"""
  Automatically generated!
  Fixture test cases from tests/fixtures/meta-programming
"""
namespace BooJs.Tests

import BooJs.Tests.Support
import NUnit.Framework

[TestFixture]
class MetaprogrammingFixtures:

  [Test]
  def test_CodeReifierMergeIntoWithEmptyArrayLiteral():
    FixtureRunner.run('tests/fixtures/meta-programming/CodeReifierMergeIntoWithEmptyArrayLiteral.boo')

  [Test]
  def test_CodeReifierMergeIntoWithEvent():
    FixtureRunner.run('tests/fixtures/meta-programming/CodeReifierMergeIntoWithEvent.boo')

  [Test]
  def test_CodeReifierMergeIntoWithGenerators():
    FixtureRunner.run('tests/fixtures/meta-programming/CodeReifierMergeIntoWithGenerators.boo')

  [Test]
  def test_CodeReifierMergeIntoWithMacros():
    FixtureRunner.run('tests/fixtures/meta-programming/CodeReifierMergeIntoWithMacros.boo')

  [Test]
  def test_CodeReifierMergeIntoWithMultipleMethods():
    FixtureRunner.run('tests/fixtures/meta-programming/CodeReifierMergeIntoWithMultipleMethods.boo')

  [Test]
  def test_CodeReifierMergeIntoWithMultipleProperties():
    FixtureRunner.run('tests/fixtures/meta-programming/CodeReifierMergeIntoWithMultipleProperties.boo')

  [Test]
  def test_CodeReifierMergeIntoWithNestedGenericStruct():
    FixtureRunner.run('tests/fixtures/meta-programming/CodeReifierMergeIntoWithNestedGenericStruct.boo')

  [Test]
  def test_CodeReifierMergeIntoWithNestedTypes():
    FixtureRunner.run('tests/fixtures/meta-programming/CodeReifierMergeIntoWithNestedTypes.boo')

  [Test]
  def test_CodeReifierMergeIntoWithNestedTypesInDifferentOrder():
    FixtureRunner.run('tests/fixtures/meta-programming/CodeReifierMergeIntoWithNestedTypesInDifferentOrder.boo')

  [Test]
  def test_CodeReifierMergeIntoWithProperties():
    FixtureRunner.run('tests/fixtures/meta-programming/CodeReifierMergeIntoWithProperties.boo')

  [Test]
  def test_CodeReifierMergeIntoWithStatementModifiers():
    FixtureRunner.run('tests/fixtures/meta-programming/CodeReifierMergeIntoWithStatementModifiers.boo')

  [Test]
  def test_auto_lift_1():
    FixtureRunner.run('tests/fixtures/meta-programming/auto-lift-1.boo')

  [Test]
  def test_auto_lift_2():
    FixtureRunner.run('tests/fixtures/meta-programming/auto-lift-2.boo')

  [Test]
  def test_block_lift():
    FixtureRunner.run('tests/fixtures/meta-programming/block-lift.boo')

  [Test]
  def test_class_body_splicing_1():
    FixtureRunner.run('tests/fixtures/meta-programming/class-body-splicing-1.boo')

  [Test]
  def test_class_name_splicing_1():
    FixtureRunner.run('tests/fixtures/meta-programming/class-name-splicing-1.boo')

  [Test]
  def test_class_name_splicing_2():
    FixtureRunner.run('tests/fixtures/meta-programming/class-name-splicing-2.boo')

  [Test]
  def test_compile_1():
    FixtureRunner.run('tests/fixtures/meta-programming/compile-1.boo')

  [Test]
  def test_compile_2():
    FixtureRunner.run('tests/fixtures/meta-programming/compile-2.boo')

  [Test]
  def test_field_splicing_1():
    FixtureRunner.run('tests/fixtures/meta-programming/field-splicing-1.boo')

  [Test]
  def test_field_splicing_in_expression_becomes_reference_to_field():
    FixtureRunner.run('tests/fixtures/meta-programming/field-splicing-in-expression-becomes-reference-to-field.boo')

  [Test]
  def test_field_splicing_null_initializer():
    FixtureRunner.run('tests/fixtures/meta-programming/field-splicing-null-initializer.boo')

  [Test]
  def test_generic_splicing_1():
    FixtureRunner.run('tests/fixtures/meta-programming/generic-splicing-1.boo')

  [Test]
  def test_interpolation_splicing_1():
    FixtureRunner.run('tests/fixtures/meta-programming/interpolation-splicing-1.boo')

  [Test]
  def test_interpolation_splicing_2():
    FixtureRunner.run('tests/fixtures/meta-programming/interpolation-splicing-2.boo')

  [Test]
  def test_lexical_info_is_preserved():
    FixtureRunner.run('tests/fixtures/meta-programming/lexical-info-is-preserved.boo')

  [Test]
  def test_macro_yielding_selective_import():
    FixtureRunner.run('tests/fixtures/meta-programming/macro-yielding-selective-import.boo')

  [Test]
  def test_macro_yielding_types_shouldnt_cause_module_class_to_be_defined():
    FixtureRunner.run('tests/fixtures/meta-programming/macro-yielding-types-shouldnt-cause-module-class-to-be-defined.boo')

  [Test]
  def test_macro_yielding_varargs():
    FixtureRunner.run('tests/fixtures/meta-programming/macro-yielding-varargs.boo')

  [Test]
  def test_meta_methods_1():
    FixtureRunner.run('tests/fixtures/meta-programming/meta-methods-1.boo')

  [Test]
  def test_meta_methods_2():
    FixtureRunner.run('tests/fixtures/meta-programming/meta-methods-2.boo')

  [Test]
  def test_meta_methods_3():
    FixtureRunner.run('tests/fixtures/meta-programming/meta-methods-3.boo')

  [Test]
  def test_meta_methods_4():
    FixtureRunner.run('tests/fixtures/meta-programming/meta-methods-4.boo')

  [Test]
  def test_meta_methods_5():
    FixtureRunner.run('tests/fixtures/meta-programming/meta-methods-5.boo')

  [Test]
  def test_meta_methods_6():
    FixtureRunner.run('tests/fixtures/meta-programming/meta-methods-6.boo')

  [Test]
  def test_meta_methods_can_return_null():
    FixtureRunner.run('tests/fixtures/meta-programming/meta-methods-can-return-null.boo')

  [Test]
  def test_meta_methods_with_closure():
    FixtureRunner.run('tests/fixtures/meta-programming/meta-methods-with-closure.boo')

  [Test]
  def test_meta_methods_with_generator():
    FixtureRunner.run('tests/fixtures/meta-programming/meta-methods-with-generator.boo')

  [Test]
  def test_meta_methods_with_macro():
    FixtureRunner.run('tests/fixtures/meta-programming/meta-methods-with-macro.boo')

  [Test]
  def test_meta_methods_with_modifier_inside_closure():
    FixtureRunner.run('tests/fixtures/meta-programming/meta-methods-with-modifier-inside-closure.boo')

  [Test]
  def test_meta_methods_with_statement_modifier():
    FixtureRunner.run('tests/fixtures/meta-programming/meta-methods-with-statement-modifier.boo')

  [Test]
  def test_name_splicing_1():
    FixtureRunner.run('tests/fixtures/meta-programming/name-splicing-1.boo')

  [Test]
  def test_name_splicing_2():
    FixtureRunner.run('tests/fixtures/meta-programming/name-splicing-2.boo')

  [Test]
  def test_name_splicing_3():
    FixtureRunner.run('tests/fixtures/meta-programming/name-splicing-3.boo')

  [Test]
  def test_name_splicing_4():
    FixtureRunner.run('tests/fixtures/meta-programming/name-splicing-4.boo')

  [Test]
  def test_name_splicing_5():
    FixtureRunner.run('tests/fixtures/meta-programming/name-splicing-5.boo')

  [Test]
  def test_name_splicing_6():
    FixtureRunner.run('tests/fixtures/meta-programming/name-splicing-6.boo')

  [Test]
  def test_parameter_splicing_1():
    FixtureRunner.run('tests/fixtures/meta-programming/parameter-splicing-1.boo')

  [Test]
  def test_parameter_splicing_2():
    FixtureRunner.run('tests/fixtures/meta-programming/parameter-splicing-2.boo')

  [Test]
  def test_parameter_splicing_3():
    FixtureRunner.run('tests/fixtures/meta-programming/parameter-splicing-3.boo')

  [Test]
  def test_property_splicing_1():
    FixtureRunner.run('tests/fixtures/meta-programming/property-splicing-1.boo')

  [Test]
  def test_quasi_quotation_1():
    FixtureRunner.run('tests/fixtures/meta-programming/quasi-quotation-1.boo')

  [Test]
  def test_quasi_quotation_2():
    FixtureRunner.run('tests/fixtures/meta-programming/quasi-quotation-2.boo')

  [Test]
  def test_quasi_quotation_3():
    FixtureRunner.run('tests/fixtures/meta-programming/quasi-quotation-3.boo')

  [Test]
  def test_quasi_quotation_4():
    FixtureRunner.run('tests/fixtures/meta-programming/quasi-quotation-4.boo')

  [Test]
  def test_reification_1():
    FixtureRunner.run('tests/fixtures/meta-programming/reification-1.boo')

  [Test]
  def test_splicing_1():
    FixtureRunner.run('tests/fixtures/meta-programming/splicing-1.boo')

  [Test]
  def test_splicing_2():
    FixtureRunner.run('tests/fixtures/meta-programming/splicing-2.boo')

  [Test]
  def test_splicing_3():
    FixtureRunner.run('tests/fixtures/meta-programming/splicing-3.boo')

  [Test]
  def test_splicing_4():
    FixtureRunner.run('tests/fixtures/meta-programming/splicing-4.boo')

  [Test]
  def test_splicing_5():
    FixtureRunner.run('tests/fixtures/meta-programming/splicing-5.boo')

  [Test]
  def test_splicing_6():
    FixtureRunner.run('tests/fixtures/meta-programming/splicing-6.boo')

  [Test]
  def test_splicing_7():
    FixtureRunner.run('tests/fixtures/meta-programming/splicing-7.boo')

  [Test]
  def test_splicing_8():
    FixtureRunner.run('tests/fixtures/meta-programming/splicing-8.boo')

  [Test]
  def test_splicing_9():
    FixtureRunner.run('tests/fixtures/meta-programming/splicing-9.boo')

  [Test]
  def test_splicing_reference_into_enum_body():
    FixtureRunner.run('tests/fixtures/meta-programming/splicing-reference-into-enum-body.boo')

  [Test]
  def test_typedef_splicing_1():
    FixtureRunner.run('tests/fixtures/meta-programming/typedef-splicing-1.boo')

  [Test]
  def test_typeref_splicing_1():
    FixtureRunner.run('tests/fixtures/meta-programming/typeref-splicing-1.boo')

  [Test]
  def test_typeref_splicing_2():
    FixtureRunner.run('tests/fixtures/meta-programming/typeref-splicing-2.boo')

  [Test]
  def test_typeref_splicing_3():
    FixtureRunner.run('tests/fixtures/meta-programming/typeref-splicing-3.boo')

  [Test]
  def test_typeref_splicing_4():
    FixtureRunner.run('tests/fixtures/meta-programming/typeref-splicing-4.boo')

  [Test]
  def test_typeref_splicing_5():
    FixtureRunner.run('tests/fixtures/meta-programming/typeref-splicing-5.boo')

  [Test]
  def test_typeref_splicing_null():
    FixtureRunner.run('tests/fixtures/meta-programming/typeref-splicing-null.boo')

