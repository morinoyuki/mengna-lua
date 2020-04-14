--插件启动后调用的文件
--目前仅用来注册各种开机后会运行的东西
--并且当前文件的功能，仅在账号为chenxu自己的测试qq下运行

return function ()
    --防止多次启动
    if AppFirstStart then return end
    AppFirstStart = true

    -- if CQApi:GetLoginQQId() ~= 751323264 then return end--仅限官方群里的机器人号用这个功能

    --服务器空间定期检查任务，十分钟一次
    CQLog:Debug("lua插件","加载服务器空间定期检查任务")
    sys.timerLoopStart(function ()
        CQLog:Debug("lua插件","执行服务器空间定期检查任务")
        local free = Utils.GetHardDiskFreeSpace("C")
        if free < 1024 * 10 then--空间小于10G
            CQApi:SendGroupMessage(828090839,
            Utils.CQCode_At(454693264)..
            "你的小垃圾服务器空间只有"..tostring(Utils.GetHardDiskFreeSpace("C")).."M空间了知道吗？快去清理")
        end
    end,600 * 1000)
    --自动撤回
    CQLog:Debug("lua插件","加载自动撤回任务")
    sys.timerLoopStart(function ()
        local pendingRepeal = Utils.GetVar("autoRepeal")
        if pendingRepeal ~= "" then
            pendingRepeal = jsonDecode(pendingRepeal)
            if #pendingRepeal ~= 0 then
                local i = 1
                local flag = false
                while i <= #pendingRepeal do
                    --执行撤回
                    if pendingRepeal[i].time <= os.time() then
                        CQLog:Debug("lua插件","尝试撤回")
                        CQApi:RemoveMessage(pendingRepeal[i].id)
                        table.remove(pendingRepeal,i)
                        if not flag then flag = true end
                    --通知
                    elseif pendingRepeal[i].notice and
                    pendingRepeal[i].time - os.time() <= pendingRepeal[i].rmngSec then
                        if pendingRepeal[i].group then
                            CQApi:SendGroupMessage(pendingRepeal[i].group,
                            pendingRepeal[i].msg)
                        else
                            CQApi:SendPrivateMessage(pendingRepeal[i].qq,
                            pendingRepeal[i].msg)
                        end
                        pendingRepeal[i].notice = false
                        if not flag then flag = true end
                        i = i+1
                    else
                        i = i+1
                    end
                end
                --刷新数据
                if flag then
                    local j = jsonEncode(pendingRepeal)
                    Utils.SetVar("autoRepeal",j)
                end
            end
        end
    end,1000)
end
