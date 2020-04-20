--网易云

local function netEaseMusic(message)
    local songID
    local key
    if message:find("music%.163%.com/song%?id=%d+") then
        songID = message:match("song%?id=(%d+)")
    else
        key = message:gsub("网易点歌 *",""):gsub("网易云点歌 *","")
        if key == "" then return "请正确输入关键词" end
        songID = tonumber(key)
    end
    
    if not songID and key then
        local html = asyncHttpGet("http://music.163.com/api/search/get/web", "csrf_token=hlpretag=&hlposttag=&s="..key:urlEncode().."&type=1&offset=0&total=true&limit=1")
        if not html then
            return "机器人爆炸了，原因：数据获取失败"
        end
        local j,r,e = jsonDecode(html)
        if r and j.result.songCount > 0 and j.result.songs[1].id then
            songID = j.result.songs[1].id
        elseif e then
            return "机器人爆炸了，原因："..e
        end
    end
    if songID then
        return "[CQ:music,type=163,id="..tostring(songID).."]"
    else
        return "机器人爆炸了，原因：根本没这首歌"
    end
end

return {--网易点歌
check = function (data)
    return data.msg:find("网易点歌") == 1 or data.msg:find("网易云?点歌") == 1 or data.msg:find("music%.163%.com/song%?id=%d+")
end,
run = function (data,sendMessage)
    if not checkCoolDownTime(data,"netEase",sendMessage) then
        return true
    end
    sys.taskInit(function ()
        local r = netEaseMusic(data.msg)
        sendMessage(r)
        if not r:find("爆炸") then
            setCoolDownTime(data,"netEase",5*60)
        end
    end)
    return true
end,
explain = function ()
    return "[CQ:emoji,id=127932]网易点歌 加 网易音乐id或歌名"
end
}