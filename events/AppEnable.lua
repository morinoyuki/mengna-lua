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

    -- --mc服务器定时重启
    -- CQLog:Debug("lua插件","加载mc服务器定时重启任务")
    -- sys.taskInit(function ()
    --     while true do
    --         local delay
    --         local time = os.date("*t")
    --         if time.hour >=3 then
    --             local next = os.date("*t",os.time()+3600*24)
    --             next.hour = 3
    --             next.min = 0
    --             next.sec = 0
    --             delay = os.time(next) - os.time()
    --         else
    --             next.hour = 3
    --             next.min = 0
    --             next.sec = 0
    --             delay = os.time(time) - os.time()
    --         end
    --         CQLog:Debug("lua插件","mc自动重启，延时"..delay.."秒")
    --         sys.wait(delay * 1000)
    --         CQLog:Debug("lua插件","mc自动重启，开始执行")
    --         if Utils.GetHardDiskFreeSpace("D") > 1024 * 10 then
    --             CQApi:SendGroupMessage(241464054,
    --                 "一分钟后，将自动进行服务器例行重启与资源世界回档，请注意自己身上的物品")
    --             TcpServer.Send("一分钟后，将自动进行服务器例行重启与资源世界回档，请注意自己身上的物品")
    --             sys.wait(60000)
    --             TcpServer.Send("cmdstop")
    --             sys.wait(3600*1000)
    --             TcpServer.Send("cmdworld create mine")
    --         end
    --     end
    -- end)

    -- --检查GitHub更新
    -- sys.taskInit(function ()
    --     while true do
    --         CQLog:Debug("lua插件","检查GitHub更新，开始执行")
    --         local r,info = pcall(function ()
    --             local cr,ct = checkGitRelease("https://api.github.com/repos/chenxuuu/receiver-meow/releases/latest","githubRelease")
    --             if cr and ct then CQApi:SendGroupMessage(931546484, "接待喵lua插件发现插件版本更新\r\n"..ct) end
    --         end)
    --         if not r then print(info) end
    --         CQLog:Debug("lua插件","检查GitHub更新，结束执行")
    --         sys.wait(600*1000)
    --     end
    -- end)


    -- sys.taskInit(function ()
    --     while true do
    --         CQLog:Debug("lua插件","检查直播，开始执行")
    --         local r,info = pcall(function ()
    --             --检查要监控的y2b频道
    --             v2bAll(y2bList)
    --             --检查b站
    --             for i=1,#bList do
    --                 checkb(bList[i][1],bList[i][2])
    --             end
    --             --检查twitcasting
    --             for i=1,#tList do
    --                 checkt(tList[i][1],tList[i][2])
    --             end
    --             --fc2检查
    --             for i=1,#fc2List do
    --                 checkfc2(fc2List[i])
    --             end
    --         end)
    --         if not r then print(info) end
    --         CQLog:Debug("lua插件","检查直播，结束执行")
    --         sys.wait(60*1000)--一分钟后继续检查一次
    --     end
    -- end)
end
