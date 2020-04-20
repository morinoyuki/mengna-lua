return {
    check = function (data)
        return (LuaEnvName ~= "private" and data.msg:gsub("%[CQ:.-%]",""):len() > 1 and
        (data.msg:find("%[CQ:at,qq="..CQApi:GetLoginQQId().."%]") or randNum() > 0.9)) or data.msg == "投食"
    end,
    run = function (data,sendMessage)
        if data.msg == "投食" then
            sendMessage(Utils.CQCode_Image("pay\\赞助.jpg").."投食将被用于服务器维护费用")
            return true
        end
        if data.qq == 1000000 then
            return true
        end
        local replyGroup = LuaEnvName ~= "private" and XmlApi.RandomGet(tostring(data.group),data.msg) or ""
        local replyCommon = XmlApi.RandomGet("common",data.msg)
        if replyGroup == "" and replyCommon ~= "" then
            sendMessage(replyCommon)
        elseif replyGroup ~= "" and replyCommon == "" then
            sendMessage(replyGroup)
        elseif replyGroup ~= "" and replyCommon ~= "" then
            sendMessage(math.random(1,10)>=5 and replyCommon or replyGroup)
        else
            return false
        end
        return true
    end,
    explain = function ()
        return "[CQ:emoji,id=128176]投食 养我！"
    end
}