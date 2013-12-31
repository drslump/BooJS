"""
Rodrigo
"""

class Customer:
	[Property(FirstName)]
	_fname as string
	
// creates a new object and assigns "Rodrigo" to its FirstName property or field
c = Customer(FirstName: "Rodrigo")
print c.FirstName
