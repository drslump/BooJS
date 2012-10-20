namespace BooJs.Compiler.Mozilla

abstract class Visitor:

    virtual def Visit(node as Node):
        if node is not null:
            node.Apply(self)

    virtual def Visit[of T(INode)](nodes as List[of T]):
        for node in nodes:
            Visit(node as Node)
