#IGNORE: Properties not supported yet
"""
bar
"""
import System.Xml from System.Xml

doc = XmlDocument()
a = doc.CreateAttribute("foo")
a.InnerText = "bar"
print a.InnerText
