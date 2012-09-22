#IGNORE: zip is not yet supported

closures = []
for i in range(3):
	closures.push({ return i })
	
for expected, closure as callable in zip(range(3), closures):
	assert expected == closure(), "for variables are not shareable"
