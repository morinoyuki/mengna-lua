return function (data)
    if data.qq == Utils.setting.AdminQQ then--开发者邀请
        CQApi:SetGroupAddRequest(data.tag,CQGroupAddRequestType.RobotBeInviteAddGroup,CQResponseType.PASS,"同意邀请操作")--同意邀请
        return
    end
    -- CQApi:SetGroupAddRequest(data.tag,2,2,"不加新群"..tostring(data.qq))
    local inviteeData = Utils.GetVar("groupInvitee")
    inviteeData = inviteeData ~= "" and jsonDecode(inviteeData) or {}
    table.insert(inviteeData, data.tag) --加入记录
    local j,r,_ = jsonEncode(inviteeData)
    Utils.SetVar("groupInvitee",j)
    local s = CQApi:GetStrangerInfo(data.qq).Nick..
    "("..tostring(data.qq)..")试图邀请我加入"..tostring(data.group).."\r\n"..
    "#同意"..tostring(#inviteeData)
    CQApi:SendPrivateMessage(Utils.setting.AdminQQ,s)
end
