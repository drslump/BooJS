namespace BooJs.Lang.Runtime

import BooJs.Lang

class RuntimeServices:
    # Use generics to keep type information
    static def slice[of T](list as T*, begin as Number) as T:
        pass
    static def slice[of T](list as T*, begin as Number, end as Number) as T*:
        pass
    static def slice[of T](list as T*, begin as Number, end as Number, step as Number) as T*:
        pass

