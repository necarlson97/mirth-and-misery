func as_list(x):
	# Helpful for functions that we want to be able to pass either a single
	# element or a list of elements
	return x if x is Array else [x]
