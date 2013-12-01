namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler.TypeSystem.Core import NamespaceDelegator
from Boo.Lang.Compiler.Steps import IntroduceGlobalNamespaces as BooStep


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
