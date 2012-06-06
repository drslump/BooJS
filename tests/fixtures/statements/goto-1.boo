"""
@IGNORE@ Forward gotos are not supported
before
after
"""
print 'before'
goto end
print 'skipped'
:end
print 'after'


