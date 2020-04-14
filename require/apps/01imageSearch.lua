--搜图
--api key请用自己的
local key = XmlApi.Get("settings","saucenao"):split("|")
local keyIndex = 0
local searchFlag = {}
local function getUrls(urls)
    local ret = ""
    for i = 1, #urls do
        ret = ret..urls[i].."\r\n"
    end
    return ret
end
local function getImageInfo(pic)
    if keyIndex >= #key then
        keyIndex = 1
    else
        keyIndex = keyIndex+1
    end
    local html = asyncHttpGet("https://saucenao.com/search.php?"..(#key ~= 0 and "api_key="..key[keyIndex].."&" or "")..
        "db=999&output_type=2&numres=16&url="..pic:urlEncode(),"",30000)
    local t,r,_ = jsonDecode(html)
    if not r or not t then return false,"查找失败 可能今日搜索限额已满 明日再试或使用a2d代替" end
    if not t.results or #t.results==0 then return false,"未找到结果 请尝试使用a2d搜索看看" end
    local result = ""
    local last = {}
    local n = 0
    for i=1,#t.results do
        local tmp = ""
        local flag = false
        if t.results[i].header.index_id == 5 and tonumber(t.results[i].header.similarity) > t.header.minimum_similarity then
            tmp = (t.results[i].header.thumbnail and asyncImage(t.results[i].header.thumbnail,true) or "").."\r\n"..
            (t.results[i].data.title and t.results[i].data.title or "").."\r\n"..
            (t.results[i].data.pixiv_id and "p站id："..t.results[i].data.pixiv_id or "").."\r\n"..
            (t.results[i].data.member_name and "画师："..t.results[i].data.member_name or "").."\r\n"..
            (t.results[i].data.ext_urls[1] and getUrls(t.results[i].data.ext_urls) or "")
        elseif t.results[i].header.index_id == 21 and tonumber(t.results[i].header.similarity) > t.header.minimum_similarity then
            tmp = (t.results[i].header.thumbnail and asyncImage(t.results[i].header.thumbnail) or "").."\r\n"..
            (t.results[i].data.source and t.results[i].data.source or "").."\r\n"..
            (t.results[i].data.part and "集数："..t.results[i].data.part or "").."\r\n"..
            (t.results[i].data.est_time and "时间："..t.results[i].data.est_time or "").."\r\n"..
            (t.results[i].data.ext_urls[1] and getUrls(t.results[i].data.ext_urls) or "")
        elseif t.results[i].header.index_id == 18 and tonumber(t.results[i].header.similarity) > t.header.minimum_similarity then
            tmp = (t.results[i].header.thumbnail and asyncImage(t.results[i].header.thumbnail,true) or "").."\r\n"..
            (t.results[i].data.source and t.results[i].data.source or "").."\r\n"..
            (t.results[i].data.creator[1] and "创作者："..t.results[i].data.creator[1] or "").."\r\n"..
            (t.results[i].data.eng_name and "英文名："..t.results[i].data.eng_name.."\r\n" or "")..
            (t.results[i].data.jp_name and "日文名："..t.results[i].data.jp_name.."\r\n" or "")
        elseif (t.results[i].header.index_id == 12 or t.results[i].header.index_id == 26) and
        tonumber(t.results[i].header.similarity) > t.header.minimum_similarity then
            tmp = (t.results[i].header.thumbnail and asyncImage(t.results[i].header.thumbnail,true) or "").."\r\n"..
            ((t.results[i].data.creator and t.results[i].data.creator ~= "") and "创作者："..t.results[i].data.creator.."\r\n" or "")..
            ((t.results[i].data.characters and t.results[i].data.characters ~= "") and "人物："..t.results[i].data.characters.."\r\n" or "")..
            ((t.results[i].data.material and t.results[i].data.material ~= "") and "原著："..t.results[i].data.material.."\r\n" or "")..
            (t.results[i].data.source and "来源："..t.results[i].data.source.."\r\n" or "")..
            (t.results[i].data.ext_urls[1] and getUrls(t.results[i].data.ext_urls) or "")
        elseif tonumber(t.results[i].header.similarity) > t.header.minimum_similarity then
            tmp = (t.results[i].header.thumbnail and asyncImage(t.results[i].header.thumbnail,true) or "").."\r\n"..
            (t.results[i].data.title and t.results[i].data.title.."\r\n" or "")..
            (t.results[i].data.ext_urls[1] and getUrls(t.results[i].data.ext_urls) or "")
        end
        if tonumber(t.results[i].header.similarity) > t.header.minimum_similarity and
        t.results[i].header.index_id ~= 18 and
        t.results[i].data.ext_urls and
        t.results[i].data.ext_urls[1] then
            if #last ~= 0 then
                for m=1,#last do
                    if last[m] == t.results[i].data.ext_urls[1] then
                        flag = true
                    end
                end
                if not flag then last[#last+1] = t.results[i].data.ext_urls[1] end
            else
            last[1] = t.results[i].data.ext_urls[1]
            end
        end
        if tmp ~= "" and not flag then
            result = result..tmp..
            (tonumber(t.results[i].header.similarity) < 40 and "此结果相似度过低，可能不正确" or "相似度："..t.results[i].header.similarity)..
            "\r\n-------------------\r\n"
            n = n+1
            if n >= 3 then
                break
            end
        end
    end
    if n > 0 then
        return true,result..tostring(n).."个结果"
    end
    return false,"未找到结果 请尝试使用a2d搜索看看"
end

local function imageSearch(data,sendMessage)
    local pic = Utils.GetImageUrl(data.msg)
    if pic and pic ~= "" then
        local id = sendMessage("少女祈祷中....")
        local ok,r = getImageInfo(pic)
        if ok then
            setCoolDownTime(data,"imageSearch",10*60)
        end
        CQApi:RemoveMessage(id)
        return r,ok
    else
        return "未在消息中过滤出图片"
    end
end

return {--搜图
check = function (data)
    return (data.msg:find("^搜图") or data.msg:find("搜图$")) or
    (data.msg:find("%[CQ:image,file=") and searchFlag[tostring(data.qq)])
end,
run = function (data,sendMessage)
    if not checkCoolDownTime(data, "imageSearch", sendMessage) then
        return true
    end
    if data.msg:gsub(" ","") == "搜图" then
        searchFlag[tostring(data.qq)] = true
        sendMessage(Utils.CQCode_At(data.qq).."请发送要搜索的图片")
    else
        if searchFlag[tostring(data.qq)] then
            searchFlag[tostring(data.qq)] = nil
        end
        sys.taskInit(function ()
            local r,ok = imageSearch(data,sendMessage)
            local id = sendMessage(Utils.CQCode_At(data.qq).."\r\n"..r)
            if LuaEnvName ~= "private" and ok and id > 0 then
                setAutoRemove(data,id,(2*60)-5)
            end
        end)
    end
    return true
end,
explain = function ()
    return "[CQ:emoji,id=128444]搜图 加 完整二次元图片"
end
}