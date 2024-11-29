local HLW8032 = {}
--[[
	时间：2024年11月28日16:15
	作者：BSCC_GN
	功能：电量计量器HLW8032的驱动程序
	版本：v1.0.0
	修订记录：
	1. 创建文件
]]
--初始化硬件——uart通讯——电路网络编号与GPIO编号匹配
local uartid = 1 -- 根据实际设备选取不同的uartid

--初始化
uart.setup(
    uartid,--串口id
    4800,--波特率
    8,--数据位
    1,--停止位
	uart.Even
)

-- 收取数据会触发回调, 这里的"receive" 是固定值
uart.on(uartid, "receive", function(id, len)
    local s = ""
    repeat
        s = uart.read(id, 24)
        if #s >= 24  then -- #s 是取字符串的长度
            -- 如果传输二进制/十六进制数据, 部分字符不可见, 不代表没收到
            -- 关于收发hex值,请查阅 https://doc.openluat.com/article/583
			--log.info("uart", "receive", id, #s, s:toHex())
			local uart_data = s:toHex()
			--log.info("uart", "转换的数据", id, #uart_data, uart_data)
			sys.publish("HLW8032_UART_DATA", uart_data)--发布uart数据到消息
        end
        -- 如使用2024.5.13之前编译的ESP32C3/ESP32S3固件, 恢复下面的代码可以正常工作
        -- if #s == len then
        --     break
        -- end
    until s == ""
end)











--[[
				local State_REG = s:sub(1,1) -- 状态寄存器
				local Check_REG = s:sub(2,2) -- 检测寄存器,默认值
				local Voltage_parameter_REG = s:sub(3,5) -- 电压参数寄存器,默认值
				local Voltage_REG = s:sub(6,8) -- 电压寄存器
				local Current_parameter_REG = s:sub(9,11) -- 电流参数寄存器,默认值
				local Current_REG = s:sub(12,14) -- 电流寄存器
				local Power_parameter_REG = s:sub(15,17) -- 功率参数寄存器,默认值
				local Power_REG = s:sub(18,20) -- 功率寄存器
				local Data_Updata_REG = s:sub(21,21) -- 数据更新寄存器
				local PF_REG= s:sub(22,23) -- PF寄存器
				local CheckSum_REG= s:sub(24,24) -- 校验和寄存器
				log.info("State_REG", State_REG, State_REG:toHex())
				log.info("Check_REG", Check_REG, Check_REG:toHex())
				log.info("Voltage_parameter_REG", Voltage_parameter_REG, Voltage_parameter_REG:toHex())
				log.info("Voltage_REG", Voltage_REG, Voltage_REG:toHex())
				log.info("Current_parameter_REG", Current_parameter_REG, Current_parameter_REG:toHex())
				log.info("Current_REG", Current_REG, Current_REG:toHex())
				log.info("Power_parameter_REG", Power_parameter_REG, Power_parameter_REG:toHex())
				log.info("Power_REG", Power_REG, Power_REG:toHex())
				log.info("Data_Updata_REG", Data_Updata_REG, Data_Updata_REG:toHex())
				log.info("PF_REG", PF_REG, PF_REG:toHex())
				log.info("CheckSum_REG", CheckSum_REG, CheckSum_REG:toHex())
				local ck = crypto.checksum(0x11)
				log.info("checksum", "ok", string.format("%02X", ck))
]]






return HLW8032
