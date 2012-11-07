"""
Implementation of Mozilla's SpiderMonkey Parser API
"""
namespace BooJs.Compiler.Mozilla

import System

interface INode:
""" All node types implement this interface. The type field is a string representing the
    AST variant type. You can use this field to determine which interface a node implements.
"""
    def Apply(visitor as Visitor)

interface IStatement(INode):
""" Any statement """
    pass

interface IDeclaration(IStatement):
""" Any declaration node. Note that declarations are considered statements;
    this is because declarations can appear in any statement context in the
    language recognized by the SpiderMonkey parser.
    Note: Declarations in arbitrary nested scopes are SpiderMonkey-specific.
"""
    pass

interface IExpression(IPattern):
""" Any expression node. Since the left-hand side of an assignment may
    be any expression in general, an expression can also be a pattern.
"""
    pass

interface IPattern(INode):
""" JavaScript 1.7 introduced destructuring assignment and binding forms. All binding
    forms (such as function parameters, variable declarations, and catch block headers),
    accept array and object destructuring patterns in addition to plain identifiers. The
    left-hand sides of assignment expressions can be arbitrary expressions, but in the case
    where the expression is an object or array literal, it is interpreted by SpiderMonkey as
    a destructuring pattern.
    Since the left-hand side of an assignment can in general be any expression, in an assignment
    context, a pattern can be any expression. In binding positions (such as function parameters,
    variable declarations, and catch headers), patterns can only be identifiers in the base case,
    not arbitrary expressions.
"""
    pass

class Node(INode):
    public loc as SourceLocation
    public xreplace as string

    self[index as object] as object:
        get:
            return null if not _annotations or index not in _annotations
            return _annotations[index]
        set:
            if not _annotations:
                _annotations = {}
            _annotations[index] = value
    private _annotations as Hash

    def Apply(visitor as Visitor):
    """ Reflection based visitor support """
        method = 'On' + self.GetType().Name
        flags = BindingFlags.Instance | BindingFlags.FlattenHierarchy | BindingFlags.InvokeMethod
        try:
            visitor.GetType().InvokeMember(method, flags, null, visitor, (self,))
        except as MissingMethodException:
            pass


class SourceLocation:
""" Source location information of the node consisting of a start position (the position of 
    the first character of the parsed source region) and an end position (the position of 
    the first character after the parsed source region)
"""
    public source as string
    public start as Position?
    public end as Position?

struct Position:
""" Each Position object consists of a line number (1-indexed) and a column number (0-indexed) """
    line as int
    column as int


class Program(Node):
""" A complete program source tree. """
    public body = List[of IStatement]()

class Function(Node):
""" A function declaration or expression. The body of the function may be a block 
    statement, or in the case of an expression closure, an expression (Mozilla specific).
    If the generator flag is true, the function is a generator function, i.e., contains a 
    yield expression in its body (other than in a nested function).
    If the expression flag is true, the function is an expression closure and the body 
    field is an expression.
"""
    public id as Identifier
    public params = List[of IPattern]()
    public body as BlockStatement # | Expression
    public generator as bool = false
    public expression as bool = false

class EmptyStatement(Node, IStatement):
""" An empty statement, i.e., a solitary semicolon. """
    pass

class BlockStatement(Node, IStatement):
""" A block statement, i.e., a sequence of statements surrounded by braces. """
    public body = List[of IStatement]()

class ExpressionStatement(Node, IStatement):
""" An expression statement, i.e., a statement consisting of a single expression. """
    public expression as IExpression

    def constructor():
        pass

    def constructor(expression as IExpression):
        self.expression = expression

class IfStatement(Node, IStatement):
""" An if statement. """
    public test as IExpression
    public consequent as IStatement
    public alternate as IStatement

class LabeledStatement(Node, IStatement):
""" A labeled statement, i.e., a statement prefixed by a break/continue label. """
    public label as Identifier
    public body as IStatement

class BreakStatement(Node, IStatement):
""" A break statement. """
    public label as Identifier

class ContinueStatement(Node, IStatement):
""" A continue statement. """
    public label as Identifier

class WithStatement(Node, IStatement):
""" A with statement. """
    public object as IExpression
    public body as IStatement

class SwitchStatement(Node, IStatement):
""" A switch statement. The lexical flag is metadata indicating whether the switch statement 
    contains any unnested let declarations (and therefore introduces a new lexical scope).
"""
    public discriminant as IExpression
    public cases = List[of SwitchCase]()
    public lexical as bool = false

class ReturnStatement(Node, IStatement):
""" A return statement. """
    public argument as IExpression

class ThrowStatement(Node, IStatement):
""" A throw statement. """
    public argument as IExpression

    def constructor():
        pass

    def constructor(argument as IExpression):
        self.argument = argument

class TryStatement(Node, IStatement):
""" A try statement. Multiple catch clauses are SpiderMonkey-specific. """
    public block as BlockStatement
    public handlers = List[of CatchClause]()
    public finalizer as BlockStatement

class WhileStatement(Node, IStatement):
""" A while statement. """
    public test as IExpression
    public body as IStatement

class DoWhileStatement(Node, IStatement):
""" A do/while statement. """
    public body as IStatement
    public test as IExpression

class ForStatement(Node, IStatement):
""" A for statement. """
    public init as IExpression  # VariableDeclaration | Expression |  = null
    public test as IExpression
    public update as IExpression
    public body as IStatement

class ForInStatement(Node, IStatement):
""" A for/in statement, or, if each is true, a for each/in statement.
    Note: The for each form is SpiderMonkey-specific.
"""
    public left as IExpression  # VariableDeclaration | Expression
    public right as IExpression
    public body as IStatement
    public each as bool = false

class DebuggerStatement(Node, IStatement):
""" A debugger statement.
    Note: The debugger statement is new in ECMAScript 5th edition
"""
    pass

class FunctionDeclaration(Function, IDeclaration):
""" A function declaration.
    Note: The id field cannot be null.
"""
    public meta as FunctionDeclarationMeta?

struct FunctionDeclarationMeta:
    thunk as bool
    closed as bool
    generator as bool
    expression as bool

class VariableDeclaration(Node, IDeclaration):
""" A variable declaration, via one of var, let, or const. """
    public declarations = List[of VariableDeclarator]()
    public kind as string = 'var'  # "var" | "let" | "const"

    def constructor():
        pass

    def constructor(decls as List[of VariableDeclarator]):
        declarations = decls

class VariableDeclarator(Node):
""" A variable declarator.
    Note: The id field cannot be null.
    Note: let and const are SpiderMonkey-specific.
"""
    public id as IPattern
    public init as IExpression

    def constructor():
        pass

    def constructor(id as string):
        self.id = Identifier(id)

class ThisExpression(Node, IExpression):
""" A this expression """
    pass

class ArrayExpression(Node, IExpression):
""" An array expression. """
    public elements = List[of IExpression]()

class ObjectExpression(Node, IExpression):
""" An object expression. A literal property in an object expression can have 
    either a string or number as its value. Ordinary property initializers have 
    a kind value "init"; getters and setters have the kind values "get" and "set", 
    respectively.
"""
    public properties = List[of ObjectExpressionProp]()

struct ObjectExpressionProp:
    public key as IExpression # Literal | Identifier
    public value as IExpression
    public kind as string # "init" | "get" | "set"

    def constructor(key as string, value as IExpression):
        self.key = Literal(key)
        self.value = value

class FunctionExpression(Function, IExpression):
""" A function expression. """
    public meta as FunctionExpressionMeta?

struct FunctionExpressionMeta:
    thunk as bool
    closed as bool
    generator as bool
    expression as bool

class SequenceExpression(Node, IExpression):
""" A sequence expression, i.e., a comma-separated sequence of expressions. """
    public expressions = List[of IExpression]()

class UnaryExpression(Node, IExpression):
""" A unary operator expression. """
    public operator as string
    public argument as IExpression
    public prefix as bool = true

class UpdateExpression(UnaryExpression, IExpression):
""" An update (increment or decrement) operator expression. """
    pass

class BinaryExpression(Node, IExpression):
""" A binary operator expression. """
    public operator as string
    public left as IExpression
    public right as IExpression

class AssignmentExpression(BinaryExpression, IExpression):
""" An assignment operator expression. """
    pass

class LogicalExpression(BinaryExpression, IExpression):
""" A logical operator expression. """
    pass

class ConditionalExpression(Node, IExpression):
""" A conditional expression, i.e., a ternary ?/: expression. """
    public test as IExpression
    public alternate as IExpression
    public consequent as IExpression

class NewExpression(Node, IExpression):
""" A new expression. """
    public _constructor as IExpression
    public arguments = List[of IExpression]()

class CallExpression(Node, IExpression):
""" A function or method call expression. """
    public callee as IExpression
    public arguments = List[of IExpression]()

class MemberExpression(Node, IExpression):
""" A member expression. If computed === true, the node corresponds to a computed 
    e1[e2] expression and property is an Expression. If computed === false, the 
    node corresponds to a static e1.x expression and property is an Identifier.
"""
    public object as IExpression
    public property as IExpression # Identifier | Expression
    public computed = false

class SwitchCase(Node):
""" A case (if test is an Expression) or default (if test === null) clause in the body of a 
    switch statement.
"""
    public test as IExpression = null
    public consequent = List[of IStatement]()

class CatchClause(Node):
""" A catch clause following a try block. The optional guard property corresponds to the 
    optional expression guard on the bound variable.
    Note: The guard expression is SpiderMonkey-specific.
"""
    public param as IPattern
    public guard as IExpression
    public body as BlockStatement

class Identifier(Node, IExpression):
""" An identifier. Note that an identifier may be an expression or a destructuring pattern. """
    public name as string

    def constructor():
        pass

    def constructor(name as string):
        self.name = name

class Literal(Node, IExpression):
""" A literal token. Note that a literal can be an expression. """
    public value as object // string | boolean | null | number | RegExp

    public regexp = false   # BooJs proprietary

    def constructor():
        pass

    def constructor(val as object):
        value = val


## Spidemonkey (Harmony) specific nodes

class ComprehensionBlock(Node):
""" A for or for each block in an array comprehension or generator expression.
    Note: Array comprehensions and generator expressions are SpiderMonkey-specific.
"""
    public left as IPattern
    public right as IExpression
    public each as bool

class LetStatement(Node, IStatement):
""" A let statement.
    Note: The let statement form is SpiderMonkey-specific.
"""
    public head = List[of LetStatementDecl]()
    public body as IStatement

struct LetStatementDecl:
    id as IPattern
    init as IExpression

class LetExpression(Node, IExpression):
""" A let expression.
    Note: The let expression form is SpiderMonkey-specific.
"""
    public head = List[of LetExpressionHead]()
    public body as IExpression

struct LetExpressionHead:
    public id as IPattern
    public init as IExpression

class ObjectPattern(Node, IPattern):
""" An object-destructuring pattern. A literal property in an object pattern can have either a
    string or number as its value.
"""
    public properties = List[of ObjectPatternProp]()

struct ObjectPatternProp:
    public key as IExpression  # Literal | Identifier
    public value as IPattern

class ArrayPattern(Node, IPattern):
""" An array-destructuring pattern. """
    public elements = List[of IPattern]() # null

class GeneratorExpression(Node, IExpression):
""" A generator expression. As with array comprehensions, the blocks array corresponds to the sequence
    of for and for each blocks, and the optional filter expression corresponds to the final if clause,
    if present.
    Note: Generator expressions are SpiderMonkey-specific.
"""
    public body as IExpression
    public blocks = List[of ComprehensionBlock]()
    public filter as IExpression

class GraphExpression(Node, IExpression):
""" A graph expression, aka "sharp literal," such as #1={ self: #1# }.
    Note: Graph expressions are SpiderMonkey-specific.
"""
    public index as int
    public expression as Literal

class GraphIndexExpression(Node, IExpression):
""" A graph index expression, aka "sharp variable," such as #1#.
    Note: Graph index expressions are SpiderMonkey-specific.
"""
    public index as uint

class YieldExpression(Node, IExpression):
""" A yield expression.
    Note: yield expressions are SpiderMonkey-specific.
"""
    public argument as IExpression

class ComprehensionExpression(Node, IExpression):
""" An array comprehension. The blocks array corresponds to the sequence of for and for each blocks.
    The optional filter expression corresponds to the final if clause, if present.
    Note: Array comprehensions are SpiderMonkey-specific.
"""
    public body as IExpression
    public blocks = List[of ComprehensionBlock]()
    public filter as IExpression

class XCodeExpression(Node, IExpression):
""" A chunk of Javascript code to be generated verbatim
    Node: This node type is not defined by the Mozilla parser API.
"""
    public code as string
