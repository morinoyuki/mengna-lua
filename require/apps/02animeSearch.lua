--查动画
--api key请用自己的
local key = XmlApi.Get("settings","trace.moe")
local searchFlag = {}
local function animeSearch(data,sendMessage)
    local pCheck = Utils.GetPictureWidth(data.msg) / Utils.GetPictureHeight(data.msg)
    if pCheck <= 1.3 or pCheck >= 2.4 then
        return "别拿表情忽悠我、请换一张完整的、没有裁剪过的动画视频截图",false
    elseif pCheck ~= pCheck then --0/0 == IND
        return "未在消息中过滤出图片",false
    end

    local imagePath = Utils.GetImagePath(data.msg)--获取图片路径

    if not imagePath then
        return "图片读取失败",false
    end
    sendMessage("少女祈祷中....")
    --imagePath = Utils.GetAsciiHex(imagePath):fromHex()--转码路径，以免乱码找不到文件

    local base64 = Utils.Base64File(imagePath,Utils.GetPictureHeight(data.msg) > 720 and 720 or 0) --获取base64结果
    local html = asyncHttpPost("https://trace.moe/api/search?token="..key,
    "image=data:image/jpeg;base64,"..base64,15000)
    if not html or html:len() == 0 then
        return "查找失败，网站炸了，请稍后再试。",false
    end
    local d,r,i = jsonDecode(html)
    if r then
        return "搜索结果：\r\n"..
        "动画名："..d.docs[1].title_native.."("..d.docs[1].title_romaji..")\r\n"..
        (d.docs[1].title_chinese and "译名："..d.docs[1].title_chinese.."\r\n" or "")..
        (d.docs[1].similarity < 0.86 and "准确度："..tostring(math.floor(d.docs[1].similarity*100)).."%"..
        "\r\n（准确度过低，请确保这张图片是完整的、没有裁剪过的动画视频截图）\r\n" or "")..
        (d.docs[1].episode and "话数："..tostring(d.docs[1].episode).."\r\n" or "")..
        ((not d.docs[1].is_adult and d.docs[1].tokenthumb and d.docs[1].tokenthumb ~= "") and
        asyncImage("https://trace.moe/thumbnail.php?anilist_id="..tostring(d.docs[1].anilist_id)..
        "&file="..d.docs[1].filename:urlEncode()..
        "&t="..tostring(d.docs[1].at)..
        "&token="..d.docs[1].tokenthumb).."\r\n" or "")..
        "by trace.moe",true
    else
        return "没搜到结果，请换一张完整的、没有裁剪过的动画视频截图",false
    end
end



return {--查动画
check = function (data)
    return (data.msg:find("^搜番") or data.msg:find("搜番$")) or
           (data.msg:find("%[CQ:image,file=") and searchFlag[tostring(data.qq)])
end,
run = function (data,sendMessage)
    if LuaEnvName ~= "828090839" then
        if getUseNum(data, "animeSearch") >= 10 then
            sendMessage(Utils.CQCode_At(data.qq).."今日你使用次数太多达到限制")
            return true
        end
    end
    if not checkCoolDownTime(data, "animeSearch", sendMessage) then
        return true
    end
    if data.msg:gsub(" ","") == "搜番" then
        searchFlag[tostring(data.qq)] = true
        sendMessage(Utils.CQCode_At(data.qq).."请发送要搜索的截图")
    else
        if searchFlag[tostring(data.qq)] then
            searchFlag[tostring(data.qq)] = nil
        end
        sys.taskInit(function ()
            local r,ok = animeSearch(data,sendMessage)
            sendMessage(Utils.CQCode_At(data.qq).."\r\n"..r)
            if ok then
                setCoolDownTime(data, "animeSearch", 10*60)
                setUseNum(data, "animeSearch")
            end
        end)
    end
    return true
end,
explain = function ()
    return "[CQ:emoji,id=128444]搜番 加 没裁剪过的视频截图"
end
}
