import System
import System.IO

def PascalCase(name as string):
    return name[:1].ToUpper() + name[1:]

def IntegrationTestFixtureName(dir as string):
    baseName = join(PascalCase(part) for part in /-/.Split(Path.GetFileName(dir)), '')
    return "${baseName}IntegrationTestFixture"


if not len(argv):
  print "Usage: booi script.boo -- ns path/to/fixtures/directory"
  return

ns = argv[0]
path = argv[1]

name = Path.GetFileNameWithoutExtension(path)
name = name[:1].ToUpper() + name[1:]
name = name.Replace('-', '')

print '"""'
print "  Automatically generated!"
print "  Fixture test cases from $path"
print '"""'
print 'namespace ' + ns
print ''
print 'import BooJs.Tests.Support'
print 'import NUnit.Framework'
print ''
print '[TestFixture]'
print "class $(name)Fixtures:"
print ''

for fname in Directory.GetFiles(path):
  continue unless fname.EndsWith(".boo")

  name = Path.GetFileNameWithoutExtension(fname)
  name = name.Replace('-', '_').Replace('.', '_')

  print "  [Test]"
  print "  def test_$name():"
  print "    FixtureRunner.run('$fname')"
  print ""

