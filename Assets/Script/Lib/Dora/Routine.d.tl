local record Routine
	{Job}
	record Job
		metamethod __call: function(...: any): any...
	end
	remove: function(self: Routine, job: Job): boolean
	clear: function(self: Routine)
	metamethod __call: function(self: Routine, job: Job): Job
end
local routine: Routine
return routine
