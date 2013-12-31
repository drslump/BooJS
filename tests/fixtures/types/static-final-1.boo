#IGNORE: BUG - Static constructor/initialization not fully supported
"""
default
"""
class Item:
	public static final Default = Item(Name: "default")
	
	[property(Name)] _name = ""
	
print Item.Default.Name
