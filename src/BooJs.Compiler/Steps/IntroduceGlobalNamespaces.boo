namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Steps.IntroduceGlobalNamespaces as BooStep
import Boo.Lang.Compiler.TypeSystem.Core


class IntroduceGlobalNamespaces(BooStep):
""" Configures the default namespaces available to the compiled code
"""
    override def Run():
        NameResolutionService.Reset()

        NameResolutionService.GlobalNamespace = NamespaceDelegator(
            NameResolutionService.GlobalNamespace,
            SafeGetNamespace('BooJs.Lang.Globals'),
            SafeGetNamespace('BooJs.Lang.Macros'),
            SafeGetNamespace('BooJs.Lang'),
            TypeSystemServices.BuiltinsType,
            # Make pattern maching macros globally available
            SafeGetNamespace('Boo.Lang.PatternMatching')
        )
