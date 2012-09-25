"""
public abstract class Foo(object):

	public virtual def Pub() as void:
		pass

	protected virtual def Pro() as void:
		pass

	private virtual def Pri() as void:
		pass

	internal virtual def Int() as void:
		pass

	protected def constructor():
		super()

public class Bar(Foo):

	public def constructor():
		super()

	public override def Pub() as void:
		raise System.NotImplementedException()

	protected override def Pro() as void:
		raise System.NotImplementedException()

	private override def Pri() as void:
		raise System.NotImplementedException()

	internal override def Int() as void:
		raise System.NotImplementedException()
"""
class Foo:
	public abstract def Pub():
		pass
	protected abstract def Pro():
		pass
	private abstract def Pri():
		pass
	internal abstract def Int():
		pass

class Bar(Foo):
	pass

