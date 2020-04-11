return function (data)
    if not data.all and data.banqq == 1005432229 then
        CQApi:ExitGroup(data.group)
    end
    CQLog:Info("lua插件","机器人被禁言自动退出群:"..tostring(data.group))
end