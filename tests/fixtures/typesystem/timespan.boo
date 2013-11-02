"""
3600000
5430000
2000-01-01T00:00:00.000Z
2000-01-01T03:00:00.000Z
1999-12-28T12:00:00.000Z
"""
[Extension] def op_Addition(date as Date, ms as int) as Date:
    return Date(date.getTime() + ms)

[Extension] def op_Subtraction(date as Date, ms as int) as Date:
    return Date(date.getTime() - ms)


with date = Date(2000, 0, 1):
    .setUTCFullYear(2000, 0, 1)
    .setUTCHours(0, 0, 0, 0)

date_mod1 = date + 3h
date_mod2 = date - 3.5d

print 1h
print 1h + 30m + 30s
print date.toISOString()
print date_mod1.toISOString()
print date_mod2.toISOString()
