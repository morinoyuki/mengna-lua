return function (data)
    if not data.all and data.banqq == CQApi:GetLoginQQId() then
        CQApi:SendPrivateMessage(Utils.setting.AdminQQ, "被禁言自动退出群:"..CQApi:GetGroupInfo(data.group).Name.."("..tostring(data.group)..")")
        CQApi:ExitGroup(data.group)
    end
end