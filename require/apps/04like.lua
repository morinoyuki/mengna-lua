return {--点赞
check = function (data)--检查函数，拦截则返回true
    return (data.msg=="点赞" or data.msg=="赞我") and checkCoolDownTime(data, "like")
end,
run = function (data,sendMessage)--匹配后进行运行的函数
    if math.random() > 0.8 then
        sendMessage(Utils.CQCode_At(data.qq).."\r\n"..Utils.CQCode_Image("jojo\\jujue.jpg"))
        setCoolDownTime(data, "like", 12*60*60)
        return true
    end
    CQApi:SendPraise(data.qq, 10)
    if math.random(1, 100) > 50 then
        sendMessage(Utils.CQCode_At(data.qq).."\r\n"..Utils.CQCode_Image("jojo\\like.jpg").."\r\n吉良吉影为你点赞")
    else
        sendMessage(Utils.CQCode_At(data.qq).."好了，快给[CQ:emoji,id=128116]爬")
    end
    return true
end,
explain = function ()--功能解释，返回为字符串，若无需显示解释，返回nil即可
    return "[CQ:emoji,id=128077]点赞"
end
}