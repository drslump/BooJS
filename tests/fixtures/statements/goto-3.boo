#IGNORE Forward gotos are not supported
"""
0
1
2
"""
i = 0

goto test
:start

print i
++i

:test
goto start if i < 3
