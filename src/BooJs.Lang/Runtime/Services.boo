namespace BooJs.Lang.Runtime

class Services:
    # Use generics to keep type information
    static def slice[of T](list as T*, begin as int) as T:
        pass
    static def slice[of T](list as T*, begin as int, end as int) as T*:
        pass
    static def slice[of T](list as T*, begin as int, end as int, step as int) as T*:
        pass

