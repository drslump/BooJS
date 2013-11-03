/*

    - Files without modules inherit the module name from the filename
    - Every module is a boo file named after the module:
        ng -> ng.boo
        ng.auto -> ng.auto.boo
    - The namespace of the file is the name of the module
    - Multiple modules with the same name end up in the same file
    - If two files define the same module error out


*/

var fs = require('fs');

// Dirty import of the typescript compiler
eval(fs.readFileSync('typescript.js').toString());


var fname = 'code.ts';
//var code = 'module Foo { export class Greeter { greeting: number; } }';
var code = fs.readFileSync('mocha.d.ts').toString();
var source = TypeScript.SimpleText.fromString(code);


var emitterIOHost = {
    writeFile: function (fileName, contents, writeByteOrderMark) {
        console.log(contents);
    },
    directoryExists: function (fileName) {
        return true;
    },
    fileExists: function (fileName) {
        return true;
    },
    resolvePath: function (fileName) {
        return fileName;
    }
};

// Instantiate a compiler
var compiler = new TypeScript.TypeScriptCompiler();
compiler.settings = new TypeScript.CompilationSettings();
compiler.settings.removeComments = false;

compiler.emitOptions.ioHost = emitterIOHost;
// compiler.setEmitOptions(emitterIOHost);

var libcode = fs.readFileSync('./typescript/bin/lib.d.ts').toString();
compiler.addSourceUnit("lib.d.ts", TypeScript.ScriptSnapshot.fromString(libcode), ByteOrderMark.None, /*version:*/ 0, /*isOpen:*/ false);

var referencedFiles = [];
compiler.addSourceUnit(fname, TypeScript.ScriptSnapshot.fromString(code), /*BOM*/ null, /*version:*/ 0, /*isOpen:*/ false, referencedFiles);

// Run the compiler to populate the AST
// TODO: Handle error reporting
var syntacticDiagnostics = compiler.getSyntacticDiagnostics(fname);
compiler.pullTypeCheck();
var semanticDiagnostics = compiler.getSemanticDiagnostics(fname);


// Support private functions from TypeScript
function hasFlag(val, flag) {
    return (val & flag) !== 0;
}

function ToDeclFlags(flags) {
    return flags;
}

// Custom Declaration emitter
function BooDeclEmitter(fname, doc, compiler)
{
    TypeScript.DeclarationEmitter.call(this, fname, doc, compiler);
}
BooDeclEmitter.prototype = Object.create(TypeScript.DeclarationEmitter.prototype);
BooDeclEmitter.prototype.constructor = BooDeclEmitter;

BooDeclEmitter.prototype.variableDeclaratorCallback = function (pre, varDecl) {
    if (pre) {
        this.emitIndent();
        this.declFile.Write(varDecl.id.actualText);
        this.emitTypeOfBoundDecl(varDecl);
        this.declFile.WriteLine('');
    }

    return false;
};

BooDeclEmitter.prototype.emitTypeOfBoundDecl = function (boundDecl) {
    var start = new Date().getTime();
    var decl = this.compiler.semanticInfoChain.getDeclForAST(boundDecl, this.document.fileName);
    var pullSymbol = decl.getSymbol();
    TypeScript.declarationEmitGetBoundDeclTypeTime += new Date().getTime() - start;

    var type = this.widenType(pullSymbol.type);
    if (!type) {
        // PULLTODO
        return;
    }

    if (boundDecl.typeExpr || // Specified type expression
        (boundDecl.init && type !== this.compiler.semanticInfoChain.anyTypeSymbol)) { // Not infered any
        this.declFile.Write(" as ");
        this.emitTypeSignature(type);
    }
};

BooDeclEmitter.prototype.interfaceDeclarationCallback = function (pre, infDecl) {
    if (pre) {
        this.declFile.WriteLine('');
        var interfaceName = infDecl.name.actualText;
        this.emitDeclarationComments(infDecl);
        var infPullDecl = this.compiler.semanticInfoChain.getDeclForAST(infDecl, this.document.fileName);
        this.emitDeclFlags(infDecl.getVarFlags(), infPullDecl, "interface");
        this.declFile.Write(interfaceName);
        this.pushDeclarationContainer(infDecl);
        this.emitTypeParameters(infDecl.typeParameters);
        this.emitBaseList(infDecl, true);
        this.declFile.WriteLine(":");

        this.indenter.increaseIndent();
    } else {
        this.indenter.decreaseIndent();
        this.popDeclarationContainer(infDecl);

        this.emitIndent();
    }
    return true;
};

BooDeclEmitter.prototype.emitBaseList = function (typeDecl, useExtendsList) {
    var bases = useExtendsList ? typeDecl.extendsList : typeDecl.implementsList;
    if (bases && (bases.members.length > 0)) {
        this.declFile.Write("(");
        var basesLen = bases.members.length;
        for (var i = 0; i < basesLen; i++) {
            if (i > 0) {
                this.declFile.Write(", ");
            }
            this.emitBaseExpression(bases, i);
        }
        this.declFile.Write(")");
    }
};

BooDeclEmitter.prototype.functionDeclarationCallback = function (pre, funcDecl) {
    if (!pre) {
        return false;
    }

    if (funcDecl.isAccessor()) {
        return this.emitPropertyAccessorSignature(funcDecl);
    }

    var isInterfaceMember = (this.getAstDeclarationContainer().nodeType() === TypeScript.NodeType.InterfaceDeclaration);

    var start = new Date().getTime();
    var funcSymbol = this.compiler.semanticInfoChain.getSymbolForAST(funcDecl, this.document.fileName);

    TypeScript.declarationEmitFunctionDeclarationGetSymbolTime += new Date().getTime() - start;

    var funcTypeSymbol = funcSymbol.type;
    if (funcDecl.block) {
        var constructSignatures = funcTypeSymbol.getConstructSignatures();
        if (constructSignatures && constructSignatures.length > 1) {
            return false;
        }
        else if (this.isOverloadedCallSignature(funcDecl)) {
            // This means its implementation of overload signature. do not emit
            return false;
        }
    }
    else if (!isInterfaceMember && hasFlag(funcDecl.getFunctionFlags(), TypeScript.FunctionFlags.Private) && this.isOverloadedCallSignature(funcDecl)) {
        // Print only first overload of private function
        var callSignatures = funcTypeSymbol.getCallSignatures();
        Debug.assert(callSignatures && callSignatures.length > 1);
        var firstSignature = callSignatures[0].isDefinition() ? callSignatures[1] : callSignatures[0];
        var firstSignatureDecl = firstSignature.getDeclarations()[0];
        var firstFuncDecl = this.compiler.semanticInfoChain.getASTForDecl(firstSignatureDecl);
        if (firstFuncDecl !== funcDecl) {
            return false;
        }
    }

    if (!this.canEmitSignature(ToDeclFlags(funcDecl.getFunctionFlags()), funcDecl, false)) {
        return false;
    }

    var funcPullDecl = this.compiler.semanticInfoChain.getDeclForAST(funcDecl, this.document.fileName);
    var funcSignature = funcPullDecl.getSignatureSymbol();
    this.emitDeclarationComments(funcDecl);
    if (funcDecl.isConstructor) {
        this.emitIndent();
        this.declFile.Write("def constructor");
        this.emitTypeParameters(funcDecl.typeArguments, funcSignature);
    }
    else {
        var id = funcDecl.getNameText();
        if (!isInterfaceMember) {
            this.emitDeclFlags(ToDeclFlags(funcDecl.getFunctionFlags()), funcPullDecl, "function");
            if (id !== "__missing" || !funcDecl.name || !funcDecl.name.isMissing()) {
                this.declFile.Write('def ');
                this.declFile.Write(id);
            }
            else if (funcDecl.isConstructMember()) {
                this.declFile.Write("new");
            }

            this.emitTypeParameters(funcDecl.typeArguments, funcSignature);
        }
        else {
            this.emitIndent();
            if (funcDecl.isConstructMember()) {
                this.declFile.Write("new");
                this.emitTypeParameters(funcDecl.typeArguments, funcSignature);
            }
            else if (!funcDecl.isCallMember() && !funcDecl.isIndexerMember()) {
                this.declFile.Write('def ');
                this.declFile.Write(id);
                this.emitTypeParameters(funcDecl.typeArguments, funcSignature);
                if (hasFlag(funcDecl.name.getFlags(), TypeScript.ASTFlags.OptionalName)) {
                    this.declFile.Write("? ");
                }
            }
            else {
                this.emitTypeParameters(funcDecl.typeArguments, funcSignature);
            }
        }
    }

    if (!funcDecl.isIndexerMember()) {
        this.declFile.Write("(");
    }
    else {
        this.declFile.Write("[");
    }

    if (funcDecl.arguments) {
        var argsLen = funcDecl.arguments.members.length;
        if (funcDecl.variableArgList) {
            argsLen--;
        }

        for (var i = 0; i < argsLen; i++) {
            var argDecl = funcDecl.arguments.members[i];
            this.emitArgDecl(argDecl, funcDecl);
            if (i < (argsLen - 1)) {
                this.declFile.Write(", ");
            }
        }
    }

    if (funcDecl.variableArgList) {
        var lastArg = funcDecl.arguments.members[funcDecl.arguments.members.length - 1];
        if (funcDecl.arguments.members.length > 1) {
            this.declFile.Write(", ...");
        }
        else {
            this.declFile.Write("...");
        }

        this.emitArgDecl(lastArg, funcDecl);
    }

    if (!funcDecl.isIndexerMember()) {
        this.declFile.Write(")");
    }
    else {
        this.declFile.Write("]");
    }

    if (!funcDecl.isConstructor &&
        this.canEmitTypeAnnotationSignature(ToDeclFlags(funcDecl.getFunctionFlags()))) {
        var returnType = funcSignature.returnType;
        if (funcDecl.returnTypeAnnotation ||
            (returnType && returnType !== this.compiler.semanticInfoChain.anyTypeSymbol)) {
            this.declFile.Write(" as ");
            this.emitTypeSignature(returnType);
        }
    }

    this.declFile.WriteLine('');

    return false;
};

BooDeclEmitter.prototype.emitTypeParameters = function (typeParams, funcSignature) {
    if (!typeParams || !typeParams.members.length) {
        return;
    }

    this.declFile.Write("[of ");
    var containerAst = this.getAstDeclarationContainer();

    var start = new Date().getTime();
    var containerDecl = this.compiler.semanticInfoChain.getDeclForAST(containerAst, this.document.fileName);
    var containerSymbol = containerDecl.getSymbol();
    TypeScript.declarationEmitGetTypeParameterSymbolTime += new Date().getTime() - start;

    var typars; // PullTypeSymbol[];
    if (funcSignature) {
        typars = funcSignature.getTypeParameters();
    }
    else {
        typars = containerSymbol.getTypeArguments();
        if (!typars || !typars.length) {
            typars = containerSymbol.getTypeParameters();
        }
    }

    for (var i = 0; i < typars.length; i++) {
        if (i) {
            this.declFile.Write(", ");
        }

        var memberName = typars[i].getScopedNameEx(containerSymbol, /*useConstraintInName:*/ true);
        this.emitTypeNamesMember(memberName);
    }

    this.declFile.Write("]");
};

BooDeclEmitter.prototype.emitArgDecl = function (argDecl, funcDecl) {
    this.indenter.increaseIndent();

    this.emitDeclarationComments(argDecl, false);
    this.declFile.Write(argDecl.id.actualText);
    if (argDecl.isOptionalArg()) {
        this.declFile.Write("?");
    }

    this.indenter.decreaseIndent();

    if (this.canEmitTypeAnnotationSignature(ToDeclFlags(funcDecl.getFunctionFlags()))) {
        this.emitTypeOfBoundDecl(argDecl);
    }
};





// Create the declarations emitter to process the script 
var doc = compiler.getDocument(fname);
var declEmitter = new BooDeclEmitter('fname.boo', doc, compiler);
declEmitter.emitDeclarations(doc.script);

// We need to call close to actually dump the contents
declEmitter.close();
