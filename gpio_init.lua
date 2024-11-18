local gpio_init = {}
--[[
	时间：2024年11月15日20:46
	作者：BSCC_GN
	功能：只是初始化GPIO，包括LED，按键，继电器等。
	注意事项：无
	版本：v1.0.0
	修订记录：
	1. 创建文件
	2. 完成硬件初始化与建立简单的管脚控制函数
]]

---------------------初始化GPIO-----------------------------
local ESP_OFF_ON --系统供电控制
local Power_out --电源输出控制
local PWM_ID = 18 -- 蜂鸣器控制管脚



--继电器输出控制
local function initialization() -- 内部方法, 外部无法调用
    --设置为上拉输出模式，初始状态为硬件匹配的电平
    ESP_OFF_ON=gpio.setup(9, 1 ,gpio.PULLUP)
    Power_out=gpio.setup(5, 0 ,gpio.PULLUP)
end
initialization() --直接调用，在main.lua文件中require"hardware_init"的时候则会调用该函数

-- 定义继电器输出函数,输入参数为继电器的输出状态，
local function Relay_output(ESP,Power)
    print("ESP_OFF_ON=",ESP,"Power_out=",Power)
	if ESP then
		print("打开ESP")
        ESP_OFF_ON(1)
	else
		print("关闭ESP")
        ESP_OFF_ON(0)
	end
	if Power then
		print("打开电源")
        Power_out(1)
	else
		print("关闭电源")
        Power_out(0)
	end
end

--单独订阅，回调函数，接收系统与电源的输出控制命令
sys.subscribe("ESP_Power",function(data)
    Relay_output(data.ESP,data.Power)
end)


--蜂鸣器控制函数
local function beep_control(status)
    if status then
        pwm.open(PWM_ID, 1100, 10) -- 频率1100Hz，占空比10%
    else
        pwm.close(PWM_ID) -- 关闭蜂鸣器
    end
end

-- 音符频率定义（单位：毫赫兹）
local notes = {
    C4 = 261,
    D4 = 294,
    E4 = 329,
    F4 = 349,
    G4 = 392,
    A4 = 440,
    B4 = 493,
}


-- 播放旋律的函数
local function play_melody()
    local frequency1 = notes.D4  -- 获取音符频率
    local frequency2 = notes.E4  -- 获取音符频率
    for i = frequency1, frequency2 , 10 do
        beep_control(true)
        pwm.open(PWM_ID, i, 7) -- 频率1100Hz，占空比10%
        sys.wait(200) -- 音符间隔时间
    end
end






sys.taskInit(function()
    --防止开机日志没有打印出来
    sys.wait(1000)
    print("GPIO初始化完成")
    --beep_control(true)
    print("系统已启动")
    sys.wait(300)
    play_melody()
    beep_control(false)
    while 1 do





        sys.wait(3000)
    end
end)





return gpio_init
