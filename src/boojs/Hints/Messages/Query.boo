namespace boojs.Hints.Messages


class Query:
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

    def GetParam(idx as int) as object:
        if params and idx >= 0 and idx < len(params):
            return params[idx]
        return null

    def GetBoolParam(idx as int) as bool:
        return (true if GetParam(idx) else false)

    def GetIntParam(idx as int) as int:
        return GetParam(idx) or 0

    def GetStringParam(idx as int) as string:
        return GetParam(idx)
