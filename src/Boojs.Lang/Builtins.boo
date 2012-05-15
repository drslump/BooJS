namespace Boojs.Lang

# TODO: Do we actually need to defined these?

def range(begin as int, end as int) as int:
    pass

def range(max as int):
    assert max >= 0
    return range(0, max)

def join(items):
    return join(items, ' ')

def join(items, separator) as string:
    pass

def prompt(msg as string):
    pass
