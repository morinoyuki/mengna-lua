import("Native.Csharp.Sdk","Native.Csharp.Sdk.Cqp.Enum")

 
return function (data)
    if data.qq == Utils.setting.AdminQQ then--开发者邀请
        CQApi:SetGroupAddRequest(data.tag,CQGroupAddRequestType.RobotBeInviteAddGroup,CQResponseType.PASS,"同意邀请操作")--同意邀请
    end
    -- CQApi:SetGroupAddRequest(data.tag,2,2,"不加新群"..tostring(data.qq))
end
