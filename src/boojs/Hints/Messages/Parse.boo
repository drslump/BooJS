namespace boojs.Hints.Messages


class Parse:
    struct Error:
        code as string
        message as string
        line as int
        column as int

    public errors as List[of Error]
    public warnings as List[of Error]

    def constructor():
        errors = List[of Error]()
        warnings = List[of Error]()
