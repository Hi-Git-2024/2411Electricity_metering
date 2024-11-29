local gpio_init = {}
--[[
	时间：2024年11月15日20:46
	作者：BSCC_GN
	功能：只是初始化GPIO，包括控制IO口的输出状态与输入状态
	注意事项：无PWM功能。
	版本：v1.0.1
	修订记录：
	1. 创建文件
	2. 完成硬件初始化与建立简单的管脚控制函数
]]

---------------------初始化GPIO------------------------
--电路的网络编号与GPIO编号匹配
local ESP_OFF_ON = 9 --系统供电控制管脚
local K_OFF_ON = 5 --AC电源输出控制管脚

--定义GPIO的控制函数名称
local ESP_Power -- 系统供电控制函数
local AC_Power   -- AC电源输出控制函数

--定义按键开机时间
local power_on_time = 2000 --开机时间，单位：毫秒

--继电器输出控制
local function initialization() -- 内部方法, 外部无法调用
    --设置为上拉输出模式，初始状态低电平
    ESP_Power=gpio.setup(ESP_OFF_ON, 0 ,gpio.PULLUP)
    AC_Power=gpio.setup(K_OFF_ON, 0 ,gpio.PULLUP)
    print("GPIO初始化完成")
end
initialization() --直接调用，在main.lua文件中require"gpio_init"的时候则会调用该函数

-- 定义继电器输出函数,输入参数为继电器的输出状态
-- ESP=true 打开ESP, ESP=false 关闭ESP
-- AC=true 打开AC电源, AC=false 关闭AC电源
local function Relay_output(ESP,AC)
    print("ESP_OFF_ON=",ESP,"Power_out=",AC)
	if ESP then
		print("打开ESP")
        ESP_Power(1)
	else
		print("关闭ESP")
        ESP_Power(0)
	end
	if AC then
		print("打开AC电源")
        AC_Power(1)
	else
		print("关闭AC电源")
        AC_Power(0)
	end
end

---------------------------------------------------------------------------------
--[[
外部调用接口
local data = {ESP=true,AC=true}--设置系统与AC电源的输出状态
sys.publish("ESP_AC_Control",data)--发布ESP_AC_Control，控制PSE与AC电源的输出状态
]]
--单独订阅，回调函数，接收系统与AC电源的输出控制命令
sys.subscribe("ESP_AC_Control",function(data)
    print("订阅到ESP_AC_Control消息")
    Relay_output(data.ESP,data.AC)
end)


--一键开关机与开机默认状态
sys.timerStart(function()	--开启一个一次性定时器
    --Relay_output(true,false) --默认打开系统，关闭AC电源
    Relay_output(true,true) --默认打开系统，打开AC电源
--[[     local data = {ESP=true,AC=true}--设置系统与AC电源的输出状态
    sys.publish("ESP_AC_Control",data)--发布ESP_AC_Control，控制PSE与AC电源的输出状态 ]]
    log.info("系统已开机")
    sys.publish("ESP_ON")--发布系统开机消息
end,power_on_time)--根据实际情况修改开机时间


--任务
sys.taskInit(function()
    while 1 do
        sys.wait(1000)
    end
end)





return gpio_init
