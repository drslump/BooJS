namespace BooJs.Lang.Globals

# TODO: Check which methods are 5th edition
class Date(Object):

    static def parse(s as string) as int:
        pass

    static def UTC(year as int, month as int) as int:
        pass
    static def UTC(year as int, month as int, day as int) as int:
        pass
    static def UTC(year as int, month as int, day as int, hours as int) as int:
        pass
    static def UTC(year as int, month as int, day as int, hours as int, minutes as int) as int:
        pass
    static def UTC(year as int, month as int, day as int, hours as int, minutes as int, seconds as int) as int:
        pass
    static def UTC(year as int, month as int, day as int, hours as int, minutes as int, seconds as int, ms as int) as int:
        pass

    static def now() as int:
        pass


    def constructor():
        pass
    def constructor(value as int):
        pass
    def constructor(value as string):
        pass
    def constructor(year as int, month as int):
        pass
    def constructor(year as int, mont as int, day as int):
        pass
    def constructor(year as int, mont as int, day as int, hours as int):
        pass
    def constructor(year as int, mont as int, day as int, hours as int, minutes as int):
        pass
    def constructor(year as int, mont as int, day as int, hours as int, minutes as int, seconds as int):
        pass
    def constructor(year as int, mont as int, day as int, hours as int, minutes as int, seconds as int, ms as int):
        pass


    def toDateString() as string:
        pass
    def toTimeString() as string:
        pass
    def toLocaleDateString() as string:
        pass
    def toLocaleTimeString() as string:
        pass
    def getTime() as int:
        pass
    def getFullYear() as int:
        pass
    def getUTCFullYear() as int:
        pass
    def getMonth() as int:
        pass
    def getUTCMonth() as int:
        pass
    def getDate() as int:
        pass
    def getUTCDate() as int:
        pass
    def getDay() as int:
        pass
    def getUTCDay() as int:
        pass
    def getHours() as int:
        pass
    def getUTCHours() as int:
        pass
    def getMinutes() as int:
        pass
    def getUTCMinutes() as int:
        pass
    def getSeconds() as int:
        pass
    def getUTCSeconds() as int:
        pass
    def getMilliseconds() as int:
        pass
    def getUTCMilliseconds() as int:
        pass
    def getTimezoneOffset() as int:
        pass
    def setTime(time as int) as void:
        pass
    def setMilliseconds(ms as int) as void:
        pass
    def setUTCMilliseconds(ms as int) as void:
        pass

    # TODO: Make oveloads for optionals
    def setSeconds(sec as int, ms_optional as int) as void:
        pass
    def setUTCSeconds(sec as int, ms_optional as int) as void:
        pass
    def setMinutes(min as int, sec_opt as int, ms_opt as int) as void:
        pass
    def setUTCMinutes(min as int, sec_opt as int, ms_opt as int) as void:
        pass
    def setHours(hours as int, min_opt as int, sec_opt as int, ms_opt as int) as void:
        pass
    def setUTCHours(hours as int, min_opt as int, sec_opt as int, ms_opt as int) as void:
        pass
    def setDate(date_ as int) as void:
        pass
    def setUTCDate(date_ as int) as void:
        pass
    def setMonth(month as int, date_opt as int) as void:
        pass
    def setUTCMonth(month as int, date_opt as int) as void:
        pass
    def setFullYear(year as int, month_opt as int, date_opt as int) as void:
        pass
    def setUTCFullYear(year as int, month_opt as int, date_opt as int) as void:
        pass
    def toUTCString() as string:
        pass
    def toISOString() as string:
        pass
    def toJSON(key_opt as object) as string:
        pass


