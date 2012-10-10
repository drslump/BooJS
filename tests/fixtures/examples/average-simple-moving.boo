"""
Next number = 1, SMA_3 = 1, SMA_5 = 1
Next number = 2, SMA_3 = 1, SMA_5 = 1
Next number = 3, SMA_3 = 2, SMA_5 = 2
Next number = 4, SMA_3 = 3, SMA_5 = 2
Next number = 5, SMA_3 = 4, SMA_5 = 3
Next number = 5, SMA_3 = 4, SMA_5 = 3
Next number = 4, SMA_3 = 4, SMA_5 = 4
Next number = 3, SMA_3 = 4, SMA_5 = 4
Next number = 2, SMA_3 = 3, SMA_5 = 3
Next number = 1, SMA_3 = 2, SMA_5 = 3
"""
def simple_moving_averager(period as int):
    nums as (int) = []
    return do(num as int):
        nums.push(num)
        if len(nums) > period:
            nums.splice(0, 1)  # remove the first element of the array
        sum = 0
        for n in nums:
            sum += n
        n = period
        if len(nums) < period:
            n = len(nums)
        return sum / n

sma3 = simple_moving_averager(3)
sma5 = simple_moving_averager(5)
data = [1,2,3,4,5,5,4,3,2,1]
for n in data:
    print "Next number = $n, SMA_3 = $(sma3(n)), SMA_5 = $(sma5(n))"
