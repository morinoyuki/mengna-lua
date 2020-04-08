local function tiangou()
    local html = asyncHttpGet("https://www.somekey.cn/tiangou/random.php")
    if not html or html == "" then return "舔失败了" end
    local j, r, _ = jsonDecode(html)
    if not j or not r or j.code ~= 1 then return "解析失败" end
    return j.data.date.." "..j.data.weather.."\r\n"..
    j.data.content
end
return {
    check = function (data)
        return data.msg == "舔狗日记" or data.msg == "舔狗日志"
    end,
    run = function (data,sendMessage)
        if not checkCoolDownTime(data, "tiangou", sendMessage) then
            return false
        end
        sys.taskInit(function ()
            sendMessage(tiangou())
            --CD时间
            local time = os.date("*t",os.time()+3600*24)
            time.hour = 0
            time.min = 0
            time.sec = 0
            local cdTime = os.time(time) - os.time()
            setCoolDownTime(data, "tiangou", cdTime)
        end)
        return true
    end,
    explain = function ()
        return "[CQ:emoji,id=128054]舔狗日记 心酸的舔狗日记"
    end
}