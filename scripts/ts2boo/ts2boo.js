/*

*/

var fs = require('fs');

// Dirty import of the typescript compiler
eval(fs.readFileSync('typescript.js').toString());


var settings = new TypeScript.CompilationSettings();
var parseOptions = TypeScript.getParseOptions(settings);

var fname = 'code.ts';
var code = 'module Foo { export class Greeter { greeting: number; } }';
var source = TypeScript.SimpleText.fromString(code);


//compiler.getDocument(documentName)
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
compiler.settings = settings;

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

// TODO: Create custom DeclarationEmitter for Boo
TypeScript.DeclarationEmitter.prototype.variableDeclaratorCallback = function (pre, varDecl) {
    if (pre) {
       this.declFile.Write(varDecl.id.actualText);
       this.emitTypeOfBoundDecl(varDecl);
       this.declFile.WriteLine('');
    }

    return false;
};

TypeScript.DeclarationEmitter.prototype.emitTypeOfBoundDecl = function (boundDecl) {
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



// Create the declarations emitter to process the script 
var doc = compiler.getDocument(fname);
var declEmitter = new TypeScript.DeclarationEmitter('fname.d.ts', doc, compiler);
declEmitter.emitDeclarations(doc.script);

// We need to call close to actually dump the contents
declEmitter.close();
