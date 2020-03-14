import('System')
local function cqSetGroupBanSpeak(g,q,t)
    local time = TimeSpan(0,0,t)
    CQApi:SetGroupMemberBanSpeak(g,q,time)
end
return {--精致睡眠
check = function (data)
    return ((data.msg == "supersleep" or data.msg == "sleep" or data.msg == "nap") or
    (data.msg:find("%[CQ:at,qq="..CQApi:GetLoginQQId().."%]") and
    (data.msg:find("%d+天.-套餐") or data.msg:find("%d+小?时.-套餐"))))
end,
run = function (data,sendMessage)
    if not data.group then
        sendMessage("私聊你睡尼玛呢")
        return
    end
    local robotInfo = Utils.GetGroupMemberInfo(data.group,CQApi:GetLoginQQId())
    local memberInfo = Utils.GetGroupMemberInfo(data.group,data.qq)
    if robotInfo and robotInfo.MemberType:ToString () == "Member" then
        sendMessage("请先将本机器人设置为管理员")
        return true
    elseif memberInfo and memberInfo.MemberType:ToString () ~= "Member" then
        sendMessage("无法禁言管理员")
        return true
    end
    local banTime = 0
    if data.msg == "supersleep" then
        banTime = 24*60*60-60
    elseif data.msg == "sleep" then
        banTime  = 8*60*60
    elseif data.msg == "nap" then
        banTime = 30*60
    else
        local day = data.msg:match("(%d+)天")
        day = tonumber(day)
        local hour = data.msg:match("(%d+)小?时")
        hour = tonumber(hour)
        if day and day > 0 then
            day = day > 30 and 30 or day
            banTime = day*24*60*60
        elseif hour and hour > 0 then
            hour = hour > 720 and 720 or hour
            banTime = hour*60*60
        else
            return false
        end
    end
    cqSetGroupBanSpeak(data.group,data.qq,banTime)
    sendMessage(Utils.CQCode_At(data.qq).."精致深度睡眠套餐已送达 口球戴好杂修")
    return true
end,
explain = function ()
    return "[CQ:emoji,id=128163]sleep 领取精致睡眠套餐"
end
}