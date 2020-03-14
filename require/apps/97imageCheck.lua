local onGroupList = {}
local function switch(data,sendMessage)
    if data.qq ~= Utils.setting.AdminQQ then
        sendMessage("无操作权限")
        return
    end
    local r18CheckSwitch = XmlApi.Get("r18CheckGroup",tostring(data.group))
    local robotInfo = Utils.GetGroupMemberInfo(data.group,CQApi:GetLoginQQId())

    if r18CheckSwitch == "on" then
        local nick = robotInfo.Nick:gsub("「巡视中」","")
        r18CheckSwitch = "off"
        onGroupList[tostring(data.group)] = false
        CQApi:SetGroupMemberVisitingCard(data.group,CQApi:GetLoginQQId(),nick)
    else
        local nick = robotInfo.Nick:gsub("「巡视中」","").."「巡视中」"
        r18CheckSwitch = "on"
        onGroupList[tostring(data.group)] = true
        CQApi:SetGroupMemberVisitingCard(data.group,CQApi:GetLoginQQId(),nick)
    end
    XmlApi.Set("r18CheckGroup",tostring(data.group),r18CheckSwitch)
    sendMessage(Utils.CQCode_At(data.qq)..(r18CheckSwitch == "on" and "涩图检测已开启" or "涩图检测已关闭"))
end
--是否开启
local function isOn(group)
    if onGroupList[tostring(group)] == nil then
        onGroupList[tostring(group)] = XmlApi.Get("r18CheckGroup",tostring(group)) == "on"
    end
    return onGroupList[tostring(group)]
end
return {--涩图检查
check = function (data)
    return (data.msg:find("%[CQ:image,file=") and isOn(data.group)) or
            data.msg == "涩图检测"
end,
run = function (data,sendMessage)
    if data.msg == "涩图检测"  then--开关
        switch(data,sendMessage)
    else
        local memberInfo = Utils.GetGroupMemberInfo(data.group,data.qq)
        if memberInfo.MemberType:ToString() ~= "Member" then
            return false
        end
        sys.taskInit(function ()
            imageCheck.checkAndBan(data,sendMessage)
        end) 
    end
    return false
end,
explain = function ()
    return "[CQ:emoji,id=128286]涩图检测 检查尺度大的图片"
end
}