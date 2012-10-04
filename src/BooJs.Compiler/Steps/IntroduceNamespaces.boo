namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.TypeSystem.Core

class IntroduceNamespaces(IntroduceGlobalNamespaces):

    override def Run():
        NameResolutionService.Reset()
        NameResolutionService.GlobalNamespace = NamespaceDelegator(
            NameResolutionService.GlobalNamespace,
            SafeGetNamespace('BooJs.Lang.Globals'),
            SafeGetNamespace('BooJs.Lang.Macros'),
            TypeSystemServices.BuiltinsType
        )
