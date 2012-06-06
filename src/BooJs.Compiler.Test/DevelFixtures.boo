import NUnit.Framework

[TestFixture]
class FixtureTestCasesForDevel:

  [Test]
  def test_one():
    FixtureRunner.run('/Users/drslump/www/boojs/tests/fixtures/devel/one.boo')

  [Test]
  def test_safe_member_access():
    FixtureRunner.run('/Users/drslump/www/boojs/tests/fixtures/devel/safe-member-access.boo')