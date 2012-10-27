namespace BooJs.Compiler.TypeSystem

import Boo.Lang.Compiler.TypeSystem(IType)
import Boo.Lang.Compiler.TypeSystem.Reflection(ExternalType)
import Boo.Lang.Compiler.TypeSystem.Services.DowncastPermissions as BooDowncastPermissions


class DowncastPermissions(BooDowncastPermissions):

    protected virtual def CanBeReachedByInterfaceDowncast(expected as IType, actual as IType) as bool:
        // Boo would always downcast if one of the types is an interface (see BOO-1211).
        // Here we check if the expected type is an interface and if it's probably safe to
        // downcast the actual value by checking the expected type against the interfaces
        // the actual value implements.
        if expected.IsInterface and external = actual as ExternalType:
            for iface in external.GetInterfaces():
                return true if iface.IsAssignableFrom(expected)
            return false

        return true

