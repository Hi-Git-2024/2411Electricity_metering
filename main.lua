-- LuaTools需要PROJECT和VERSION这两个信息
PROJECT = "Electricity_metering"
VERSION = "1.0.0"

-- 引入必要的库文件(lua编写), 内部库不需要require
sys = require("sys")
require("sysplus")

--[[
完成继电器的控制
完成温度的采集
完成蜂鸣器提示音的控制

下一步是完成电量计量的功能
再下一步是完成按键的控制功能
再下一步是完成OLED显示功能
再下一步是充电管理功能显示界面与按键的互动
再下一步是完成WEB页面的设计，实现界面与功能的互动
]]

--硬件初始化
local gpio_init = require "gpio_init"
local pwm_init = require "pwm_init"
local DS18B20_init = require "DS18B20_init"
local HLW8032 = require "HLW8032"
local string_HEX = require "string_HEX"

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
