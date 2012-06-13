# Simple types
my_int as int = -10
my_uint as uint = 100
my_double as double = 0.54
my_bool as bool = true
my_string as string = 'string'
my_callable as callable = {x as int| x*2}

# Super type
my_object_int as object = 10
my_object_bool as object = true
my_object_str as object = 'string'
my_object_arr as object = (1,2,3)

# Javascript types
my_Number as Number = 100
my_String as String = 'string'
my_RegExp as RegExp = /foobar/i
#my_Function as Function = {x as int| x * 2}
my_Object as Object = {}
my_Object.foo = 'foo'

# Arrays
my_array_int as (int) = (1,2,3)
my_array_obj as (object) = (1,'two',false)
#my_array_js as (Number) = (1, 0.50, -100)

# Duck typing
my_duck as duck = 10
my_duck = 0.50
my_duck = 'foobar'
my_duck = my_Number
my_duck = my_callable
my_duck = my_array_int

my_int = my_duck
my_bool = my_duck

# Functions/Constructors
my_func as Function
#my_func(10, 20)

# Creating new instances with the new keyword
my_obj as Object
#my_obj('foo')  # -> new my_obj('foo')
# my_cons as Constructor
# my_cons('foo')  # -> new my_cons('foo')
