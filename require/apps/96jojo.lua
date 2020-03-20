return {
check = function (data)
    return data.msg == "泷泽萝拉哒" and checkCoolDownTime(data,"jojo")
end,
run = function (data,sendMessage)
    sys.taskInit(function ()
        for i = 1, 12 do
            sendMessage(Utils.CQCode_Record("声音"..tostring(i)..".mp3"))
            if i == 3 then
                sendMessage(Utils.CQCode_Image("jojo\\theworld.jpg"))
                sys.wait(60*60)
                CQApi:SetGroupBanSpeak(data.group)
            end
            sys.wait(60*100)
        end
        CQApi:RemoveGroupBanSpeak(data.group)
        setCoolDownTime(data,"jojo",12*60*60)
    end)
    return true
end,
explain = function ()
    return "[CQ:emoji,id=128668]泷泽萝拉哒"
end
}