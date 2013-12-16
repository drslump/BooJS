#IGNORE: Ast types not supported
"""
literal = [| print('Hello, world') |]
literal = [| System.Console.WriteLine("\$message") |]
"""
literal = [| print("Hello, world") |]
literal = [| System.Console.WriteLine("${message}") |]
