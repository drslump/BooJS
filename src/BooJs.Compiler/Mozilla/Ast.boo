"""
Implementation of Mozilla's SpiderMonkey Parser API

TODO: This is just a prototype, it doesn't even compile.

"""
namespace Boojs.Compiler.Mozilla.Ast

/*
interface INode:
""" All node _types implement this interface. The type field is a string representing the 
    AST variant _type. You can use this field to determine which interface a node implements. 
"""
    type as string:
        get
    loc as SourceLocation:
        get

class Node(INode):
    [Property(type)]
    _type as string
    [Property(loc)]
    _loc as SourceLocation

    def constructor(loc as SourceLocation):
        _loc = loc

class SourceLocation:
""" Source location information of the node consisting of a start position (the position of 
    the first character of the parsed source region) and an end position (the position of 
    the first character after the parsed source region)
"""
    source as string
    start as Position
    end as Position

struct Position:
""" Each Position object consists of a line number (1-indexed) and a column number (0-indexed) """
    line as int
    column as int


class Program(Node):
""" A complete program source tree. """
    _type = 'Program'
    elements as List[of Statement]

class Function(Node):
""" A function declaration or expression. The body of the function may be a block 
    statement, or in the case of an expression closure, an expression (Mozilla specific).
    If the generator flag is true, the function is a generator function, i.e., contains a 
    yield expression in its body (other than in a nested function).
    If the expression flag is true, the function is an expression closure and the body 
    field is an expression.
"""
    _type = 'Function'
    id as Identifier = null
    params as List[of Pattern]
    body as BlockStatement # | Expression 
    generator as boolean
    expression as boolean

interface Statement(Node):
""" Any statement """
    pass

class EmptyStatement(Statement):
""" An empty statement, i.e., a solitary semicolon. """
    _type = 'EmptyStatement'

class BlockStatement(Statement):
""" A block statement, i.e., a sequence of statements surrounded by braces. """
    _type = 'BlockStatement'
    body as List[of Statement]

class ExpressionStatement(Statement):
""" An expression statement, i.e., a statement consisting of a single expression. """
    _type = "ExpressionStatement"
    expression as Expression

class IfStatement(Statement):
""" An if statement. """
    _type = "IfStatement"
    test as Expression
    consequent as Statement
    alternate as Statement = null

class LabeledStatement(Statement):
""" A labeled statement, i.e., a statement prefixed by a break/continue label. """
    _type = "LabeledStatement"
    label as Identifier
    body as Statement

class BreakStatement(Statement):
""" A break statement. """
    _type = "BreakStatement"
    label as Identifier = null

class ContinueStatement(Statement):
""" A continue statement. """
    _type = "ContinueStatement"
    label as Identifier = null

class WithStatement(Statement):
""" A with statement. """
    _type = "WithStatement"
    object as Expression
    body as Statement

class SwitchStatement(Statement):
""" A switch statement. The lexical flag is metadata indicating whether the switch statement 
    contains any unnested let declarations (and therefore introduces a new lexical scope).
"""
    _type = "SwitchStatement"
    discriminant as Expression
    cases as List[of SwitchCase]
    lexical as bool

class ReturnStatement(Statement):
""" A return statement. """
    _type = "ReturnStatement"
    argument as Expression = null

class ThrowStatement(Statement):
""" A throw statement. """
    _type = "ThrowStatement"
    argument as Expression

class TryStatement(Statement):
""" A try statement. Multiple catch clauses are SpiderMonkey-specific. """
    _type = "TryStatement"
    block as BlockStatement
    handlers as List[of CatchClause]
    finalizer as BlockStatement = null

class WhileStatement(Statement):
""" A while statement. """
    _type = "WhileStatement"
    test as Expression
    body as Statement

class DoWhileStatement(Statement):
""" A do/while statement. """
    _type = "DoWhileStatement"
    body as Statement
    test as Expression

class ForStatement(Statement):
""" A for statement. """
    _type = "ForStatement"
    init as VariableDeclaration # | Expression |  = null
    test as Expression = null
    update as Expression = null
    body as Statement


class ForInStatement(Statement):
""" A for/in statement, or, if each is true, a for each/in statement.
    Note: The for each form is SpiderMonkey-specific.
"""
    _type = "ForInStatement"
    left as VariableDeclaration # |  Expression 
    right as Expression
    body as Statement
    each as bool

struct LetStatementDecl:
    id as Pattern
    init as Expression = null

class LetStatement(Statement):
""" A let statement.
    Note: The let statement form is SpiderMonkey-specific.
"""
    _type = "LetStatement"
    head as List[of LetStatementDecl]
    body as Statement

class DebuggerStatement(Statement):
""" A debugger statement.
    Note: The debugger statement is new in ECMAScript 5th edition
"""
    _type = "DebuggerStatement"

interface Declaration(Statement):
""" Any declaration node. Note that declarations are considered statements; 
    this is because declarations can appear in any statement context in the 
    language recognized by the SpiderMonkey parser.
    Note: Declarations in arbitrary nested scopes are SpiderMonkey-specific.
"""
    pass

class FunctionDeclaration(Function, Declaration):
""" A function declaration.
    Note: The id field cannot be null.
"""
    _type = "FunctionDeclaration"
    id as Identifier
    params as List[of Pattern]
    body as BlockStatement # | Expression
    meta as FunctionDeclarationMeta

struct FunctionDeclarationMeta:
    thunk as boolean
    closed as boolean
    generator as boolean
    expression as boolean

class VariableDeclaration(Declaration):
""" A variable declaration, via one of var, let, or const. """
    _type = "VariableDeclaration"
    declarations as List[of VariableDeclarator]
    kind as string  # "var" | "let" | "const" 

class VariableDeclarator(Node):
""" A variable declarator.
    Note: The id field cannot be null.
    Note: let and const are SpiderMonkey-specific.
"""
    _type = "VariableDeclarator"
    id as Pattern
    init as Expression = null

interface Expression(Node, Pattern):
""" Any expression node. Since the left-hand side of an assignment may 
    be any expression in general, an expression can also be a pattern.
"""
    pass

class ThisExpression(Expression):
""" A this expression """
    _type = "ThisExpression"

class ArrayExpression(Expression):
""" An array expression. """
    _type = "ArrayExpression"
    elements as List[of Expression] # null

class ObjectExpression(Expression):
""" An object expression. A literal property in an object expression can have 
    either a string or number as its value. Ordinary property initializers have 
    a kind value "init"; getters and setters have the kind values "get" and "set", 
    respectively.
"""
    _type = "ObjectExpression"
    properties as List[of ObjectExpressionProp]

struct ObjectExpressionProp:
    key as Literal # | Identifier 
    value as Expression
    kind as string # "init" | "get" | "set" 

class FunctionExpression(Function, Expression):
""" A function expression. """
    _type = "FunctionExpression"
    id as Identifier = null
    params as List[of Pattern]
    body as BlockStatement # | Expression; 
    meta as FunctionExpressionMeta

struct FunctionExpressionMeta:
    thunk as bool
    closed as bool
    generator as bool
    expression as bool

class SequenceExpression(Expression):
""" A sequence expression, i.e., a comma-separated sequence of expressions. """
    _type = "SequenceExpression"
    expressions as List[of Expression]

class UnaryExpression(Expression):
""" A unary operator expression. """
    _type = "UnaryExpression"
    operator as UnaryOperator
    prefix as bool
    argument as Expression

class BinaryExpression(Expression):
""" A binary operator expression. """
    _type = "BinaryExpression"
    operator as BinaryOperator
    left as Expression
    right as Expression

class AssignmentExpression(Expression):
""" An assignment operator expression. """
    _type = "AssignmentExpression"
    operator as AssignmentOperator
    left as Expression
    right as Expression

class UpdateExpression(Expression):
""" An update (increment or decrement) operator expression. """
    _type = "UpdateExpression"
    operator as UpdateOperator
    argument as Expression
    prefix as bool

class LogicalExpression(Expression):
""" A logical operator expression. """
    _type = "LogicalExpression";
    operator as LogicalOperator;
    left as Expression;
    right as Expression;

class ConditionalExpression(Expression):
""" A conditional expression, i.e., a ternary ?/: expression. """
    _type = "ConditionalExpression"
    test as Expression
    alternate as Expression
    consequent as Expression

class NewExpression(Expression):
""" A new expression. """
    _type = "NewExpression"
    # TODO: Renamed constructor
    _constructor as Expression
    arguments as List[of Expression] # null

class CallExpression(Expression):
""" A function or method call expression. """
    _type = "CallExpression"
    callee as Expression
    arguments as List[of Expression]

class MemberExpression(Expression):
""" A member expression. If computed === true, the node corresponds to a computed 
    e1[e2] expression and property is an Expression. If computed === false, the 
    node corresponds to a static e1.x expression and property is an Identifier.
"""
    _type = "MemberExpression"
    object as Expression
    property as Identifier # | Expression 
    computed as bool

class YieldExpression(Expression):
""" A yield expression.
    Note: yield expressions are SpiderMonkey-specific.
"""
    argument as Expression = null

class ComprehensionExpression(Expression):
""" An array comprehension. The blocks array corresponds to the sequence of for and for each blocks. The optional filter expression corresponds to the final if clause, if present.
    Note: Array comprehensions are SpiderMonkey-specific.
"""
    body as Expression
    blocks as List[of ComprehensionBlock]
    filter as Expression = null

class GeneratorExpression(Expression):
""" A generator expression. As with array comprehensions, the blocks array corresponds to the sequence of for and for each blocks, and the optional filter expression corresponds to the final if clause, if present.
    Note: Generator expressions are SpiderMonkey-specific.
"""
    body as Expression
    blocks as List[of ComprehensionBlock]
    filter as Expression = null

class GraphExpression(Expression):
""" A graph expression, aka "sharp literal," such as #1={ self: #1# }.
    Note: Graph expressions are SpiderMonkey-specific. 
"""
    index as int
    expression as Literal

class GraphIndexExpression(Expression):
""" A graph index expression, aka "sharp variable," such as #1#.
    Note: Graph index expressions are SpiderMonkey-specific.
"""
    index as uint32

class LetExpression(Expression):
""" A let expression.
    Note: The let expression form is SpiderMonkey-specific.
"""
    _type = "LetExpression"
    head as List[of LetExpressionHead]
    body as Expression

struct LetExpressionHead(Expression):
    id as Pattern
    init as Expression = null

interface Pattern(Node):
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

class ObjectPattern(Pattern):
""" An object-destructuring pattern. A literal property in an object pattern can have either a
    string or number as its value.
"""
    _type = "ObjectPattern"
    properties as List[of ObjectPatternProp]
    
struct ObjectPatternProp:
    key as Literal # | Identifier 
    value as Pattern

class ArrayPattern(Pattern):
""" An array-destructuring pattern. """
    _type = "ArrayPattern"
    elements as List[of Pattern] # null

class SwitchCase(Node):
""" A case (if test is an Expression) or default (if test === null) clause in the body of a 
    switch statement.
"""
    _type = "SwitchCase"
    test as Expression = null
    consequent as List[of Statement]

class  CatchClause(Node):
""" A catch clause following a try block. The optional guard property corresponds to the 
    optional expression guard on the bound variable.
    Note: The guard expression is SpiderMonkey-specific.
"""
    _type = "CatchClause"
    param as Pattern
    guard as Expression = null
    body as BlockStatement

class ComprehensionBlock(Node):
""" A for or for each block in an array comprehension or generator expression.
    Note: Array comprehensions and generator expressions are SpiderMonkey-specific.
"""
    _type = "ComprehensionBlock"
    left as Pattern
    right as Expression
    each as bool

class Identifier(Node, Expression, Pattern):
""" An identifier. Note that an identifier may be an expression or a destructuring pattern. """
    _type = "Identifier"
    name as string

class Literal(Node, Expression):
""" A literal token. Note that a literal can be an expression. """
    _type = "Literal"
    value as object // string | boolean | null | number | RegExp

class UnaryOperator(Node):
""" A unary operator token. """
    _type = "UnaryOperator"
    token as string // "-" | "+" | "!" | "~" | "typeof" | "void" | "delete"

class BinaryOperator(Node):
""" A binary operator token.
    Note: The .. operator is E4X-specific.
"""
    _type = "BinaryOperator"
    token as string 
    # "==" | "!=" | "===" | "!=="
    # | "<" | "<=" | ">" | ">="
    # | "<<" | ">>" | ">>>"
    # | "+" | "-" | "*" | "/" | "%"
    # | "|" | "^" | "^"
    # | "in" | "instanceof"
    # | "..";

class LogicalOperator(Node):
""" A logical operator token. """
    _type = "LogicalOperator"
    token as string // "||" | "&&"

class AssignmentOperator(Node):
""" An assignment operator token. """
    _type = "AssignmentOperator"
    token as string
    # "=" | "+=" | "-=" | "*=" | "/=" | "%="
    # | "<<=" | ">>=" | ">>>="
    # | "|=" | "^=" | "&="

class UpdateOperator(Node):
""" An update (increment or decrement) operator token. """
    _type = "UpdateOperator"
    token as string // "++" | "--"
*/
