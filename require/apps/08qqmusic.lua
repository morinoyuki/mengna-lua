local function qqmusic(message)
    local key = message:gsub("点歌 *","")
    if key == "" then return "请正确输入关键词" end
    local songID = tonumber(key)
    if not songID and key then
        local html = asyncHttpGet("https://c.y.qq.com/soso/fcgi-bin/client_search_cp", "?ct=24&qqmusic_ver=1298&new_json=1&remoteplace=txt.yqq.song&searchid=&t=0&aggr=1&cr=1&catZhida=1&lossless=0&flag_qc=0&p=1&n=20&w="..key:urlEncode())
        local str = html:match("callback%((.+)%)")
        local j,r,e = jsonDecode(str)
        if r and j.data and j.data.song and j.data.song.list and j.data.song.list[1] then
            songID = j.data.song.list[1].id
        elseif e then
            return "机器人爆炸了，原因："..e
        end
    end
    if songID then
        return "[CQ:music,type=qq,id="..tostring(songID).."]"
    else
        return "机器人爆炸了，原因：根本没这首歌"
    end

end

return {--点歌
check = function (data)
    return data.msg:find("点歌") == 1
end,
run = function (data,sendMessage)
    if not checkCoolDownTime(data,"qqmusic",sendMessage) then
        return true
    end
    sys.taskInit(function()
        local r = qqmusic(data.msg)
        sendMessage(r)
        if r:find("爆炸") then
            setCoolDownTime(data,"qqmusic",10*60)
        end
    end)
    return true
end,
explain = function ()
    return "[CQ:emoji,id=127932]点歌 加 qq音乐id或歌名"
end
}
