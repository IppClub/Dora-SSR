-- 在一段时间内每帧重复运行一个函数的携程。
-- @param duration (number) 持续运行的时间，以秒为单位。
-- @param work (function) 在持续运行期间被重复执行的函数。将接收一个时间进度参数time，告知已经过的运行时间，参数值区间为0-1，0表示刚开始，1表示刚结束。
local cycle: function(duration: number, work: function(time: number))

return cycle
