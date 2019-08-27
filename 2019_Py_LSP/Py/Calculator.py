import matplotlib.pyplot as plt

x = [0, 5, 10, 15, 20, 25, 30]
y = [100, 99, 111, 120, 112, 105, 109]

if len(x) == len(y):
	plt.plot(x, y)
	try:
		plt.savefig('graf')
		pass
	except Exception as error:
		print(error)
		pass
	plt.show()
	pass

