def soundex(s as string) as string:
    codes = Hash(
        a: '', e: '', i: '', o: '', u: '',
        b: 1, f: 1, p: 1, v: 1,
        c: 2, g: 2, j: 2, k: 2, q: 2, s: 2, x: 2, z: 2,
        d: 3, t: 3,
        l: 4,
        m: 5, n: 5,
        r: 6
    )

    a as (string) = s.toLowerCase().split('')
    f as string = a.shift()
    r = ''
 
    # TODO: Doesn't work :(
    r = f + map(a, {codes[_]}) \
        .filter({v as string, i as int, a as (string)| (v != codes[f] if i == 0 else v != a[i-1]) }) \
        .join('')

    r += '000'
    return r.substr(0, 4).toUpperCase()

tests = {
  "Soundex":     "S532",
  "Example":     "E251",
  "Sownteks":    "S532",
  "Ekzampul":    "E251",
  "Euler":       "E460",
  "Gauss":       "G200",
  "Hilbert":     "H416",
  "Knuth":       "K530",
  "Lloyd":       "L300",
  "Lukasiewicz": "L222",
  "Ellery":      "E460",
  "Ghosh":       "G200",
  "Heilbronn":   "H416",
  "Kant":        "K530",
  "Ladd":        "L300",
  "Lissajous":   "L222",
  "Wheaton":     "W350",
  "Ashcraft":    "A226",
  "Burroughs":   "B622",
  "Burrows":     "B620",
  "O'Hara":      "O600"
}

for v, k in tests:
    print v, k, soundex(v)
    assert soundex(v) == k
