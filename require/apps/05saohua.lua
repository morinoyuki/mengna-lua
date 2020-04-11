local function saohua()
    local html = asyncHttpGet("https://chp.shadiao.app/api.php")
    if not html or html == "" then return "舔失败了" end
    return html
end
return {
    check = function (data)
        return data.msg == "骚话"
    end,
    run = function (data,sendMessage)
        if not checkCoolDownTime(data, "saohua", sendMessage) then
            return true
        end
        sys.taskInit(function ()
            sendMessage(saohua())
            --CD时间
            setCoolDownTime(data, "saohua", 60*60)
        end)
        return true
    end,
    explain = function ()
        return "[CQ:emoji,id=127752]骚话 捧到不要不要的"
    end
}