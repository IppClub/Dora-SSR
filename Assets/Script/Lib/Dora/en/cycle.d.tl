-- A function that keeps another function to run repeatedly for a duration of time.
-- @param duration (number) The duration of the cycle, in seconds.
-- @param work (function) A function to execute repeatedly during the cycle. receiving a time value from 0 to 1 to indicate the execution progress.
local cycle: function(duration: number, work: function(time: number))

return cycle
