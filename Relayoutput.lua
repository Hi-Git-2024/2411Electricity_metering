local Relayoutput = {}
--[[
	时间：2024年6月5日17:00
	作者：BSCC_GN
	功能：用于控制继电器的输出的API
]]
-- 定义全局变量，用于记录继电器的输出状态
local Relay_Flag = false
-- 用于接收继电器控制的时间
local Relay_time = {}
--用于接收继电器的输出状态
local Relay_OUT_MSG ={}
--用于接收继电器的按键匹配
local Relay_OUT_Keyk ={}
--用于接收继电器的按键标志位
local Relay_Keyk ={false,false,false,false,false}


--接收到继电器的状态数据
sys.subscribe("Relay_OUT_dataa",function(data)--订阅消息，当收到消息时，执行回调函数
	print("接收到继电器的状态数据")
	Relay_OUT_MSG = data
	for i=1,50 do
		print("Relay_OUT_MSG",i,Relay_OUT_MSG[i][1],Relay_OUT_MSG[i][2],Relay_OUT_MSG[i][3],Relay_OUT_MSG[i][4],Relay_OUT_MSG[i][5],Relay_OUT_MSG[i][6],Relay_OUT_MSG[i][7],Relay_OUT_MSG[i][8])
	end
end)
--接收到继电器的控制时间
sys.subscribe("Relay_OUT_time",function(data)--订阅消息，当收到消息时，执行回调函数
	print("接收到继电器的控制时间")
	Relay_time = data
	for i=1,50 do
		print("Relay_time",i,Relay_time[i])
	end
end)
--接收到继电器的按键匹配
sys.subscribe("Relay_OUT_Key",function(data)--订阅消息，当收到消息时，执行回调函数
	print("接收到继电器的按键匹配")
	Relay_OUT_Keyk = data
	print("Process1",table.concat(Relay_OUT_Keyk.Process1, "|"))
	print("Process2",table.concat(Relay_OUT_Keyk.Process2, "|"))
	print("Process3",table.concat(Relay_OUT_Keyk.Process3, "|"))
	print("Process4",table.concat(Relay_OUT_Keyk.Process4, "|"))
	print("PC",table.concat(Relay_OUT_Keyk.PC, "|"))
end)
--接收到继电器的按键控制
sys.subscribe("Relay_IN_Key",function(data)--订阅消息，当收到消息时，执行回调函数
	print("接收到继电器的按键控制")
	--继电器的按键标志位
	Relay_Keyk = data
	if Relay_Keyk[4] then
		Relay_Flag = false
	else
		--继电器的输出状态
		Relay_Flag = true
	end
end)

sys.timerStart(function()--sys.timerStart开启一个一次性定时器
	local Relay_Keykkkk ={false,false,true,false,false}
	--sys.publish("Relay_IN_Key",Relay_Keykkkk)--发布这个消息，让设备停止打印
end,10000)


sys.timerStart(function()--sys.timerStart开启一个一次性定时器
	local Relay_Keykkkk ={false,false,false,true,false}
	--sys.publish("Relay_IN_Key",Relay_Keykkkk)--发布这个消息，让设备停止打印
end,20000)


--继电器的控制
sys.taskInit(function()
    while true do
		if Relay_Flag then
			--Relay_Flag = false
			local t1,t2 = 0 , 0
			if Relay_Keyk[1] then
				t1 = Relay_OUT_Keyk.Process1[1]
				t2 = Relay_OUT_Keyk.Process1[2]
			end
			if Relay_Keyk[2] then
				t1 = Relay_OUT_Keyk.Process2[1]
				t2 = Relay_OUT_Keyk.Process2[2]
				Relay_Keyk[5] = true
			end
			if Relay_Keyk[3] then
				t1 = Relay_OUT_Keyk.Process3[1]
				t2 = Relay_OUT_Keyk.Process3[2]
			end
			--[[ if Relay_Keyk[4] then
				t1 = Relay_OUT_Keyk.Process4[1]
				t2 = Relay_OUT_Keyk.Process4[2]
			end ]]
			if Relay_Keyk[1] or Relay_Keyk[2] or Relay_Keyk[3]  then
				local data = {}
				for i=t1,t2 do
					print(i)
					data = {Relay_OUT_MSG[i][1],Relay_OUT_MSG[i][2],Relay_OUT_MSG[i][3],Relay_OUT_MSG[i][4],Relay_OUT_MSG[i][5],Relay_OUT_MSG[i][6],Relay_OUT_MSG[i][7],Relay_OUT_MSG[i][8]}
					--print("继电器发送的数据",data[1],data[2],data[3],data[4],data[5],data[6],data[7])
					sys.publish("Relay_OUT_gpio",data)--发布这个消息，控制继电器的输出状态
					print("继电器运行时间："..Relay_time[i].."秒")
					sys.wait(1000*Relay_time[i])
					print("继电器运行结束")
					if Relay_OUT_Keyk.PC[1] == i then
						if Relay_Keyk[5] then
							--print("控制PC",table.concat(Relay_OUT_Keyk.PC, "|"))
							print("PC控制收到")
							--sys.wait(1000*Relay_OUT_Keyk.PC[1])
							print("开启PC控制")
							sys.publish("Relay_OUT_PC",true)--发布这个消息，控制PC
							sys.wait(1000*Relay_OUT_Keyk.PC[2])
							print("关闭PC控制")
							sys.publish("Relay_OUT_PC",false)--发布这个消息，控制PC
						end
						Relay_Keyk[5] = false
					end
				end
			end
			if Relay_Keyk[5] then
				--print("控制PC",table.concat(Relay_OUT_Keyk.PC, "|"))
				print("PC控制收到")
				--sys.wait(1000*Relay_OUT_Keyk.PC[1])
				print("开启PC控制")
				sys.publish("Relay_OUT_PC",true)--发布这个消息，控制PC
				sys.wait(1000*Relay_OUT_Keyk.PC[2])
				print("关闭PC控制")
				sys.publish("Relay_OUT_PC",false)--发布这个消息，控制PC
			end
			Relay_Flag = false
		end
		sys.wait(1000) --延时1秒，这段时间里可以运行其他代码
    end
end)

--继电器的加液控制
sys.taskInit(function()
    while true do
		if Relay_Keyk[4] then
			Relay_Keyk[4] = false
			local t1,t2 = 0 , 0
			t1 = Relay_OUT_Keyk.Process4[1]
			t2 = Relay_OUT_Keyk.Process4[2]
			local data = {}
			for i=t1,t2 do
				print(i)
				data = {Relay_OUT_MSG[i][1],Relay_OUT_MSG[i][2],Relay_OUT_MSG[i][3],Relay_OUT_MSG[i][4],Relay_OUT_MSG[i][5],Relay_OUT_MSG[i][6],Relay_OUT_MSG[i][7],Relay_OUT_MSG[i][8]}
				--print("继电器发送的数据",data[1],data[2],data[3],data[4],data[5],data[6],data[7])
				sys.publish("Relay_OUT_gpio",data)--发布这个消息，控制继电器的输出状态
				print("加液时间："..Relay_time[i].."秒")
				sys.wait(1000*Relay_time[i])
				print("加液结束")
			end
		end
		sys.wait(1000) --延时1秒，这段时间里可以运行其他代码
    end
end)

return Relayoutput
