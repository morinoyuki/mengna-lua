local function av(av)
    av = av:match("av(%d+)")
    local html = asyncHttpGet("http://api.bilibili.com/x/web-interface/view?aid="..av)
    if not html then return "查找失败" end
    local j,r,e = jsonDecode(html)
    if j.code ~= 0 then return "数据解析失败啦" end
    local image = j.data.pic and asyncImage(j.data.pic)
    return (image and image.."\r\n" or "")..
    "av"..av..",标题："..j.data.title..
    "\r\n"..j.data.desc:gsub("<br/>","\r\n")..
    "\r\n分区："..(j.data.tname and j.data.tname or "")
end
local function bv(bv)
    bv = bv:match("BV(%w+)")
    local html = asyncHttpGet("http://api.bilibili.com/x/web-interface/view?bvid="..bv)
    if not html then return "查找失败" end
    local j,r,e = jsonDecode(html)
    if j.code ~= 0 then return "数据解析失败啦" end
    local image = j.data.pic and asyncImage(j.data.pic)
    return (image and image.."\r\n" or "")..
    "BV"..bv..",标题："..j.data.title..
    "\r\n"..j.data.desc:gsub("<br/>","\r\n")..
    "\r\n分区："..(j.data.tname and j.data.tname or "")
end
return {--b站解析
    check = function (data)
        return data.msg:find("av%d+") or data.msg:find("BV%d+")
    end,
    run = function (data,sendMessage)
        if data.msg:find("av%d+") then
            sys.taskInit(function ()
                sendMessage(av(data.msg))
            end)
        else
            sys.taskInit(function ()
                sendMessage(bv(data.msg))
            end)
        end
        return true
    end,
    explain = function ()
        return "[CQ:emoji,id=127902]b站av/BV号解析"
    end
}
