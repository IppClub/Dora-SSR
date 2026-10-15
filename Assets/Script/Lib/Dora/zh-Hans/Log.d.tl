-- 表示日志级别的枚举
local enum LogLevel
	"Info"
	"Warn"
	"Error"
end

-- 向控制台记录一条日志消息。
-- @param level ("Info" | "Warn" | "Error") 要记录的日志消息级别。
-- @param msg (string) 要记录的日志消息。
local log: function(level: LogLevel, msg: string)

return log
