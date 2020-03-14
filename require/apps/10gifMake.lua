local idList = {
    ["真香"] = 1,
    ["为所欲为"] = 6,
}
local oldList = {
    ["沙滩名场景"] = "yanji",
    ["黑人问号"] = "nick",
    ["伊莉雅"] = "iriya",
    ["血小板"] = "hataraku",
    ["梁非凡"] = "liangfeifan",
    ["我说的"] = "jesus",
    ["打工"] =  "dagong",
}
local function toJson(id,s)
    local ret = {["id"] = id,["fillings"] = {}}
    local i = 0
    string.gsub(s,'[^|]+',function (w)
        ret.fillings["sentence"..tostring(i)] = w
        i=i+1
    end)
    return jsonEncode(ret)
end

local function toOldJson(s)
    local ret = {}
    local i = 0
    string.gsub(s,'[^|]+',function (w)
        ret[tostring(i)] = w
        i=i+1
    end)
    return jsonEncode(ret)
end

local function getGif(message)
    local url,apiUrl,retMsg
    local name,text = message:match("表情生成%s*([^ ]+)%s+(.+)")
    if idList[name] then --新版
        url = "https://app.xuty.tk"
        apiUrl = url.."/memeet/api/v1/template/make"
        local postPara = toJson(idList[name],text)
        local html = asyncHttpPost(apiUrl,postPara,10000,"","application/json")
        local d,r,_ = jsonDecode(html)
        if r and d and d.ok then
            retMsg = asyncImage(url..d.body.url)
        end
    elseif oldList[name] then --旧版
        url = "https://sorry.xuty.tk"
        apiUrl = url.."/"..oldList[name].."/make"
        local postPara = toOldJson(text)
        local html = asyncHttpPost(apiUrl,postPara,10000,"","text/plain")
        if html and html:find("href=\"([^\"]+)\"") then
            retMsg = asyncImage(url..html:match("href=\"([^\"]+)\""))
        end
    else
        return name.." 不支持"  
    end
    if retMsg and retMsg ~= "" then
        return retMsg
    end
    return "表情读取失败 请重试"
end
local function make(message,sendMessage)
    if message:find("表情生成%s*[^ ]+%s+.+") then
        sendMessage("少女祈祷中....")
        local r = getGif(message)
        -- cqRepealMessage(id)
        return r
    end
    return [[目前支持:
真香-5句 为所欲为-9句 沙滩名场景-2句
黑人问号-2句 打工-6句 伊莉雅-4句
血小板-3句 梁非凡-3句 我说的-3句

格式模板:
表情生成 真香 我老森就是死|死外边|从这儿跳下去|也不会开后宫的|真香
表情生成 打工 找不到女朋友 肯定要推妹的|不推妹这一生有什么意义|那你不怕妹妹怀孕吗|这么刺激|推妹是一定要推的|这辈子都不可能不推妹的
表情生成 为所欲为 好啊|就算你是一流工程师|就算你出报告再完美|我叫你改报告你就要改|毕竟我是客户|客户了不起啊|sorry 客户真的了不起|以后叫他天天改报告|天天改 天天改
表情生成 伊莉雅 快乐肥宅水|你配吗|你~不~配~|我可去你的吧
表情生成 我说的 段坤我吃定了|耶稣也留不住他|我说的！
Engine by 表情锅 Script by 喵萌茶会组长:老森]]
end

return {--表情生成
check = function (data)
    return data.msg:find("表情生成") == 1
end,
run = function (data,sendMessage)
    -- local gifMake = require("app.gifMake")
    sys.taskInit(function ()
        sendMessage(make(data.msg,sendMessage))
    end)
    return true
end,
explain = function ()
    return "[CQ:emoji,id=128138]表情生成 生成表情包~"
end
}