-- A record that defines a set of easing functions for use in animations.
local record Ease

	-- A record type that is used to define each easing function.
	record EaseFunc end

	-- An easing function that applies a linear rate of change.
	const Linear: EaseFunc

	-- An easing function that starts slow and accelerates quickly.
	const InQuad: EaseFunc

	-- An easing function that starts fast and decelerates quickly.
	const OutQuad: EaseFunc

	-- An easing function that starts slow, accelerates, then decelerates.
	const InOutQuad: EaseFunc

	-- An easing function that starts fast, decelerates, then accelerates.
	const OutInQuad: EaseFunc

	-- An easing function that starts slow and accelerates gradually.
	const InCubic: EaseFunc

	-- An easing function that starts fast and decelerates gradually.
	const OutCubic: EaseFunc

	-- An easing function that starts slow, accelerates, then decelerates.
	const InOutCubic: EaseFunc

	-- An easing function that starts fast, decelerates, then accelerates.
	const OutInCubic: EaseFunc

	-- An easing function that starts slow and accelerates sharply.
	const InQuart: EaseFunc

	-- An easing function that starts fast and decelerates sharply.
	const OutQuart: EaseFunc

	-- An easing function that starts slow, accelerates sharply, then decelerates sharply.
	const InOutQuart: EaseFunc

	-- An easing function that starts fast, decelerates sharply, then accelerates sharply.
	const OutInQuart: EaseFunc

	-- An easing function that starts slow and accelerates extremely quickly.
	const InQuint: EaseFunc

	-- An easing function that starts fast and decelerates extremely quickly.
	const OutQuint: EaseFunc

	-- An easing function that starts slow, accelerates extremely quickly, then decelerates extremely quickly.
	const InOutQuint: EaseFunc

	-- An easing function that starts fast, decelerates extremely quickly, then accelerates extremely quickly.
	const OutInQuint: EaseFunc

	-- An easing function that starts slow and accelerates gradually, then slows down again.
	const InSine: EaseFunc

	-- An easing function that starts fast and decelerates gradually, then slows down again.
	const OutSine: EaseFunc

	-- An easing function that starts slow, accelerates gradually, then decelerates gradually.
	const InOutSine: EaseFunc

	-- An easing function that starts fast, decelerates gradually, then accelerates gradually.
	const OutInSine: EaseFunc

	-- An easing function that starts extremely slow and accelerates exponentially.
	const InExpo: EaseFunc

	-- An easing function that starts extremely fast and decelerates exponentially.
	const OutExpo: EaseFunc

	-- An easing function that starts extremely slow, accelerates exponentially, then decelerates exponentially.
	const InOutExpo: EaseFunc

	-- An easing function that starts extremely fast, decelerates exponentially, then accelerates exponentially.
	const OutInExpo: EaseFunc

	-- An easing function that starts slow and accelerates gradually in a circular fashion.
	const InCirc: EaseFunc

	-- An easing function that starts fast and decelerates gradually in a circular fashion.
	const OutCirc: EaseFunc

	-- An easing function that starts slow, accelerates gradually in a circular fashion, then decelerates gradually in a circular fashion.
	const InOutCirc: EaseFunc

	-- An easing function that starts fast, decelerates gradually in a circular fashion, then accelerates gradually in a circular fashion.
	const OutInCirc: EaseFunc

	-- An easing function that starts slow and accelerates exponentially, overshooting the target and then returning to it.
	const InElastic: EaseFunc

	-- An easing function that starts fast and decelerates exponentially, overshooting the target and then returning to it.
	const OutElastic: EaseFunc

	-- An easing function that starts slow, accelerates exponentially, overshooting the target and then returning to it, then decelerates exponentially, overshooting the target and then returning to it again.
	const InOutElastic: EaseFunc

	-- An easing function that starts fast, decelerates exponentially, overshooting the target and then returning to it, then accelerates exponentially, overshooting the target and then returning to it again.
	const OutInElastic: EaseFunc

	-- An easing function that starts slow and accelerates sharply backward before returning to the target.
	const InBack: EaseFunc

	-- An easing function that starts fast and decelerates sharply backward before returning to the target.
	const OutBack: EaseFunc

	-- An easing function that starts slow, accelerates sharply backward, then decelerates sharply forward before returning to the target.
	const InOutBack: EaseFunc

	-- An easing function that starts fast, decelerates sharply backward, then accelerates sharply forward before returning to the target.
	const OutInBack: EaseFunc

	-- An easing function that starts slow and accelerates in a bouncing motion before settling on the target.
	const InBounce: EaseFunc

	-- An easing function that starts fast and decelerates in a bouncing motion before settling on the target.
	const OutBounce: EaseFunc

	-- An easing function that starts slow, accelerates in a bouncing motion, then decelerates in a bouncing motion before settling on the target.
	const InOutBounce: EaseFunc

	-- An easing function that starts fast, decelerates in a bouncing motion, then accelerates in a bouncing motion before settling on the target.
	const OutInBounce: EaseFunc

	-- Applies an easing function to a given value over a given amount of time.
	-- @param easing (EaseFunc) The easing function to apply.
	-- @param time (number) The amount of time to apply the easing function over, should be 0 to 1.
	-- @return (number) The result of applying the easing function to the value.
	func: function(self: Ease, easing: EaseFunc, time: number): number
end

return Ease
