namespace boojs.Hints


class QueryMessage:
    # Command to execute
    public command as string
    # Additional parameters for the command
    public params as (object)
    # File name
    public fname as string
    # File containing the code to process
    public codefile as string
    # Code to process (if set then codefile is not used)
    public code as string
    public offset as int
    public line as int
    public column as int
    # If true tries to return additional information (slower)
    public extra as bool
    # If true includes null values in the response
    public nulls as bool


class HintsMessage:
    struct Hint:
        node as string
        type as string
        name as string
        full as string
        info as string

        # Extra information
        doc as string
        params as List[of string]
        loc as string  # {file}:{ln}:{col}

    public hints = List[of Hint]()


class ParseMessage:
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

    def error(code as string, message as string, line as int, column as int):
        st = Error(code: code, message: message, line: line, column: column)
        errors.Add(st)

    def warning(code as string, message as string, line as int, column as int):
        st = Error(code: code, message: message, line: line, column: column)
        warnings.Add(st)


class NodeMessage:
""" Used for generating the outline """
    public type as string
    public name as string
    public desc as string
    public visibility as string
    public line as int
    public length as int
    public members as List[of NodeMessage]

    def constructor():
        members = List[of NodeMessage]()
