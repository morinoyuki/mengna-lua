return function ()
    --防止多次启动
    if AppFirstStart then return end
    AppFirstStart = true

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
    --限额清空
    sys.taskInit(function ()
        while true do
            local time = os.date("*t",os.time()+3600*24)
            time.hour = 0
            time.min = 0
            time.sec = 0
            local delay = os.time(time) - os.time()
            sys.wait(delay*1000)
            CQLog:Debug("lua插件", "开始清空搜图使用次数")
            XmlApi.Delete("useNum", "imageSearch")
            CQLog:Debug("lua插件", "开始清空搜番使用次数")
            XmlApi.Delete("useNum", "animeSearch")
            sys.wait(60*1000)
        end
    end)
end
