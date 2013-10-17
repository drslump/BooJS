namespace BooJs.Compiler

import Boo.Lang.Compiler.Services.UniqueNameProvider as BooUniqueNameProvider


class UniqueNameProvider(BooUniqueNameProvider):
""" Generates unique names for the compilation unit
	TODO: Boo's class does not define the GetUniqueName method as virtual,
	      so it's not possible to inject our behaviour in the dependencies
	      environment.
"""
	_counters = {}

	new def GetUniqueName(*parts as (string)):
		prefix = join(parts, '_')
		if prefix not in _counters:
			_counters[prefix] = 0

		_counters[prefix] = (_counters[prefix] cast int) + 1
		return '_' + prefix + _counters[prefix] + '_'

	virtual def Reset():
		_counters = {}
