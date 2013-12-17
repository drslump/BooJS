"""
goto start if (i < 3)
goto finish
"""
i = 1
:start
i++
goto start if i < 3
goto finish
:finish

