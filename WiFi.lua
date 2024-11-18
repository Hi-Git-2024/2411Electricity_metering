local WiFi = {}
--[[
	时间：2024年5月28日10:20
	作者：BSCC_GN
	功能：与网页的交互，获取设备信息，并将信息写入kv数据库
	说明：AP模式不支持读取文件，只可以用demo里面的方法来通讯
]]
-- 用于接收继电器控制的时间
local Relay_time = {}
--用于转换时间数据格式
local Relay_timed = ""
--用于接收继电器的输出状态
local Relay_OUT_MSG ={}
--用于转换状态数据格式
local Relay_OUT_MSGd = ""
--用于接收继电器的按键匹配
local Relay_OUT_Keyk ={}
--用于转换按键数据格式
local Relay_OUT_Keykd = ""

--接收到继电器的状态数据
--将数据转换为字符串，以便传入客户端
sys.subscribe("Relay_OUT_dataa",function(data)--订阅消息，当收到消息时，执行回调函数
	--print("接收到继电器的状态数据")
	Relay_OUT_MSG = data
	for i=1,50 do
		--print("Relay_OUT_MSG",i,Relay_OUT_MSG[i][1],Relay_OUT_MSG[i][2],Relay_OUT_MSG[i][3],Relay_OUT_MSG[i][4],Relay_OUT_MSG[i][5],Relay_OUT_MSG[i][6],Relay_OUT_MSG[i][7],Relay_OUT_MSG[i][8])
        for j=1,8 do
            --print("转换的状态数据",i,j,Relay_OUT_MSG[i][j])
            if Relay_OUT_MSG[i][j] then
                Relay_OUT_MSGd = Relay_OUT_MSGd.."1"..","
            else
                Relay_OUT_MSGd = Relay_OUT_MSGd.."0"..","
            end
        end
	end
    --print("Relay_OUT_MSGd",Relay_OUT_MSGd)
end)
--接收到继电器的控制时间
sys.subscribe("Relay_OUT_time",function(data)--订阅消息，当收到消息时，执行回调函数
	--print("接收到继电器的控制时间")
	Relay_time = data
	for i=1,50 do
		--print("Relay_time",i,Relay_time[i])
        Relay_timed = Relay_timed..Relay_time[i]..","
	end
    --print("Relay_timed",Relay_timed)
end)
--接收到继电器的按键匹配
sys.subscribe("Relay_OUT_Key",function(data)--订阅消息，当收到消息时，执行回调函数
	--print("接收到继电器的按键匹配")
	Relay_OUT_Keyk = data
	--print("Process1",table.concat(Relay_OUT_Keyk.Process1, "|"))
	--print("Process2",table.concat(Relay_OUT_Keyk.Process2, "|"))
	--print("Process3",table.concat(Relay_OUT_Keyk.Process3, "|"))
	--print("Process4",table.concat(Relay_OUT_Keyk.Process4, "|"))
	--print("PC",table.concat(Relay_OUT_Keyk.PC, "|"))
    Relay_OUT_Keykd = table.concat(Relay_OUT_Keyk.Process1, ",")..","..table.concat(Relay_OUT_Keyk.Process2, ",")..","..table.concat(Relay_OUT_Keyk.Process3, ",")..","..table.concat(Relay_OUT_Keyk.Process4, ",")..","..table.concat(Relay_OUT_Keyk.PC, ",")
    --print("Relay_OUT_Keykd",Relay_OUT_Keykd)
end)



--AP模式下，开启一个HTTP服务器，接收来自网页的请求，并将信息写入kv数据库
-- 接收到/AP/字符串，则将字符串分割，取出ssid和password，写入kv数据库
-- 接收到/AP字符串，则指示灯快闪，代表AP模式已经开启，已经连接客户端
-- 接收到其他字符串，则返回404错误
--AP模式标志位false-不是AP模式  true-AP模式
local AP_AP = false
local WIFI_OFFF = false
--单独订阅，可以当回调来用--获取当前指示灯的状态
sys.subscribe("PWM_12",function(data)
    --log.info("PWM_false=",data,"数据类型",type(data))
    if data == 2 then
        WIFI_OFFF = true
    else
        WIFI_OFFF = false
    end
end)
sys.subscribe("WIFI_OFF",function()
    wlan.disconnect()--作为STATION时,断开AP
    if WIFI_OFFF == true then
        sys.publish("PWM_12",1)--发布这个消息，让指示灯长亮
    end
end)
local wifi_initfo_Eonnnn = {}--接收wifi的kv数据库存储的信息
--单独订阅，可以当回调来用
sys.subscribe("wifi_initfo_Eonnn",function(data)
    wifi_initfo_Eonnnn = data
end)
local WiFI_Scanning_switch = false -- 标志位，用于控制WiFi扫描任务

--单独订阅，可以当回调来用
sys.subscribe("WiFI_Scanning",function(data)
    --log.info("WiFI_Scanning=",data,"数据类型",type(data))
    WiFI_Scanning_switch = data
end)


-- 定时扫描WiFi，超时时间为3分钟，每隔16秒扫描一次
sys.taskInit(function()
    sys.wait(3000)
    if AP_AP == false then
        wlan.init()
        print("WiFI初始化--------成功------------")
    end
    local WiFI_time = 0
    while 1 do
        if WiFI_Scanning_switch == true then
            wlan.scan()--扫描wifi频段
            WiFI_time = WiFI_time + 1
            print("WiFi扫描任务中...", WiFI_time)
            if WiFI_time > 10 then
                WiFI_Scanning_switch = false
                WiFI_time = 0
            end
            sys.wait(15000)
        end
        sys.wait(1000)
    end
end)
-- 注意, wlan.scan()是异步API,启动扫描后会马上返回
-- wifi扫描成功后, 会有WLAN_SCAN_DONE消息, 读取即可
local WiFi_receive_data = {} -- 接收到的WiFi信息
sys.subscribe("WLAN_SCAN_DONE", function ()
    print("收到WiFi扫描消息")
    local results = wlan.scanResult()
    log.info("scan", "results", #results)
    for k,v in pairs(results) do
        log.info("scan", k,v["ssid"], v["rssi"], (v["bssid"]:toHex()))
        WiFi_receive_data[k]=v["ssid"]
        --print("WiFi扫描结果WiFi_receive_data=",WiFi_receive_data[k])
    end
    --扫描周围的WiFi，并将信息与kv数据库比对，如果有匹配的，则匹配连接
    for x=1,#wifi_initfo_Eonnnn,2 do
        for i=1,#WiFi_receive_data,1 do
            if WiFi_receive_data[i] == wifi_initfo_Eonnnn[x] then
                WiFI_Scanning_switch = false --停止扫描
                local WiFi_receive_dataabb = {}
                WiFi_receive_dataabb[1] = wifi_initfo_Eonnnn[x]
                WiFi_receive_dataabb[2] = wifi_initfo_Eonnnn[x+1]
                --sys.wait(500)
                sys.publish("WiFi_receive_dataab",WiFi_receive_dataabb)--发布这个消息
                --WiFi_receive_data = {}
                break                        --break跳出本次循环
            end
        end
    end
end)



--AP模式
sys.taskInit(function()
    while true do
        sys.waitUntil("AP_MODE")--等待这个消息，这个任务阻塞在这里了
        AP_AP = true
        local ssid = "BSCC-血器测试治具"
        local password = "Bscc123456789."
        print("开启AP模式--------")
        wlan.init()
        --设置为AP模式, 广播ssid, 接收wifi客户端的链接
        wlan.setMode(wlan.AP)
        sys.wait(300)
        --设置AP的名称与密码
        wlan.createAP(ssid, password)
        --log.info("web", "pls open url http://192.168.4.1/")
        sys.wait(1000)
        httpsrv.start(80, function(fd, method, uri, headers, body)
            log.info("httpsrv", method, uri, json.encode(headers), body)
            -- meminfo()
            print("服务器接收测试","fd=",fd)
            print("服务器接收测试","method=",method)
            print("服务器接收测试","uri="..uri)
            print("服务器接收测试","json.encode(headers)=",json.encode(headers))
            print("服务器接收测试","headers=",headers)
            print("服务器接收测试","body=",body)
            local x,y = string.find(uri, "/AP/")
            print("服务器接收测试","x=",x)
            print("服务器接收测试","y=",y)
            if y then
                local str = string.sub(uri, y+1, #uri)
                print("服务器接收测试","str=",str)
                -- 按字符串分割
                local tmp = str:split(":")
                if string.sub(uri, x, y) == "/AP/" and #tmp == 18 then
                    sys.publish("PWM_12",1)--发布这个消息，让指示灯长亮
                    sys.publish("WiFi_Config", tmp)--将接收到的WiFI配置写入kv数据库
                    --for i=1,#tmp,1 do
                        --log.info("接收到的WiFI配置",i, tmp[i])
                    --end
                    return 200, {}, "ok"
                end
            end
            if uri == "/AP" then
                --print("连接上了客户端")
                sys.publish("PWM_12",4)--发布这个消息，让指示灯快闪
                return 200, {}, "ok"
            end
            if uri == "/restart/" then
                print("设备重启")
                rtos.reboot()--设备重启
                return 200, {}, "ok"
            end
            return 404, {}, "Not Found" .. uri
        end)
    end
end)



-- 连接到指定的WiFi
sys.taskInit(function()
    while true do
        local _,data = sys.waitUntil("WiFi_receive_dataab")--等待这个消息，这个任务阻塞在这里了
        print("----------WiFi匹配成功----------",data[1], data[2])
        wlan.connect(data[1], data[2])--作为STATION时,连接到指定AP
        while not wlan.ready() do--作为STATION时,是否已经连接上AP,且获取IP成功
            local ret, ip = sys.waitUntil("IP_READY", 30000)
            -- wlan连上之后, 这里会打印ip地址
            log.info("---------ip-----", ret, ip)
            if ip then
                _G.wlan_ip = ip
                sys.publish("BT_broadcast",data[1],ip)--发布这个消息，让串口广播已连接的WiFi名称与IP地址
                sys.publish("PWM_12",2)--发布这个消息，呼吸灯
                sys.publish("WiFI_broadcast",true)--发布这个消息，让设备开始打印
            end
            log.info("wlan", "ready  mac!!", wlan.getMac())--获取mac
            log.info("wlan", "AP info:", json.encode(wlan.getInfo()))--获取已连接的AP的信息
            sys.wait(1000)
            --STATION模式下，开启一个HTTP服务器，接收来自网页的请求,并将信息写入kv数据库
            httpsrv.start(80, function(fd, method, uri, headers, body)
                --log.info("httpsrv", method, uri, json.encode(headers), body)
                print("服务器接收测试","uri="..uri)
                local data1= string.sub(body, 1, 8)
                local data2= string.sub(body, 9, #body)
                --print("服务器接收测试","data1=",data1)
                --print("服务器接收测试","data2=",data2)
                --将继电器的控制数据发送给WBE端
                if uri == "/write.php" then
                    if data1 == "content=" then
                        if data2 == "FEFF00FFFE" then
                            print("发送继电器的控制数据到WBE端")
                            local data3 = Relay_OUT_MSGd..Relay_timed..Relay_OUT_Keykd
                            return 200, {}, data3
                        else
                            print("发送继电器的控制数据到WBE端失败")
                        end
                    end
                end
                --接收到WBE端的继电器控制数据
                if uri == "/wificonfig.php" then
                    if data1 == "content=" then
                        Relay_OUT_MSGd = ""
                        Relay_timed = ""
                        Relay_OUT_Keykd = ""
                        --print("接收到WBE端的继电器控制数据",data2)
                        -- 按字符串分割
                        local tmp = data2:split("F")
                        --字符串转化为数组
                        for i=1,400 do
                            if tmp[i] == "1" then
                                tmp[i] = true
                            else
                                tmp[i] = false
                            end
                        end
                        --字符转化为数
                        for i=1,50 do
                            tmp[400+i] = tonumber(tmp[400+i])
                        end
                        --字符转化为数
                        for i=1,10 do
                            tmp[450+i] = tonumber(tmp[450+i])
                        end

                        -- 取出数组
                        --继电器的状态数据
                        local Relay_OUT_MSGdd = {}
                        for i=1,400 do
                            Relay_OUT_MSGdd[i] = tmp[i]
                        end
                        --继电器的控制时间
                        local Relay_timedd = {}
                        for i=1,50 do
                            Relay_timedd[i] = tmp[400+i]
                        end
                        --继电器的按键匹配
                        local Relay_OUT_Keykdd = {}
                        Relay_OUT_Keykdd.Process1 = {tmp[451],tmp[452]}
                        Relay_OUT_Keykdd.Process2 = {tmp[453],tmp[454]}
                        Relay_OUT_Keykdd.Process3 = {tmp[455],tmp[456]}
                        Relay_OUT_Keykdd.Process4 = {tmp[457],tmp[458]}
                        Relay_OUT_Keykdd.PC = {tmp[459],tmp[460]}
                        -- 打印数组
                        --[[ for i, v in ipairs(Relay_OUT_MSGdd) do
                            print(i, v)
                        end
                        for i, v in ipairs(Relay_timedd) do
                            print(i, v)
                        end
                        for i, v in ipairs(Relay_OUT_Keykdd) do
                            print(i, v)
                        end ]]
                        -- 发布消息
                        sys.publish("Relay_OUT_dataa_Wifi",Relay_OUT_MSGdd,Relay_timedd,Relay_OUT_Keykdd)--发布这个消息，储存继电器的状态数据
                        return 200, {}, "ok"
                    end
                end
                if uri == "/Key/1" then
                    print("清洗管道按键按下")
                    local Relay_Keykkkk ={true,false,false,false,false}
                    sys.publish("Relay_IN_Key",Relay_Keykkkk)--发布这个消息，清洗管道
                    return 200, {}, "ok"
                end
                if uri == "/Key/2" then
                    print("测试按键按下")
                    local Relay_Keykkkk ={false,true,false,false,false}
                    sys.publish("Relay_IN_Key",Relay_Keykkkk)--发布这个消息，测试
                    return 200, {}, "ok"
                end
                if uri == "/Key/3" then
                    print("清洗管道按键按下")
                    local Relay_Keykkkk ={false,false,true,false,false}
                    sys.publish("Relay_IN_Key",Relay_Keykkkk)--发布这个消息，清洗管道
                    return 200, {}, "ok"
                end
                if uri == "/Key/4" then
                    print("加液按键按下")
                    local Relay_Keykkkk ={false,false,false,true,false}
                    sys.publish("Relay_IN_Key",Relay_Keykkkk)--发布这个消息，加液
                    return 200, {}, "ok"
                end
                if uri == "/Key/5" then
                    print("PC控制按下")
                    local Relay_Keykkkk ={false,false,false,false,true}
                    sys.publish("Relay_IN_Key",Relay_Keykkkk)--发布这个消息，控制PC
                    return 200, {}, "ok"
                end
                if uri == "/AP" then
                    print("连接上了客户端")
                    sys.publish("PWM_12",4)--发布这个消息，让指示灯快闪
                    sys.publish("WiFI_broadcast",false)--发布这个消息，让设备停止打印
                    return 200, {}, "ok"
                end
                return 404, {}, "Not Found" .. uri
            end)
            log.info("web", "pls open url http://" .. _G.wlan_ip .. "/")
        end
    end
end)


--[[ -- 使用 split 函数将字符串转化为数组
local array = split(str, ",")

-- 打印数组
for i, v in ipairs(array) do
    print(i, v)
end
 ]]

return WiFi
