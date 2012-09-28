txt = """Given#a#txt#file#of#many#lines,#where#fields#within#a#line#
         are#delineated#by#a#single#'dollar'#character,#write#a#program
		 that#aligns#each#column#of#fields#by#ensuring#that#words#in#each#
		 column#are#separated#by#at#least#one#space.
		 Further,#allow#for#each#word#in#a#column#to#be#either#left#
		 justified,#right#justified,#or#center#justified#within#its#column."""

def enumerate(lst):
	idx = range(len(lst))
	return zip(idx, lst)

def justify(word as string, width as int):
	return (' ' * (width-len(word))) + word

def max(a as int, b as int):
	return (a if a > b else b)
 
parts = line.split("#") for line in txt.split(/\n/)
 
widths = {}
for line in parts:
    for i, word in enumerate(line):
        widths[i] = max(widths[i] or 0, len(word))
 
for line in parts:
	for i, word in enumerate(line):
		print justify(word, widths[i])

/*
for i, justify in enumerate([str.ljust, str.center, str.rjust]):
    print ["Left", "Center", "Right"][i], " column-aligned output:\n"
    for line in parts:
        for j, word in enumerate(line):
            print justify(word, max_widths[j]),
        print
    print "- " * 52
*/