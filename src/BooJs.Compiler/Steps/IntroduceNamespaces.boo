namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.TypeSystem.Core

class IntroduceNamespaces(IntroduceGlobalNamespaces):
    override def Run():
        NameResolutionService.Reset()
        NameResolutionService.GlobalNamespace = NamespaceDelegator(
            NameResolutionService.GlobalNamespace,
            SafeGetNamespace('BooJs.Macros'),
            SafeGetNamespace('BooJs.Lang'),
            SafeGetNamespace('Boo.Lang')
        )

        #SafeGetNamespace("Boo.Lang")
        #SafeGetNamespace("Boo.Lang.Extensions")
        #TypeSystemServices.BuiltinsType
