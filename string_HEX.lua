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
    --print("输入的字符=",Hexadecimal)
    --print("字符的长度=",b)
    --print("转换后的HEX=",x)
    --print("数据HEX的长度=",y)
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


-------------------------------------------------------------------------------------
--------------------------处理器上电后，订阅HLW8032_UART_DATA消息并处理数据----------------------------------
-------------------------------------------------------------------------------------

--单独订阅，回调函数，接收uart发布的数据，并处理
sys.subscribe("HLW8032_UART_DATA",function(data)
    print("订阅到HLW8032_UART_DATA消息")
    log.info("订阅", #data, data)
end)











return string_HEX
