local HLW8032 = {}
--[[
	时间：2024年11月28日16:15
	作者：BSCC_GN
	功能：电量计量器HLW8032的驱动程序
	版本：v1.0.0
	修订记录：
	1. 创建文件
]]
-- 初始化硬件——uart通讯——电路网络编号与GPIO编号匹配
local uartid = 1 -- 根据实际设备选取不同的uartid

-- 初始化
uart.setup(uartid, -- 串口id
4800, -- 波特率
8, -- 数据位
1, -- 停止位
uart.Even)

-- 收取数据会触发回调, 这里的"receive" 是固定值
uart.on(uartid, "receive", function(id, len)
    local s = ""
    repeat
        s = uart.read(id, 24)
        if #s >= 24 then -- #s 是取字符串的长度
            -- 如果传输二进制/十六进制数据, 部分字符不可见, 不代表没收到
            -- 关于收发hex值,请查阅 https://doc.openluat.com/article/583
            -- log.info("uart", "receive", id, #s, s:toHex())
            local uart_data = s:toHex()
            -- log.info("uart", "转换的数据", id, #uart_data, uart_data)
            sys.publish("HLW8032_UART_DATA", uart_data) -- 发布uart数据到消息
        end
        -- 如使用2024.5.13之前编译的ESP32C3/ESP32S3固件, 恢复下面的代码可以正常工作
        -- if #s == len then
        --     break
        -- end
    until s == ""
end)

-- 电压有效值计算函数
local function Voltage_value(voltage_RE,Voltage_REG)
    local voltage_value = (voltage_RE / Voltage_REG) * 4.689 -- 电压值计算公式
    return voltage_value
end

-- 电流有效值的计算函数
local function Current_value(Current_parameter_REG,Current_REG)
    local current_value = (Current_parameter_REG / Current_REG) * 1 -- 电流值计算公式
    return current_value
end

-- 有功功率的计算函数
local function Power_value(Power_parameter_REG,Power_REG)
    local power_value = (Power_parameter_REG / Power_REG) * 4.689*1 -- 功率值计算公式
    return power_value
end

-- 视在功率的计算函数
local function Apparent_power_value(Voltage_value,Current_value)
    local apparent_power_value = Voltage_value * Current_value -- 视在功率值计算公式
    return apparent_power_value
end

-- 功率因数的计算函数
local function Power_factor_value(Power_P,Power_App)
    local power_factor_value = Power_P / Power_App -- 功率因数值计算公式
    return power_factor_value
end

-- 电量计算函数
local function Electricity_value(k,n,p)
    local electricity_value = (k*65536+n)*p*4.689/3600/1000/1000/1000 -- 电量值计算公式
    return electricity_value
end

-- 单独订阅，回调函数，接收string_HEX模块发布的数据
sys.subscribe("HLW8032_DATA", function(data)
	--接收数据
    local State_REG = data.state -- 状态寄存器
    local Voltage_parameter_REG = data.voltage_parameter -- 电压参数寄存器,默认值
    local Voltage_REG = data.voltage -- 电压寄存器
    local Current_parameter_REG = data.current_parameter -- 电流参数寄存器,默认值
    local Current_REG = data.current -- 电流寄存器
    local Power_parameter_REG = data.power_parameter -- 功率参数寄存器,默认值
    local Power_REG = data.power -- 功率寄存器
    local Data_Updata_REG = data.data_updata -- 数据更新寄存器
    local PF_REG = data.pf -- PF寄存器

--[[ 	--打印数据
    log.info("HLW8032", "State_REG", State_REG[1], State_REG[2], State_REG[3], State_REG[4])
    log.info("HLW8032", "Voltage_parameter_REG", Voltage_parameter_REG)
    log.info("HLW8032", "Voltage_REG", Voltage_REG)
    log.info("HLW8032", "Current_parameter_REG", Current_parameter_REG)
    log.info("HLW8032", "Current_REG", Current_REG)
    log.info("HLW8032", "Power_parameter_REG", Power_parameter_REG)
    log.info("HLW8032", "Power_REG", Power_REG)
    log.info("HLW8032", "Data_Updata_REG", Data_Updata_REG[1], Data_Updata_REG[2], Data_Updata_REG[3], Data_Updata_REG[4])
    log.info("HLW8032", "PF_REG", PF_REG) ]]

	-- 计算电压值
    local voltage_value = Voltage_value(Voltage_parameter_REG,Voltage_REG)
    -- 计算电流值
	local current_value = Current_value(Current_parameter_REG,Current_REG)
	-- 计算功率值
	local power_value = Power_value(Power_parameter_REG,Power_REG)
	-- 计算视在功率值
	local apparent_power_value = Apparent_power_value(voltage_value,current_value)
	-- 计算功率因数值
	local power_factor_value = Power_factor_value(power_value,apparent_power_value)
	-- 计算电量值
	--local electricity_value = Electricity_value(State_REG[1],State_REG[2],State_REG[3])

--[[ 	-- 打印数据
	log.info("HLW8032", "电压值", voltage_value)
	log.info("HLW8032", "电流值", current_value)
	log.info("HLW8032", "功率值", power_value)
	log.info("HLW8032", "视在功率值", apparent_power_value)
	log.info("HLW8032", "功率因数值", power_factor_value)
	--log.info("HLW8032", "电量值", electricity_value) ]]

end)

return HLW8032
