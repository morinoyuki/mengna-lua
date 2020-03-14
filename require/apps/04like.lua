return {--点赞
check = function (data)--检查函数，拦截则返回true
    return data.msg=="点赞" or data.msg=="赞我"
end,
run = function (data,sendMessage)--匹配后进行运行的函数
    CQApi:SendPraise(data.qq,10)
    sendMessage(Utils.CQCode_At(data.qq).."好了，快给[CQ:emoji,id=128116]爬")
    return true
end,
explain = function ()--功能解释，返回为字符串，若无需显示解释，返回nil即可
    return "[CQ:emoji,id=128077]点赞"
end
}