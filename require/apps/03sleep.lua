import('System')

return {--精致睡眠
check = function (data)
    return (data.msg == "supersleep" or data.msg == "sleep" or data.msg == "nap") or
    (data.msg:find("%[CQ:at,qq="..CQApi:GetLoginQQId().."%]") and
    (data.msg:find("%d+天") or data.msg:find("%d+小?时")) and (data.msg:find("套餐") or (data.msg:find("禁言"))))
end,
run = function (data,sendMessage)
    if LuaEnvName == "private" then
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
    local time 
    if data.msg == "supersleep" then
        time = TimeSpan(1,0,0,0)
    elseif data.msg == "sleep" then
        time = TimeSpan(8,0,0)
    elseif data.msg == "nap" then
        time = TimeSpan(0,30,0)
    else
        local day = data.msg:match("(%d+)天")
        day = tonumber(day) or 0
        local hour = data.msg:match("(%d+)小?时")
        hour = tonumber(hour) or 0
        if day > 0 or hour > 0 then
            time = TimeSpan(day,hour,0,0)
            if time.TotalSeconds > 2592000  then
                time = TimeSpan(30,0,0,0)
            end
        else
            return false
        end
        CQApi:SetGroupMemberBanSpeak(data.group,data.qq,time)
        sendMessage(Utils.CQCode_At(data.qq).."您要的套餐已送达 请慢用")
        return true
    end
    CQApi:SetGroupMemberBanSpeak(data.group,data.qq,time)
    sendMessage(Utils.CQCode_At(data.qq).."精致深度睡眠套餐已送达 口球戴好杂修")
    return true
end,
explain = function ()
    return "[CQ:emoji,id=128163]sleep 领取精致睡眠套餐"
end
}