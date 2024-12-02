local DS18B20_init = {}
--[[
	时间：2024年11月27日18:39
	作者：BSCC_GN
	功能：通过DS18B20传感器检测环境温度
	注意事项：
	版本：v1.0.0
	修订记录：
	1. 创建文件
	2. 完成DS18B20初始化，60秒采集一次数据并打印

]]
local ds18b20_pin = 19 -- DS18B20 引脚

-- 示例权重（可以根据需要调整）
local weights = {1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10}

-- 加权平均滤波器
local function weighted_average_filter(temperature_data, weights)
    local weighted_sum = 0
    local weight_sum = 0

    for i = 1, #temperature_data do
        weighted_sum = weighted_sum + (temperature_data[i] * weights[i])
        weight_sum = weight_sum + weights[i]
    end

    if weight_sum == 0 then
        return 0 -- 避免除以零
    end

    return weighted_sum / weight_sum
end

-- 判断当前采集的温度和上次输出结果之前的温度的差值是否大于指定阈值
local function check_difference(current, Past , threshold)
    if math.abs(current - Past) > threshold then
        return current  -- 返回当前温度值
    else
        return nil  -- 如果差值不大于阈值，返回nil
    end
end


-- 温度数据存储表
local temperature_data = {}
--储存上一次输出的温度
local temperature_Past = 25

-- 温度采集函数
local function collect_temperature()
    local val,result = sensor.ds18b20(ds18b20_pin, true)
    return val
end

-- 更新温度数据
local function update_temperature_data(new_temperature)
    -- 插入新的温度数据
    table.insert(temperature_data, new_temperature)

    -- 如果超过10个数据，则删除最旧的数据
    if #temperature_data > 30 then
        table.remove(temperature_data, 1)  -- 移除第一个元素
    end
end

-- 主逻辑
local function DS18B20_task()
    local new_temperature = collect_temperature()-- 温度采集函数
    --print(string.format("采集到的温度: %.2f", new_temperature/10))

    update_temperature_data(new_temperature/10)-- 更新温度数据

    -- 输出当前的温度数据
--[[     print("当前保存的最近30次温度数据: ")
    for _, temp in ipairs(temperature_data) do
        print(string.format("%.2f", temp))
    end ]]
	-- 加权平均滤波器输出的温度
	local filtered_temperature = weighted_average_filter(temperature_data, weights)
	--print("加权平均滤波器输出的温度",string.format("%.2f", filtered_temperature/10))
	--输出的温度与上次输出温度的对比
	local current_temperature = check_difference(filtered_temperature, temperature_Past, 0.1)
	-- 如果有变化，则更新temperature_Past
	if current_temperature then
		temperature_Past = current_temperature
		--print(string.format("采集到的温度: %.2f", new_temperature/10))
		print(string.format("输出的温度：%.2f", current_temperature-0.4))
	end
    -- 控制采集频率
    --sys.wait(100)
end




sys.taskInit(function()
    while 1 do
        sys.wait(300)
        --local val,result = sensor.ds18b20(ds18b20_pin, true)
        --log.info("ds18b20", val,result)
		--local filtered_temperature = weighted_average_filter(temperature_data, weights)

		DS18B20_task()

    end
end)




return DS18B20_init
