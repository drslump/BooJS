"""
2
4
"""
// Espaço em branco não deve ser sintaticamente significante
// dentro de colchetes e parenteses
a = [
		int('1'),
		int('2')
	]
	
for i in map(
				a,
				{ x as int | 
					x * 2
				}
			):
	print(i)
