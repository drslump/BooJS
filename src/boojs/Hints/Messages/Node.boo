namespace boojs.Hints.Messages


class Node:
""" Used for generating the outline """
    public type as string
    public name as string
    public desc as string
    public visibility as string
    public line as int
    public length as int
    public members as List[of Node]

    def constructor():
        members = List[of Node]()
