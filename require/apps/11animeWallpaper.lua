return {--随机动漫壁纸
check = function (data)
    return data.msg:find("动漫壁纸") == 1
end,
run = function (data,sendMessage)
    local apiUrlList = {
        -- "https://api.w0ai1uo.org/api/dongman/",
        -- "https://s0.xinger.ink/acgimg/acgurl.php",
        "https://api.ixiaowai.cn/api/api.php",
        "http://api.btstu.cn/sjbz/?lx=dongman",
    }
    local index = tonumber(data.msg:match("(%d+)")) or math.random(1,#apiUrlList)
    if index > #apiUrlList then
        sendMessage("不存在此接口")
    else
        sys.taskInit(function ()
            local img = asyncImage(apiUrlList[index])
            sendMessage((img ~= "" and img or "壁纸读取失败，请重试").."\r\n来自"..tostring(index).."号API接口 当前接口总数:"..tostring(#apiUrlList))
        end)
    end
    return true
end,
explain = function ()
    return "[CQ:emoji,id=127964]动漫壁纸 随机获取一张壁纸"
end
}