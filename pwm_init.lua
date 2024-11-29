local pwm_init = {}
--[[
	时间：2024年11月27日12:04
	作者：BSCC_GN
	功能：主要是初始化PWM，本文件是用于控制蜂鸣器的。
	注意事项：只有蜂鸣器功能，其他功能暂时未实现。
	版本：v1.0.1
	修订记录：
	1. 创建文件
	2.创建音调与频率的定义
	3.完成提示音播放功能
]]

---------------------初始化GPIO------------------------
--电路的网络编号与GPIO编号匹配
local BUZZER = 18 --蜂鸣器控制管脚
--定义PWM的占空比
local PWM_Duty = 50 --占空比

--选择蜂鸣器播放提的示音
local buzzer_flag = 0  --1开机，2关机，3AC开启，4AC关闭，5按键

---------------------定义蜂鸣器的音调与频率---------------------
--[[  上面有点的是高音，下面有点的是低音，没有点的是中音。
对应的音区，我们称之为低音区，中音区，高音区。]]
--A调：低音、中音、高音
--[[ local A_tone={
    bass={221,248,278,294,330,371,416},         --低音
    Baritone={441,495,556,589,661,742,833},     --中音
    treble={882,990,1112,1178,1322,1484,1665}   --高音
}
--B调：低音、中音、高音
local B_tone={
    bass={248,278,294,330,371,416,467},         --低音
    Baritone={495,556,624,661,742,833,935},     --中音
    treble={990,1112,1178,1322,1484,1665,1869} 	--高音
}
--C调：低音、中音、高音
local C_tone={
    bass={131,147,165,175,196,221,248},			--低音
    Baritone={262,294,330,350,393,441,495},	    --中音
    treble={525,589,661,700,786,882,990}    	--高音
}
--D调：低音、中音、高音
local D_tone={
    bass={147,165,175,196,221,248,278},        --低音
    Baritone={294,330,350,393,441,495,556},    --中音
    treble={589,661,700,786,882,990,1112}      --高音
}
--E调：低音、中音、高音
local E_tone={
    bass={165,175,196,221,248,278,312},        --低音
    Baritone={330,350,393,441,495,556,624},    --中音
    treble={661,700,786,882,990,1112,1248}     --高音
}
--F调：低音、中音、高音
local F_tone={
    bass={175,196,221,234,262,294,330},        --低音
    Baritone={350,393,441,465,556,624,661},    --中音
    treble={700,786,882,935,1049,1178,1322}    --高音
} ]]
--G调：低音、中音、高音
local G_tone={
    bass={196,221,234,262,294,330,371},        --低音
    Baritone={393,441,495,556,624,661,742},    --中音
    treble={786,882,990,1049,1178,1322,1484}   --高音
}

--开关机提示音的频率
local frequency = {
	G_tone.treble[1],--开机高音
	G_tone.Baritone[1],--开机中音
	G_tone.bass[1]--开机低音
}

--定义PWM控制函数的名称
local PWM_Buzzer

--定义蜂鸣器输出函数
--输入参数：频率
local function PWM_Buzzer(Freq)
    print("蜂鸣器频率："..Freq)
	pwm.open(BUZZER,Freq,PWM_Duty)
end

--定义蜂鸣器播放提示音的函数
--输入参数：数字，1开机，2关机，3AC开启，4AC关闭，5按键
local function buzzer_play(data)
	if data == 1 then--开机
		print("蜂鸣器开机提示音")
		for i = 3, 1, -1 do
			--print("第"..i.."声")
			PWM_Buzzer(frequency[i])
			sys.wait(200)
		end
	elseif data == 2 then--关机
		print("蜂鸣器关机提示音")
		for i = 1, 3, 1 do
			--print("第"..i.."声")
			PWM_Buzzer(frequency[i])
			sys.wait(200)
		end
	elseif data == 3 then--AC开启
		print("蜂鸣器AC开启提示音")
		PWM_Buzzer(G_tone.bass[5])
		sys.wait(300)
		PWM_Buzzer(G_tone.Baritone[2])
		sys.wait(300)
	elseif data == 4 then--AC关闭
		print("蜂鸣器AC关闭提示音")
		PWM_Buzzer(G_tone.Baritone[5])
		sys.wait(300)
		PWM_Buzzer(G_tone.Baritone[3])
		sys.wait(300)
	elseif data == 5 then--按键提示音
		print("蜂鸣器按键提示音")
		PWM_Buzzer(G_tone.treble[4])
		sys.wait(100)
	end
	--data = 0--清空提示音标志
	buzzer_flag = 0--清空提示音标志
	pwm.close(BUZZER)-- 关闭PWM输出
end




--订阅系统开机事件，回调函数，输出开机音频
sys.subscribe("ESP_ON",function()
    print("订阅到ESP_ON消息")
	--buzzer_flag = 1--开机提示音
end)



--任务
sys.taskInit(function()
    while 1 do
		--播放提示音
		buzzer_play(buzzer_flag)
        sys.wait(1000)
    end
end)





return pwm_init
