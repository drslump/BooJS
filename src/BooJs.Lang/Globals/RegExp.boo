namespace BooJs.Lang.Globals


class RegExp(Object):

    internal class ExecResult(Array):
        public index as int
        public input as string


    public global as bool
    public ignoreCase as bool
    public lastIndex as bool
    public multiline as bool
    public source as string

    def constructor(pattern as string, flags as string):
        pass

    def constructor(pattern as string):
        pass

    def exec(str as string) as ExecResult:
        pass

    def test(str as string) as bool:
        pass


