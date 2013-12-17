#IGNORE: Properties not supported yet
class Customer:
	[Property(FirstName, Default: "")]
	_fname as string
	
// creates a new object and assigns "Rodrigo" to its FirstName property or field
c = Customer(FirstName: "Rodrigo")
