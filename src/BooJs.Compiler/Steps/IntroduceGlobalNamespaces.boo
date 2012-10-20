namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Steps.IntroduceGlobalNamespaces as BooStep
import Boo.Lang.Compiler.TypeSystem.Core


class IntroduceGlobalNamespaces(BooStep):

    override def Run():
        NameResolutionService.Reset()

        NameResolutionService.GlobalNamespace = NamespaceDelegator(
            NameResolutionService.GlobalNamespace,
            SafeGetNamespace('BooJs.Lang.Globals'),
            SafeGetNamespace('BooJs.Lang.Macros'),
            SafeGetNamespace('BooJs.Lang'),
            TypeSystemServices.BuiltinsType
        )

