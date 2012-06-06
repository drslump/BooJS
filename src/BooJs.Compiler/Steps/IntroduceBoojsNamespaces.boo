namespace Boojs.Compiler.Steps

import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.TypeSystem.Core

class IntroduceNamespaces(IntroduceGlobalNamespaces):
    override def Run():
        NameResolutionService.Reset()
        NameResolutionService.GlobalNamespace = NamespaceDelegator(
                                        NameResolutionService.GlobalNamespace,
                                        SafeGetNamespace("Boojs.Macros"),
                                        SafeGetNamespace("Boojs.Lang"))
