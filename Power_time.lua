local Power_time = {}
--[[
	时间：2024年5月28日9:19
	作者：BSCC_GN
	功能：获取开机次数|获取上次运行时间标志位
	附加功能1：设置运行时间阀值,超过阀值则标志位true，没有超过阀值则false
    附加功能2：储存多组配置的WiFi名称与密码
    ---------------------------------------------
    功能变更：该API变更为fskv数据库储存的功能。2024/6/2
    跟新了继电器控制的fskv数据库，控制继电器的数据Relay_data 与 控制继电器的按键Relay_Key
    用两个数组来储存，一个储存会有控制继电器的数据Relay_data消失的情况
    ---------------------------------------------
    继电器控制数据的默认数据与读取已完成，接收到数据与储存还未进行2024/6/6 22：50
]]
    --读取控制继电器的输出状态
    local Relay_data = {}
    --读取控制继电器的输出时间
    local Relay_time = {}
    --读取控制继电器的按键
    local Relay_Key = {}

--读取数据库中的继电器控制数据
local function Relay_fskv_read()
    Relay_data = fskv.get("Relay_dataa")
    Relay_time = fskv.get("Relay_timee")
    Relay_Key = fskv.get("Relay_Keys")
end

--分析继电器控制数据函数
local function Relay_fskv_analysis()
    --打印出控制继电器的数据
    --print("---------打印控制继电器的数据------------")
    --print("组数，每组的数据-------","合计有【组数】*7 个数据")
    --共有50组数据
    local Relay_OUT_data = {}
    for i=1,50 do
        Relay_OUT_data[i] = {Relay_data[((i-1)*8)+1],Relay_data[((i-1)*8)+2],Relay_data[((i-1)*8)+3],Relay_data[((i-1)*8)+4],Relay_data[((i-1)*8)+5],Relay_data[((i-1)*8)+6],Relay_data[((i-1)*8)+7],Relay_data[((i-1)*8)+8]}
        --print(i,Relay_OUT_data[i][1],Relay_OUT_data[i][2],Relay_OUT_data[i][3],Relay_OUT_data[i][4],Relay_OUT_data[i][5],Relay_OUT_data[i][6],Relay_OUT_data[i][7])
    end
    sys.publish("Relay_OUT_dataa",Relay_OUT_data)--发布这个消息，继电器的开关状态
    for i=1,50 do
        if Relay_time[i] <= 1 then
            Relay_time[i] = 1
        end
    end
    sys.publish("Relay_OUT_time",Relay_time)--发布这个消息，继电器的控制时间
--[[
    print("Process1",table.concat(Relay_Key.Process1, "|"))
    print("Process2",table.concat(Relay_Key.Process2, "|"))
    print("Process3",table.concat(Relay_Key.Process3, "|"))
    print("Process4",table.concat(Relay_Key.Process4, "|"))
    print("PC",table.concat(Relay_Key.PC, "|")) ]]
    sys.publish("Relay_OUT_Key",Relay_Key)--发布这个消息，继电器的按键匹配
end

--运行时间阀值/单位秒
local time_F = 3
--开机标志位为false的次数
local ON_false =3
--获取开机次数
sys.taskInit(function()
    sys.wait(500) -- 免得日志刷没了, 生产环境不需要

    -- 检查一下当前固件是否支持fskv
    if not fskv then
        while true do
            log.info("fskv", "this demo need fskv")
            sys.wait(1000)
        end
    end

    -- 初始化kv数据库
    fskv.init()
    --log.info("初始化kv数据库")
--[[ --清空整个kv数据库
fskv.clr()
used, total,kv_count = fskv.status()
log.info("已使用的空间",used,"总可用空间",total,"总kv键值对数量",kv_count) ]]


    -- 先放入一堆值
	--读取开机次数
    local bootime = fskv.get("boottime")
    --读取开机标志位
    local time_ticks = fskv.get("time_tick")
    --读取开机标志位连续为false的次数
    local ON_false_d = fskv.get("ON_tick")
    --读取wifi连接的信息
    local wifi_initfo = fskv.get("wifi_info")
    --读取继电器控制数据
    Relay_fskv_read()

    if bootime == nil or type(bootime) ~= "number" then
        print("kv数据库-----初次写入开机次数")
        bootime = 0
    else
        bootime = bootime + 1
        --print("-------------开启开机指示灯-----长亮-----")
        sys.publish("PWM_12",1)--发布这个消息，让指示灯长亮
    end
    if time_ticks == nil or type(time_ticks) ~= "boolean" then
        print("kv数据库-----初次写入开机标志位")
        fskv.set("time_tick", false)
    end
    if ON_false_d == nil or type(ON_false_d) ~= "number" then
        print("kv数据库-----初次写入开机标志位连续为false的次数")
        ON_false_d = 1
    end
    if wifi_initfo == nil or type(wifi_initfo) ~= "table" then
        print("kv数据库-----初次写入wifi连接的信息")
        wifi_initfo = {
            ssid1 = "BSCC",password1 = "Bscc123456789.",yxj1 = "3",
            ssid2 = "Gn",password2 = "123456789.",yxj2 = "3",
            ssid3 = "FFFE",password3 = "FFFE.",yxj3 = "0",
            ssid4 = "FFFE",password4 = "FFFE.",yxj4 = "0",
            ssid5 = "FFFE",password5 = "FFFE.",yxj5 = "0",
            ssid6 = "FFFE",password6 = "FFFE.",yxj6 = "0",
        }
        --写入默认的wifi连接的信息
        fskv.set("wifi_info", wifi_initfo)
    end
    if Relay_data == nil or type(Relay_data) ~= "table" then
        print("kv数据库-----初次写入控制继电器的输出状态")
        Relay_data = {}
        for i=1,50 do
            for x=1,8 do
                Relay_data[((i-1)*8)+x] = false
            end
        end
        fskv.set("Relay_dataa", Relay_data)
    end
    if Relay_time == nil or type(Relay_time) ~= "table" then
        print("kv数据库-----初次写入控制继电器的输出时间")
        Relay_time = {}
        for i=1,50 do
            Relay_time[i] = 1
            --print("继电器的输出时间:"..Relay_time[i],i)
        end
        fskv.set("Relay_timee", Relay_time)
    end
    if Relay_Key == nil or type(Relay_Key) ~= "table" then
        print("kv数据库-----初次写入控制继电器的按键")
        Relay_Key = {}
        --备注需要补齐-------------------------------------------------------------
        Relay_Key.Process1 = {1,2}
        Relay_Key.Process2 = {3,4}
        Relay_Key.Process3 = {5,6}
        Relay_Key.Process4 = {7,8}
        Relay_Key.PC = {1,1}
        --备注需要补齐-------------------------------------------------------------
        --[[ print("Process1",table.concat(Relay_Key.Process1, "|"))
        print("Process2",table.concat(Relay_Key.Process2, "|"))
        print("Process3",table.concat(Relay_Key.Process3, "|"))
        print("Process4",table.concat(Relay_Key.Process4, "|"))
        print("PC",table.concat(Relay_Key.PC, "|")) ]]
        fskv.set("Relay_Keys", Relay_Key)
    end

    --写入开机次数
    fskv.set("boottime", bootime)
    --写入开机标志位
    fskv.set("time_tick", false)
    print("fskv", "开机次数", bootime , "数据类型",type(bootime))
    --print("开机标志位",time_ticks, "数据类型",type(time_ticks))
    --分析继电器控制数据函数
    Relay_fskv_analysis()
    if time_ticks == false then--记录开机标志位为false的次数
        ON_false_d = ON_false_d + 1
        --写入开机标志位连续为false的次数
        fskv.set("ON_tick", ON_false_d)
        print("开机标志位连续为false的",ON_false_d,"次")
        if ON_false_d >= ON_false  then
            --print("-------------开启WiFI的AP模式------指示灯-----慢闪----")
            sys.publish("PWM_12",3)--发布这个消息，让指示灯慢闪
            sys.publish("AP_MODE")--发布这个消息，让进入AP模式
        end
    else
        ON_false_d = 1
        fskv.set("ON_tick", ON_false_d)
        --打印出wifi连接信息
        print("ssid1",wifi_initfo.ssid1,"password1",wifi_initfo.password1,"yxj1",wifi_initfo.yxj1)
        print("ssid2",wifi_initfo.ssid2,"password2",wifi_initfo.password2,"yxj2",wifi_initfo.yxj2)
        print("ssid3",wifi_initfo.ssid3,"password3",wifi_initfo.password3,"yxj3",wifi_initfo.yxj3)
        print("ssid4",wifi_initfo.ssid4,"password4",wifi_initfo.password4,"yxj4",wifi_initfo.yxj4)
        print("ssid5",wifi_initfo.ssid5,"password5",wifi_initfo.password5,"yxj5",wifi_initfo.yxj5)
        print("ssid6",wifi_initfo.ssid6,"password6",wifi_initfo.password6,"yxj6",wifi_initfo.yxj6)

        -- 无效的wifi连接信息个数
        local wifi_initfo_Eff = 0
        -- 有效的wifi连接信息
        local wifi_initfo_Eon = {}
        local wifi_initfo_Eonn = {}
        if wifi_initfo.ssid1 ==  "FFFE" or wifi_initfo.password1 == "FFFE" or wifi_initfo.yxj1 == "0" then
            print("-------------ssid1数据无效------------------")
            wifi_initfo_Eff = wifi_initfo_Eff +3
        else
            wifi_initfo_Eon[1] = wifi_initfo.yxj1
            wifi_initfo_Eon[2] = wifi_initfo.ssid1
            wifi_initfo_Eon[3] = wifi_initfo.password1
        end
        if wifi_initfo.ssid2 ==  "FFFE" or wifi_initfo.password2 == "FFFE" or wifi_initfo.yxj2 == "0" then
            print("-------------ssid2数据无效------------------")
            wifi_initfo_Eff = wifi_initfo_Eff + 3
        else
            wifi_initfo_Eon[4-wifi_initfo_Eff] = wifi_initfo.yxj2
            wifi_initfo_Eon[5-wifi_initfo_Eff] = wifi_initfo.ssid2
            wifi_initfo_Eon[6-wifi_initfo_Eff] = wifi_initfo.password2
        end
        if wifi_initfo.ssid3 ==  "FFFE" or wifi_initfo.password3 == "FFFE" or wifi_initfo.yxj3 == "0" then
            print("-------------ssid3数据无效------------------")
            wifi_initfo_Eff = wifi_initfo_Eff + 3
        else
            wifi_initfo_Eon[7-wifi_initfo_Eff] = wifi_initfo.yxj3
            wifi_initfo_Eon[8-wifi_initfo_Eff] = wifi_initfo.ssid3
            wifi_initfo_Eon[9-wifi_initfo_Eff] = wifi_initfo.password3
        end
        if wifi_initfo.ssid4 ==  "FFFE" or wifi_initfo.password4 == "FFFE" or wifi_initfo.yxj4 == "0" then
            wifi_initfo_Eff = wifi_initfo_Eff + 3
            print("-------------ssid4数据无效------------------")
        else
            wifi_initfo_Eon[10-wifi_initfo_Eff] = wifi_initfo.yxj4
            wifi_initfo_Eon[11-wifi_initfo_Eff] = wifi_initfo.ssid4
            wifi_initfo_Eon[12-wifi_initfo_Eff] = wifi_initfo.password4
        end
        if wifi_initfo.ssid5 ==  "FFFE" or wifi_initfo.password5 == "FFFE" or wifi_initfo.yxj5 == "0" then
            wifi_initfo_Eff = wifi_initfo_Eff + 3
            print("-------------ssid5数据无效------------------")
        else
            wifi_initfo_Eon[13-wifi_initfo_Eff] = wifi_initfo.yxj5
            wifi_initfo_Eon[14-wifi_initfo_Eff] = wifi_initfo.ssid5
            wifi_initfo_Eon[15-wifi_initfo_Eff] = wifi_initfo.password5
        end
        if wifi_initfo.ssid6 ==  "FFFE" or wifi_initfo.password6 == "FFFE" or wifi_initfo.yxj6 == "0" then
            wifi_initfo_Eff = wifi_initfo_Eff + 3
            print("-------------ssid6数据无效------------------")
        else
            wifi_initfo_Eon[16-wifi_initfo_Eff] = wifi_initfo.yxj6
            wifi_initfo_Eon[17-wifi_initfo_Eff] = wifi_initfo.ssid6
            wifi_initfo_Eon[18-wifi_initfo_Eff] = wifi_initfo.password6
        end
        if wifi_initfo_Eff < 18 then
            print("-----------正常开机------开始扫描wifi--------------------")
            sys.publish("WiFI_Scanning",true)--发布这个消息，开始扫描wifi
            --print("有效数量-----",#wifi_initfo_Eon)
            --for i=1,#wifi_initfo_Eon,1 do
            --    print(i,wifi_initfo_Eon[i])
            --end
            local x = 1
            for i=1,#wifi_initfo_Eon,3 do
                --print("------",i,wifi_initfo_Eon[i])
                if wifi_initfo_Eon[i] =="3" then
                    --print("x="..x)
                    wifi_initfo_Eonn[x]=wifi_initfo_Eon[i+1]
                    wifi_initfo_Eonn[x+1]=wifi_initfo_Eon[i+2]
                    x = x+2
                end
            end
            for i=1,#wifi_initfo_Eon,3 do
                if wifi_initfo_Eon[i] =="2" then
                    wifi_initfo_Eonn[x]=wifi_initfo_Eon[i+1]
                    wifi_initfo_Eonn[x+1]=wifi_initfo_Eon[i+2]
                    x = x+2
                end
            end
            for i=1,#wifi_initfo_Eon,3 do
                if wifi_initfo_Eon[i] =="1" then
                    wifi_initfo_Eonn[x]=wifi_initfo_Eon[i+1]
                    wifi_initfo_Eonn[x+1]=wifi_initfo_Eon[i+2]
                    x = x+2
                end
            end
            for i=1,#wifi_initfo_Eonn,1 do
                print(i,wifi_initfo_Eonn[i])
            end
            sys.publish("wifi_initfo_Eonnn",wifi_initfo_Eonn)--发布这个消息，将wifi存储的信息发布出去
        else
            sys.publish("WiFI_Scanning",false)--发布这个消息，关闭扫描wifi
        end


    end





    -- 查询kv数据库状态
    local used, total,kv_count = fskv.status()
	print("已使用的空间",used,"总可用空间",total,"总kv键值对数量",kv_count)
    sys.wait(1000*time_F)
    fskv.set("time_tick", true)
    print("开机时间",time_F,"秒  开机标志位true")

--[[ 	--清空整个kv数据库
    fskv.clr()
    used, total,kv_count = fskv.status()
	log.info("已使用的空间",used,"总可用空间",total,"总kv键值对数量",kv_count)
 ]]
end)


--[[ --一秒后执行某函数，可以在后面传递参数
sys.timerStart(function()					--sys.timerStart开启一个一次性定时器
    fskv.set("time_tick", true)
    print("开机时间",time_F,"秒  开机标志位true")
end,1000*time_F) ]]


--单独订阅，可以当回调来用
sys.subscribe("WiFi_Config",function(data)
    print("WiFi_Config",data)
    wifi_initfo = {
        ssid1 = data[1],
        password1 = data[2],
        yxj1 = data[3],
        ssid2 = data[4],
        password2 = data[5],
        yxj2 = data[6],
        ssid3 = data[7],
        password3 = data[8],
        yxj3 = data[9],
        ssid4 = data[10],
        password4 = data[11],
        yxj4 = data[12],
        ssid5 = data[13],
        password5 = data[14],
        yxj5 = data[15],
        ssid6 = data[16],
        password6 = data[17],
        yxj6 = data[18],
    }
    --写入wifi连接的信息
    fskv.set("wifi_info", wifi_initfo)
    --[[
    --读取wifi连接的信息
    wifi_initfo = fskv.get("wifi_info")
    print("ssid1",wifi_initfo.ssid1,"password1",wifi_initfo.password1,"yxj1",wifi_initfo.yxj1)
    print("ssid2",wifi_initfo.ssid2,"password2",wifi_initfo.password2,"yxj2",wifi_initfo.yxj2)
    print("ssid3",wifi_initfo.ssid3,"password3",wifi_initfo.password3,"yxj3",wifi_initfo.yxj3)
    print("ssid4",wifi_initfo.ssid4,"password4",wifi_initfo.password4,"yxj4",wifi_initfo.yxj4)
    print("ssid5",wifi_initfo.ssid5,"password5",wifi_initfo.password5,"yxj5",wifi_initfo.yxj5)
    print("ssid6",wifi_initfo.ssid6,"password6",wifi_initfo.password6,"yxj6",wifi_initfo.yxj6) ]]
end)

--单独订阅，可以当回调来用
--接收WiFi发来的继电器的开关状态
sys.subscribe("Relay_OUT_dataa_Wifi",function(data1,data2,data3)
    --写入继电器控制数据到数据库
    fskv.set("Relay_dataa", data1)
    fskv.set("Relay_timee", data2)
    fskv.set("Relay_Keys", data3)
    print("继电器的开关状态已更新到数据库")
    --读取数据库中的继电器控制数据
    Relay_fskv_read()
    --分析继电器控制数据函数
    Relay_fskv_analysis()

end)









return Power_time
