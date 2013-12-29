#UNSUPPORTED: Generics not supported yet
import System.Collections.Generic

assert List of int is typeof(List of *).MakeGenericType(int)
