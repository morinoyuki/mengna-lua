return {--点赞
check = function (data)
    return (data.msg=="点赞" or data.msg=="赞我")
end,
run = function (data,sendMessage)
    if not checkCoolDownTime(data, "like", sendMessage) then
        return false
    end
    --CD时间
    local time = os.date("*t",os.time()+3600*24)
    time.hour = 0
    time.min = 0
    time.sec = 0
    local cdTime = os.time(time) - os.time()
    setCoolDownTime(data, "like", cdTime)
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    --拒绝
    if math.random() > 0.8 then
        sendMessage(Utils.CQCode_At(data.qq).."\r\n"..Utils.CQCode_Image("jojo\\jujue.gif"))
        return true
    end
    --开始点赞
    CQApi:SendPraise(data.qq, 10)
    if math.random() > 0.5 then
        sendMessage(Utils.CQCode_At(data.qq).."\r\n"..Utils.CQCode_Image("jojo\\like.jpg").."\r\n吉良吉影为你点赞")
    else
        sendMessage(Utils.CQCode_At(data.qq).."好了，快给[CQ:emoji,id=128116]爬")
    end
    return true
end,
explain = function ()
    return "[CQ:emoji,id=128077]点赞"
end
}