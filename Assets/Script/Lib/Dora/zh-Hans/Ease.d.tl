-- 定义了用于动画中的一组缓动函数的模块类。
local record Ease

	-- 缓动函数对象类。
	record EaseFunc end

	-- 应用线性变化的缓动函数。
	const Linear: EaseFunc

	-- 开始缓慢并且加速快的缓动函数。
	const InQuad: EaseFunc

	-- 开始快速减速的缓动函数。
	const OutQuad: EaseFunc

	-- 开始缓慢加速，然后减速的缓动函数。
	const InOutQuad: EaseFunc

	-- 开始快速减速，然后加速的缓动函数。
	const OutInQuad: EaseFunc

	-- 开始缓慢加速的缓动函数。
	const InCubic: EaseFunc

	-- 开始快速减速的缓动函数。
	const OutCubic: EaseFunc

	-- 开始缓慢加速，然后减速的缓动函数。
	const InOutCubic: EaseFunc

	-- 开始快速减速，然后加速的缓动函数。
	const OutInCubic: EaseFunc

	-- 开始缓慢加速的缓动函数。
	const InQuart: EaseFunc

	-- 开始快速减速的缓动函数。
	const OutQuart: EaseFunc

	-- 开始缓慢加速，然后减速的缓动函数。
	const InOutQuart: EaseFunc

	-- 开始快速减速，然后加速的缓动函数。
	const OutInQuart: EaseFunc

	-- 开始缓慢加速的缓动函数。
	const InQuint: EaseFunc

	-- 开始快速减速的缓动函数。
	const OutQuint: EaseFunc

	-- 开始缓慢加速，然后减速的缓动函数。
	const InOutQuint: EaseFunc

	-- 开始快速减速，然后加速的缓动函数。
	const OutInQuint: EaseFunc

	-- 以正弦曲线方式缓慢加速的缓动函数。
	const InSine: EaseFunc

	-- 以正弦曲线方式快速减速的缓动函数。
	const OutSine: EaseFunc

	-- 以正弦曲线方式缓慢加速，然后减速的缓动函数。
	const InOutSine: EaseFunc

	-- 以正弦曲线方式快速减速，然后加速的缓动函数。
	const OutInSine: EaseFunc

	-- 以指数方式极慢加速的缓动函数。
	const InExpo: EaseFunc

	-- 以指数方式极快减速的缓动函数。
	const OutExpo: EaseFunc

	-- 以指数方式极慢加速，然后极快减速的缓动函数。
	const InOutExpo: EaseFunc

	-- 以指数方式极快减速，然后加速的缓动函数。
	const OutInExpo: EaseFunc

	-- 以圆弧曲线方式缓慢加速的缓动函数。
	const InCirc: EaseFunc

	-- 以圆弧曲线方式快速减速的缓动函数。
	const OutCirc: EaseFunc

	-- 以圆弧曲线方式缓慢加速，然后减速的缓动函数。
	const InOutCirc: EaseFunc

	-- 以圆弧曲线方式快速减速，然后加速的缓动函数。
	const OutInCirc: EaseFunc

	-- 以反弹方式缓慢加速，然后返回目标。
	const InElastic: EaseFunc

	-- 以反弹方式快速减速，然后返回目标。
	const OutElastic: EaseFunc

	-- 以反弹方式缓慢加速，然后返回目标，然后减速，再次反弹。
	const InOutElastic: EaseFunc

	-- 以反弹方式快速减速，然后返回目标，然后加速，再次反弹。
	const OutInElastic: EaseFunc

	-- 向后急剧加速，然后返回目标。
	const InBack: EaseFunc

	-- 向后急剧减速，然后返回目标。
	const OutBack: EaseFunc

	-- 向后急剧加速，然后向前急剧减速，然后返回目标。
	const InOutBack: EaseFunc

	-- 向前急剧减速，然后向后急剧加速，然后返回目标。
	const OutInBack: EaseFunc

	-- 以反弹方式缓慢加速，然后落回目标。
	const InBounce: EaseFunc

	-- 以反弹方式快速减速，然后落回目标。
	const OutBounce: EaseFunc

	-- 以反弹方式缓慢加速，然后缓慢减速，然后落回目标。
	const InOutBounce: EaseFunc

	-- 以反弹方式快速减速，然后快速加速，然后落回目标。
	const OutInBounce: EaseFunc

	-- 对给定的时间值应用缓动函数，计算得到对应的缓动值。
	-- @param easing (EaseFunc) 要应用的缓动函数。
	-- @param time (number) 应用缓动函数的时间值，取值范围为0-1。
	-- @return (number) 将缓动函数应用于时间值的结果。
	func: function(self: Ease, easing: EaseFunc, time: number): number
end

return Ease
