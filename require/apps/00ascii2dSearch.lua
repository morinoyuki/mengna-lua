--ascii2d
local htmlParser = require("htmlparser")
local searchFlag = {}
local function getHtml(url,path,mode)
    if not mode then mode = "get" end
    local html
    if mode == "get" then
        html = asyncHttpGet(url,"",30000)
    elseif mode == "post" then
        html = asyncHttpUploadFile(url,"file",path,36000)
    end
    if not html or html == "" then
        return nil
    end
    local root = htmlParser.parse(html)
    return root
end

local function getHash(root)
    local hashTree = root(".hash")
    return hashTree[1]:getcontent()
end

local function getItemInfo(root)
    local itemTree = root(".item-box")
    if #itemTree == 0 then
        return nil
    end
    local n = 0
    local res = ""
    for i=1,#itemTree do
        local itemStr = itemTree[i]:getcontent()
        local itemRoot = htmlParser.parse(itemStr)
        local linkTree = itemRoot("h6 > a")
        local linkHref = ""
        local linkContent = ""
        local imageSrc = ""
        if #linkTree ~= 0 then
            linkHref = linkTree[1].attributes['href']:find("http") and linkTree[1].attributes['href'] or "https://ascii2d.net"..linkTree[1].attributes['href']
            linkContent = linkTree[1]:getcontent()
            local imageTree = itemRoot(".image-box > img")
            imageSrc = "https://ascii2d.net"..imageTree[1].attributes['src']
            
            res = res..asyncImage(imageSrc,true).."\r\n"..
            linkContent.."\r\n"..
            linkHref.."\r\n"..
            "-------------\r\n"
            n = n+1
            if n >= 2 then
                return res
            end
        end
    end
    return res
end

local function getImageInfo(path)
    --色合検索
    local root = getHtml("https://ascii2d.net/search/url/"..path)
    local bovwData
    local errorInfo = "未知错误"
    if not root then
        return "数据获取失败"
    end
    local hash = getHash(root)
    local colorData = getItemInfo(root)
    if not colorData then
        return "BOOM"
    end
    --特徴検索
    if hash and hash ~= "" then
        root = getHtml("https://ascii2d.net/search/bovw/"..hash)
        if root then
            bovwData = getItemInfo(root)
            if not bovwData then
                errorInfo = "获取图片信息失败"
            end
        else
            errorInfo = "获取数据未成功"
        end
    else
        errorInfo = "HASH获取失败"
    end
    return "色合検索:\r\n"..colorData..
        "特徴検索:\r\n"..(bovwData or errorInfo.."\r\n").."Engine by Ascii2d\r\nScript by 喵萌茶会组长:老森"
end

local function ascii2d(message,sendMessage)
    local path = Utils.GetImageUrl(message)
    if path and path:len() ~= 0 then
        sendMessage("少女祈祷中....")
        -- path = Utils.GetAsciiHex(path):fromHex()
        return getImageInfo(path)
    else
        return "未在消息中过滤出图片"
    end
end

return {--Ascii2d搜图
check = function (data)
    return (data.msg:lower():find("^a2d") or data.msg:lower():find("a2d$")) or
    (data.msg:find("%[CQ:image,file=") and searchFlag[tostring(data.qq)])
end,
run = function (data,sendMessage)
    if data.msg:lower():gsub(" ","") == "a2d" then
        searchFlag[tostring(data.qq)] = true
        sendMessage(Utils.CQCode_At(data.qq).."请发送要搜索的图片")
    else
        if searchFlag[tostring(data.qq)] then
            searchFlag[tostring(data.qq)] = nil
        end
        sys.taskInit(function ()
            local r = ascii2d(data.msg,sendMessage)
            sendMessage(Utils.CQCode_At(data.qq).."\r\n"..r)
        end)
    end
    
    return true
end,
explain = function ()
    return "[CQ:emoji,id=128444]a2d 加 二次元图片"
end
}

