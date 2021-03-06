return {--点赞
check = function (data)
    return (data.msg=="点赞" or data.msg=="赞我")
end,
run = function (data,sendMessage)
    if not checkCoolDownTime(data, "like", sendMessage) then
        return true
    end
    --CD时间
    local time = os.date("*t",os.time()+3600*24)
    time.hour = 0
    time.min = 0
    time.sec = 0
    local cdTime = os.time(time) - os.time()
    setCoolDownTime(data, "like", cdTime)
    --拒绝
    if randNum() > 0.8 then
        sendMessage(Utils.CQCode_At(data.qq).."\r\n"..Utils.CQCode_Image("jojo\\jujue.gif"))
        return true
    end
    --开始点赞
    local msgs = {
        "\r\n"..Utils.CQCode_Image("jojo\\like.jpg").."\r\n吉良吉影为你点赞",
        "好了，快给[CQ:emoji,id=128116]爬",
        "\r\n"..Utils.CQCode_Image("beidou\\百裂拳.gif").."健次郎为你点赞(死兆星在闪闪发光)",
        "\r\n"..Utils.CQCode_Image("jojo\\觉得很赞.jpg")
    }
    CQApi:SendPraise(data.qq, 10)
    sendMessage(Utils.CQCode_At(data.qq)..msgs[randNum(1, #msgs)])
    return true
end,
explain = function ()
    return "[CQ:emoji,id=128077]点赞"
end
}