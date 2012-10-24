namespace BooJs.Compiler.Mozilla

import System.IO(TextWriter)


abstract class Printer(Visitor):
"""
    Abstract printer for the Mozilla AST
"""
    enum Precedence:
        None
        Sequence
        Assignment
        Conditional
        LogicalOR
        LogicalAND
        BitwiseOR
        BitwiseXOR
        BitwiseAND
        Equality
        Relational
        BitwiseSHIFT
        Additive
        Multiplicative
        Unary
        Postfix
        Call
        New
        Member
        Primary


    [getter(Writer)]
    protected _writer as TextWriter
    [property(IndentText)]
    protected _indentText = "  "

    protected _indent = 0
    protected _needsIndenting = true
    protected _disableNewLine = 0
    protected _accumulator = ''
    protected _line = 0
    protected _column = 0

    [getter(PrecedenceStack)]
    protected _precedenceStack = List[of Precedence]()

    protected _binaryPrecedence = {
        '=': Precedence.Assignment,
        '||': Precedence.LogicalOR,
        '&&': Precedence.LogicalAND,
        '|': Precedence.BitwiseOR,
        '^': Precedence.BitwiseXOR,
        '&': Precedence.BitwiseAND,
        '==': Precedence.Equality,
        '!=': Precedence.Equality,
        '===': Precedence.Equality,
        '!==': Precedence.Equality,
        'is': Precedence.Equality,
        'isnt': Precedence.Equality,
        '<': Precedence.Relational,
        '>': Precedence.Relational,
        '<=': Precedence.Relational,
        '>=': Precedence.Relational,
        'in': Precedence.Relational,
        'instanceof': Precedence.Relational,
        '<<': Precedence.BitwiseSHIFT,
        '>>': Precedence.BitwiseSHIFT,
        '>>>': Precedence.BitwiseSHIFT,
        '+': Precedence.Additive,
        '-': Precedence.Additive,
        '*': Precedence.Multiplicative,
        '%': Precedence.Multiplicative,
        '/': Precedence.Multiplicative
    }


    def constructor(writer as TextWriter):
        raise System.ArgumentNullException('writer') if writer is null
        _writer = writer

    def Indent():
        _indent++

    def Dedent():
        _indent--

    def DisableNewLine():
        _disableNewLine++

    def EnableNewLine():
        if 0 == _disableNewLine:
            raise System.InvalidOperationException()
        _disableNewLine--

    def Trim():
        _accumulator = ''

    virtual def Write(s as string):
        # Dump accumulated white space if actually writing something
        if len(_accumulator) and not /^\s*$/.IsMatch(s):
            s = _accumulator + s
            _accumulator = ''

        # Accumulate trailing white space
        m = /\s+$/.Match(s)
        if m.Success:
            _accumulator += m.ToString()
            s = s[:-m.Length]

        # Adjust the target line and column
        lines = s.Split(char('\n'))
        if len(lines) > 1:
            _line += len(lines) - 1
            _column = len(lines[-1])
        else:
            _column += len(lines[0])

        # Only indent if there is no input on the same line
        _needsIndenting = len(lines[-1]) == 0

        _writer.Write(s)

    def Write(format as string, *args as (object)):
        Write(string.Format(format, *args))

    virtual def WriteIndented():
        if _needsIndenting:
            Write(_indentText * _indent)
            _needsIndenting = false;

    virtual def WriteLine():
        if 0 == _disableNewLine:
            Write(_writer.NewLine)
            _needsIndenting = true

    def WriteIndented(s as string):
        WriteIndented()
        Write(s)

    def WriteIndented(format as string, *args as (object)):
        WriteIndented()
        Write(format, *args)

    def WriteLine(s as string):
        Write(s)
        WriteLine()

    def WriteLine(format as string, *args as (object)):
        Write(format, *args)
        WriteLine()

    def WriteCommaSeparatedList[of T(INode)](items as T*):
        i = 0
        _precedenceStack.Add(Precedence.Sequence)
        for node in items:
            if i++ > 0: Write(", ")
            Visit(node as Node)
            Trim
        _precedenceStack.Pop()

    def Parens(precedence as Precedence, block as callable):
        last = (_precedenceStack[-1] if len(_precedenceStack) else Precedence.None)
        parens = precedence < last
        _precedenceStack.Add(precedence)
        Write '(' if parens
        block()
        Write ')' if parens
        _precedenceStack.Pop()

