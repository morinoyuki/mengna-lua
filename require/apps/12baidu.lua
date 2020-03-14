return {--教你百度
check = function (data)
    return data.msg:find("百度") == 1
end,
run = function (data,sendMessage)
    local key = data.msg:gsub("^百度 *","")
    if not key or key == "" then
        return false
    end
    local apiUrl = "http://lab.mkblog.cn/lmbtfy/api.php?url="..("http://lab.mkblog.cn/lmbtfy/?"..key):urlEncode()
    sys.taskInit(function ()
        local html = asyncHttpGet(apiUrl,"",10000)
        local j,r,_ = jsonDecode(html)
        if r and j and j.code == 200 then
            sendMessage(key..":"..j.result)
        else
            sendMessage("error")
        end
    end)
    return true
end,
explain = function ()
    return "[CQ:emoji,id=128269]百度 让我来教你百度"
end
}
