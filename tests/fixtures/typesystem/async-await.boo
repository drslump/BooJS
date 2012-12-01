"""
start
0
1
2
Waiting 100...
Waited for 0.1
Waiting 200...
Waited for 0.2
end
"""

import Async

# Either as an attribute or a simple function
[async] def foo():
    print 'start'
    try:
        for i in range(3):
            print i

        for delay in (100ms, 200ms):
            print "Waiting $delay..."
            await delay = sleep(delay)
            print "Waited for 0.$(delay/100)"
        
    except:
        print 'Error'

    print 'end'


foo();
