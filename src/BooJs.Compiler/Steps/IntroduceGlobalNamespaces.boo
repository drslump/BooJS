namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Steps.IntroduceGlobalNamespaces as BooStep
import Boo.Lang.Compiler.TypeSystem.Core


class IntroduceGlobalNamespaces(BooStep):

    override def Run():
        NameResolutionService.Reset()

        NameResolutionService.GlobalNamespace = NamespaceDelegator(
            NameResolutionService.GlobalNamespace,  # TODO: Do we need this for Boo.Lang ??
            SafeGetNamespace('BooJs.Lang.Globals'),
            SafeGetNamespace('BooJs.Lang.Macros'),
            SafeGetNamespace('BooJs.Lang'),  # TODO: Do we actually need this ?
            TypeSystemServices.BuiltinsType
        )

