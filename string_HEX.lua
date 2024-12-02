--字符转HEX
local string_HEX = {}
--module(...,package.seeall)
--[[
各种字符串转HEX的函数 ]]




--判断数字0123456789
--判断字符abcdef，其他字符无法判断
function st_judge( judge )
    if judge<58 then
        judge=judge-48
    end
    if judge>58 then
        judge=judge-55
    end
    return judge
end



--字符转换成HEX函数，输入字符，返回HEX
--输入的字符必须是“0123456789abcdef”
function st_HEX( Hexadecimal )
    local a =string.upper(Hexadecimal)--输入的字符转成大写
    local b = string.len(a)--计算字符串长度
    local d={}             --储存拆分后的字符
    local HEX              --输出的数据
    if b==1 then
        local g = string.byte(a,1) --返回字符所对应的 ASCII 码
        g = st_judge(g)
        d[1] = string.char(g+1-1)
    else
        if b%2 == 0 then --字符长度为偶数
            --print("偶数",b)
            for i=1,b,2 do
                local x,y = string.byte(a,i),string.byte(a,i+1)  --返回字符所对应的 ASCII 码
                local c = st_judge(x)*16+st_judge(y)
                d[(i+1)/2] = string.char(c)
            end
        else  --字符长度为奇数
            --print("奇数",b)
            local g = string.byte(a,1)
            g = st_judge(g)
            d[1] = string.char(g+1-1)
            for i=2,b,2 do
                local x,y = string.byte(a,i),string.byte(a,i+1)  --返回字符所对应的 ASCII 码
                local c = st_judge(x)*16+st_judge(y)
                d[(i+2)/2] = string.char(c)
            end
        end
    end
    HEX =table.concat(d)
    --计算字符串长度
    local x,y = string.toHex(HEX)
--[[     print("输入的字符=",Hexadecimal)
    print("字符的长度=",b)
    print("转换后的HEX=",x)
    print("数据HEX的长度=",y) ]]
    --print("上传数据的长度=",string.len(x),y)     --计算字符串长度
    --socketOutMsg.TCP_OUT(HEX) --数据上传服务器
    return HEX,y --返回转换后的数据与数据数量，数据类型——HEX
end


--16进制数转换成字符
--输入与输出都是字符
function st_st( data )
    local data16 =string.upper(data)--输入的字符转成大写
    local length = string.len(data16)--计算字符串长度
    local data              --输出的数据
    if length%2 == 0 then  --字符长度为偶数
        data = data16
    else
        data = "0"..data16
    end
    return data
end


--16进制累加和校验
--输入待处理数据；输出累加和校验
--输入与输出，都是字符
function st_and( Hex )
    local a =string.upper(Hex)--输入的字符转成大写
    local b = string.len(a)--计算字符串长度
    local Hex1 = 0
    local d={}             --储存拆分后的字符
    for i=1,b-1,2 do
        local x,y = string.byte(a,i),string.byte(a,i+1)
        local c = st_judge(x)*16+st_judge(y)
        --print(i,"=",x,y,c)
        d[(i+1)/2] = c
    end
    for i=1,(b+1)/2,1 do
        --print(i,"=",string.sub(a, 2*i-1 , 2*i),d[i])
        Hex1 = d[i]+Hex1
    end
    --print("累加和输入的字符=",a)
    --print("累加和十进制=",Hex1)
    local d3 = string.format("%x", Hex1)
    --print("累加和十六进制=",d3)
    local d1 = string.format("%s", d3)
    local d2 = string.sub(d1, -2 , -1)
    d2 = string.upper(d2)--输入的字符转成大写
    --print(d1,string.upper(d2) )
    return d2 --返回累加和校验,数据类型——字符
end


--16进制
local st_in ={"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"}

--16进制转成10进制
--输入字符，输出数字
function st16_st10( st16 )
    local st10I,st10II,st10 = 0,0,0
    st16 =string.upper(st16)--输入的字符转成大写
    for i=1,16 do
        if string.sub(st16,1,1) == st_in[i] then
            st10I = i-1
        end
        if string.sub(st16,2,2) == st_in[i] then
            st10II = i-1
        end
        st10 = st10I*16+st10II
    end
    return st10 --返回10进制,数据类型——数字
end

--[[
sys.taskInit(function()
    while true do
        --local e = st_and(x)
        --socketOutMsg.TCP_OUT(e) --数据上传服务器
        --socketOutMsg.TCP_OUT(st_HEX(e)) --数据上传服务器
        print("转换",st16_st10("ac"))
        sys.wait(1000) --延时1秒，这段时间里可以运行其他代码
    end
end)
]]

--十六进制数转换为二进制数
--输入十六进制字符串，输出二进制字符串
function hexToBinary(hex)
    -- 将十六进制字符串转换为十进制数
    local decimal = tonumber(hex, 16)

    -- 如果转换失败，返回一个错误信息
    if not decimal then
        return "无效的十六进制数"
    end

    -- 将十进制数转换为二进制字符串
    local binary = ""
    repeat
        local remainder = decimal % 2
        binary = remainder .. binary
        decimal = math.floor(decimal / 2)
    until decimal == 0

    return binary
end

--[[ -- 示例
local hexValue = "1A3F"
local binaryValue = hexToBinary(hexValue)
print("十六进制数 " .. hexValue .. " 转换为二进制是: " .. binaryValue) ]]

--处理状态寄存器(State REG)的数据
--输入十六进制数据字符串，输出二进制数据位的判断值
function Function_State_REG(data)
    --print("data",data)
    local string_binary = hexToBinary(data)--将十六进制数据转换为二进制数据
    --print("string_binary",string_binary)
    if #string_binary < 8 then --如果数据位数不足8位，则补齐
        for i=1,8-#string_binary,1 do
            string_binary = "0"..string_binary
        end
    end
    local binary = {}--分割二进制数据
    --v电压寄存器状态位
    --i电流寄存器状态位
    --p功率寄存器状态位
    --state状态寄存器状态位
    --true表示正常标志位是0，false表示异常标志位是1
    local v_state,i_state,p_state,state = true,true,true,true
    if data == "AA" then
        print("芯片误差修正功能失效，此时参数寄存器不可用")
    elseif data == "55" then
        print("芯片误差修正功能正常，此时参数寄存器可用,且寄存器未溢出")
    elseif data:sub(1,1) == "F" then
        --print("芯片误差修正功能正常，此时参数寄存器可用,相应位为1时表示相应的寄存器溢出,溢出接近0")
        for i=1,4,1 do
            binary[i] = string.sub(string_binary,i+4,i+4)
            if i == 1 then
                if binary[i] == "0" then
                    v_state = true
                else
                    v_state = false
                end
            elseif i == 2 then
                if binary[i] == "0" then
                    i_state = true
                else
                    i_state = false
                end
            elseif i == 3 then
                if binary[i] == "0" then
                    p_state = true
                else
                    p_state = false
                end
            elseif i == 4 then
                if binary[i] == "0" then
                    state = true
                else
                    state = false
                end
            end
        end
        --print("State_REG二进制", table.concat(binary, "|"))--每个元素连接起来，并用"|"分割
--[[         print("电压寄存器状态位", v_state)
        print("电流寄存器状态位", i_state)
        print("功率寄存器状态位", p_state)
        print("状态寄存器状态位", state) ]]
    else
        print("未知异常")
    end
    binary = {v_state,i_state,p_state,state}
    return binary--返回四个状态位的值
end

--将高八位、中八位和低八位的十六进制数转换为十进制数
--输入3位十六进制字符串，输出十进制数
function hexToDecimal(data)
    local data_hex,data_len = st_HEX(data)-- 将十六进制字符串转换为hex数据
    local data_H,data_L = string.unpack(">BH", data_hex)-- 高八位转为数字，中八位和低八位转为数字
    --print("data_H",data_H,"data_L",data_L)
    local data_number = data_H*65536+data_L
    --print("十六进制数", data, "转换为十进制数", data_number)
    -- 如果转换失败，返回一个错误信息
    if not data then
        return "无效的十六进制数"
    end
    return data_number
end



--处理数据更新寄存器(Data Updata REG)的数据
--输入1bit数据字符串，输出二进制数据位的判断值
function Function_bit_Binary(data)
    --print("data",data)
    local string_binary = hexToBinary(data)--将十六进制数据转换为二进制数据
    --print("string_binary",string_binary)
    if #string_binary < 8 then --如果数据位数不足8位，则补齐
        for i=1,8-#string_binary,1 do
            string_binary = "0"..string_binary
        end
    end
    local binary = {}--分割二进制数据

    --v电压寄存器状态位
    --i电流寄存器状态位
    --p功率寄存器状态位
    --state状态寄存器状态位
    --true表示正常标志位是0，false表示异常标志位是1
    --print("芯片误差修正功能正常，此时参数寄存器可用,相应位为1时表示相应的寄存器溢出,溢出接近0")
    for i=1,8,1 do
        binary[i] = string.sub(string_binary,i,i)
        if i == 1 then
            if binary[i] == "1" then
                v_state = true
            else
                v_state = false
            end
        elseif i == 2 then
            if binary[i] == "1" then
                i_state = true
            else
                i_state = false
            end
        elseif i == 3 then
            if binary[i] == "1" then
                p_state = true
            else
                p_state = false
            end
        elseif i == 4 then
            if binary[i] == "1" then
                state = true
            else
                state = false
            end
        end
    end
    --print("Data Updata REG二进制", table.concat(binary, "|"))--每个元素连接起来，并用"|"分割
--[[         print("电压寄存器状态位", v_state)
        print("电流寄存器状态位", i_state)
        print("功率寄存器状态位", p_state)
        print("状态寄存器状态位", state) ]]
    binary = {v_state,i_state,p_state,state}
    return binary--返回四个状态位的值
end

--将高八位和低八位的十六进制数转换为十进制数
--输入2位十六进制字符串，输出十进制数
function PF_number(data)
    local data_hex,data_len = st_HEX(data)-- 将十六进制字符串转换为hex数据
    local data_number = string.unpack(">H", data_hex)-- 高八位转为数字，中八位和低八位转为数字
    --print("十六进制数", data, "转换为十进制数", data_number)
    -- 如果转换失败，返回一个错误信息
    if not data then
        return "无效的十六进制数"
    end
    return data_number
end


-------------------------------------------------------------------------------------
--------------------------处理器上电后，订阅HLW8032_UART_DATA消息并处理数据----------------------------------
-------------------------------------------------------------------------------------

--单独订阅，回调函数，接收uart发布的数据，并处理
sys.subscribe("HLW8032_UART_DATA",function(data)
    --print("订阅到HLW8032_UART_DATA消息")
    --log.info("订阅", #data, data)
    local Add_REG = string.sub(data, 6, 46)--截取需要计算校验和的数据
    --log.info("Add_REG", Add_REG)
    local Add_data = st_and(st_st(Add_REG))--计算的校验和
    --log.info("Add_data", Add_data)
    local CheckSum_REG= string.sub(data, 47, 48)--接收到的校验和
    local HLW8032_DATA = {}--合并数据
    --log.info("CheckSum_REG", CheckSum_REG)
    if Add_data == CheckSum_REG then --计算校验和与接收到的校验和进行比较
        --log.info("HLW8032_UART_DATA消息校验成功")
        --local data_hex,data_len = st_HEX(data)
        --log.info("HEX数据",data_hex:toHex())

        --截取数据
        local State_REG = data:sub(1,2) -- 状态寄存器
        local Check_REG = data:sub(3,4) -- 检测寄存器,默认值
        local Voltage_parameter_REG = data:sub(5,10) -- 电压参数寄存器,默认值
        local Voltage_REG = data:sub(11,16) -- 电压寄存器
        local Current_parameter_REG = data:sub(17,22) -- 电流参数寄存器,默认值
        local Current_REG = data:sub(23,28) -- 电流寄存器
        local Power_parameter_REG = data:sub(29,34) -- 功率参数寄存器,默认值
        local Power_REG = data:sub(35,40) -- 功率寄存器
        local Data_Updata_REG = data:sub(41,42) -- 数据更新寄存器
        local PF_REG= data:sub(43,46) -- PF寄存器

        --转换为需要的数据类型
        local F_State_REG = Function_State_REG(State_REG)--处理状态寄存器数据
        local F_Voltage_parameter_REG = hexToDecimal(Voltage_parameter_REG)--处理电压参数寄存器数据
        local F_Voltage_REG = hexToDecimal(Voltage_REG)--处理电压寄存器数据
        local F_Current_parameter_REG = hexToDecimal(Current_parameter_REG)--处理电流参数寄存器数据
        local F_Current_REG = hexToDecimal(Current_REG)--处理电流寄存器数据
        local F_Power_parameter_REG = hexToDecimal(Power_parameter_REG)--处理功率参数寄存器数据
        local F_Power_REG = hexToDecimal(Power_REG)--处理功率寄存器数据
        local F_Data_Updata_REG = Function_bit_Binary(Data_Updata_REG)--处理数据更新寄存器数据
        local F_PF_REG = PF_number(PF_REG)--处理PF寄存器数据

        --打印数据
--[[         print("State_REG", State_REG, F_State_REG[1], F_State_REG[2], F_State_REG[3], F_State_REG[4])--处理状态寄存器数据
        print("Voltage_parameter_REG",Voltage_parameter_REG, F_Voltage_parameter_REG)--处理检测寄存器数据
        print("Voltage_REG",Voltage_REG, F_Voltage_REG)--处理电压寄存器数据
        print("Current_parameter_REG",Current_parameter_REG, F_Current_parameter_REG)--处理电流参数寄存器数据
        print("Current_REG",Current_REG, F_Current_REG)--处理电流寄存器数据
        print("Power_parameter_REG",Power_parameter_REG, F_Power_parameter_REG)--处理功率参数寄存器数据
        print("Power_REG",Power_REG, F_Power_REG)--处理功率寄存器数据
        print("Data_Updata_REG", Data_Updata_REG, F_Data_Updata_REG[1], F_Data_Updata_REG[2], F_Data_Updata_REG[3], F_Data_Updata_REG[4])--处理状态寄存器数据
        print("PF_REG",PF_REG, F_PF_REG)--处理PF寄存器数据 ]]

        --合并数据
        HLW8032_DATA.state = F_State_REG
        HLW8032_DATA.voltage_parameter = F_Voltage_parameter_REG
        HLW8032_DATA.voltage = F_Voltage_REG
        HLW8032_DATA.current_parameter = F_Current_parameter_REG
        HLW8032_DATA.current = F_Current_REG
        HLW8032_DATA.power_parameter = F_Power_parameter_REG
        HLW8032_DATA.power = F_Power_REG
        HLW8032_DATA.data_updata = F_Data_Updata_REG
        HLW8032_DATA.pf = F_PF_REG

--[[         log.info("state", HLW8032_DATA.state[1], HLW8032_DATA.state[2], HLW8032_DATA.state[3], HLW8032_DATA.state[4])
        log.info("voltage_parameter", HLW8032_DATA.voltage_parameter)
        log.info("voltage", HLW8032_DATA.voltage)
        log.info("current_parameter", HLW8032_DATA.current_parameter)
        log.info("current", HLW8032_DATA.current)
        log.info("power_parameter", HLW8032_DATA.power_parameter)
        log.info("power", HLW8032_DATA.power)
        log.info("data_updata", HLW8032_DATA.data_updata[1], HLW8032_DATA.data_updata[2], HLW8032_DATA.data_updata[3], HLW8032_DATA.data_updata[4])
        log.info("pf", HLW8032_DATA.pf) ]]

        sys.publish("HLW8032_DATA", HLW8032_DATA)--发布电量计量数据到消息队列
    end
end)











return string_HEX
