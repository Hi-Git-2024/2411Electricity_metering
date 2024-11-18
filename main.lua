-- LuaTools需要PROJECT和VERSION这两个信息
PROJECT = "Electricity_metering"
VERSION = "1.0.0"

-- 引入必要的库文件(lua编写), 内部库不需要require
sys = require("sys")
require("sysplus")


--硬件初始化
local gpio_init = require "gpio_init"


--软件始化
--local Power_time = require "Power_time"--获取开机次数与上次运行时间标志位
--local WiFi = require "WiFi"--连接wifi模块
--local Relayoutput = require "Relayoutput"--继电器控制模块
------------------WiFi  与  Relayoutput   同时打开会一直重启，，，，，，，原因未知 --------------------------------
-----------原因是ESP32的协程不能同时开太多----------------------------

--添加硬狗防止程序卡死
if wdt then
    wdt.init(9000)--初始化watchdog设置为9s
    sys.timerLoopStart(wdt.feed, 3000)--3s喂一次狗
end

--创建任务
sys.taskInit(function()
    while true do
        sys.wait(1000) --延时1秒，这段时间里可以运行其他代码
    end
end)


-- 用户代码已结束---------------------------------------------
-- 结尾总是这一句
sys.run()
-- sys.run()之后后面不要加任何语句!!!!!
