#UNSUPPORTED: forward Goto not supported
"""
ding
ding
ding
"""
i = 0

goto test
:start
print("ding")
i += 1
:test
goto start if i < 3

