local runing
local next = 0
local nieta = require("nieta")
local function nietaRun(data, t, sendMessage)
    local robotInfo = Utils.GetGroupMemberInfo(data.group,CQApi:GetLoginQQId())
    for i, v in ipairs(t) do
        if v.type == "message" then
            sendMessage(v.msg)
        elseif v.type == "record" then --语音
            sendMessage(Utils.CQCode_Record(v.file))
        elseif v.type == "image" then --图片
            sendMessage(Utils.CQCode_Image(v.file))
        elseif v.type == "setban" then --禁言
            if robotInfo and robotInfo.MemberType:ToString () ~= "Member" then --是否管理员
                CQApi:SetGroupBanSpeak(data.group)
            else
                sendMessage("机器人非管理员无法全体禁言")
            end
        elseif v.type == "removeban" then --解禁
            if robotInfo and robotInfo.MemberType:ToString () ~= "Member" then --是否管理员
                CQApi:RemoveGroupBanSpeak(data.group)
            else
                sendMessage("机器人非管理员无法全体解禁")
            end
        end
        if v.wait and v.wait > 0 then sys.wait(v.wait) end
    end
    runing = false
    setCoolDownTime(data, "jojo", 24*60*60)
end
return {
check = function (data)
    return LuaEnvName ~= "private" and not runing and ((data.msg:find("[Jj][Oo][Jj][Oo]") and next and os.time() > next) or
    (nieta[data.msg] and checkCoolDownTime(data,"jojo")))
end,
run = function (data, sendMessage)
    runing = true
    next = os.time()+3600*24
    local name = data.msg
    if data.msg:find("[Jj][Oo][Jj][Oo]") then
        sendMessage("jojo？你说jojo了吧！ wryyyyyyyy")
        name = "泷泽萝拉哒"
    end
    sys.taskInit(function ()
        nietaRun(data, nieta[name], sendMessage)
    end)
    return true
end,
explain = function ()
    return "[CQ:emoji,id=128668]泷泽萝拉哒/阿姨压一压"
end
}