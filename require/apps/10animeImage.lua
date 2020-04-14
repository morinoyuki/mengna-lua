return {--随机动漫图片
check = function (data)
    return data.msg:find("动漫图片 *%d*$") == 1 or data.msg:find("涩图 *%d*$") == 1
end,
run = function (data,sendMessage)
    if not checkCoolDownTime(data, "animeImage", sendMessage) then
        return true
    end
    local apiUrlList = {
        "https://acg.yanwz.cn/api.php",
        "https://img.xjh.me/random_img.php?return=302",
    }
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    local index = tonumber(data.msg:match("(%d+)")) or math.random(1,#apiUrlList)
    if index > #apiUrlList then
        sendMessage("不存在此接口")
    else
        sys.taskInit(function ()
            local img = asyncImage(apiUrlList[index])
            if img ~= "" then
                setCoolDownTime(data, "animeImage", 5*60)
            end
            sendMessage((img ~= "" and img or "读取失败，请重试").."\r\n来自"..tostring(index).."号API接口 当前接口总数:"..tostring(#apiUrlList))
        end)
    end
    return true
end,
explain = function ()
    return "[CQ:emoji,id=128152]动漫图片 随机二次元图片"
end
}