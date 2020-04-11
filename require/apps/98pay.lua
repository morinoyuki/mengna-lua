return {
    check = function (data)
        return data.msg == "投食"
    end,
    run = function (data,sendMessage)
        sendMessage(Utils.CQCode_Image("pay\\赞助.jpg").."投食将被用于服务器维护费用")
        return true
    end,
    explain = function ()
        return "[CQ:emoji,id=128176]投食 养我！"
    end
}