local imageCheck = {}
local key = XmlApi.Get("settings","moderatecontent")
local userData = {}
local cache = {} --简易缓存
import('System')
local function cqSetGroupBanSpeak(g,q,t)
    local time = TimeSpan(0,0,t)
    CQApi:SetGroupMemberBanSpeak(g,q,time)
end
--格式化秒数
local function secDateFormat(sec)
    local date = {
        d = math.floor(sec / 60 / 60 / 24),
        h = math.floor(sec / 60 / 60 % 24),
        m = math.floor(sec / 60 % 60),
        s = sec % 60,
    }
    return (date.d ~= 0 and tostring(date.d).."天" or "")..
    (date.h ~= 0 and tostring(date.h).."小时" or "")..
    (date.m ~= 0 and tostring(date.m).."分钟" or "")..
    (date.s ~= 0 and tostring(date.s).."秒" or "")
end
--缓存初始化
-- local function cacheInitialize()
--     local tmp = apiGetVar("md5Cache")
--     cache = tmp ~= "" and jsonDecode(tmp) or {}
-- end
--按照MD5将table存入缓存
local function setCache(image,t)
    local md5 = image:match("%[CQ:image,file=(.-)%..-%]")
    cache[md5] = t
    -- local j = jsonEncode(cache)
    -- apiSetVar("md5Cache",j)
end
local function getCache(image)
    local imageMD5 = image:match("%[CQ:image,file=(.-)%..-%]")
    if imageMD5 and cache[imageMD5] then --检查缓存
        CQLog:Debug("涩图检查","使用缓存")
        return cache[imageMD5] --返回缓存
    end
    return nil
end
local function getAdultInfo(html)
    local ret = {isAdult = -1,json = nil}
    local j,r,_ = jsonDecode(html)
    if not r or not j or j.error_code ~= 0 then
        CQLog:Debug("涩图检查","数据读取失败 "..(j and j.error or ""))
        return ret
    end
    if j.rating_index == 3 and
    j.predictions.adult >= 85 then
        ret.isAdult = 2
        ret.json = j
    elseif j.rating_index == 3 then
        ret.isAdult = 1
        ret.json = j
    else
        ret.isAdult = 0
        ret.json = j
    end
    CQLog:Debug("涩图检查","涩情指数:"..tostring(j.predictions.adult))
    return ret
end
local function submitRemoteImage(url)
    local html = asyncHttpGet("https://www.moderatecontent.com/api/v2","key="..key.."&url="..url:urlEncode(),30000)
    return getAdultInfo(html)
end
local function submitLocalImage(path)
    if not path then
        return {isAdult = 0,json = nil}
    end
    local html = asyncHttpUploadFile("https://www.moderatecontent.com/api/v2?key="..key,"file",path,60000)
    return getAdultInfo(html)
end
--获取累加次数
local function getAccumulate(qq)
    if userData[tostring(qq)] and os.time() - userData[tostring(qq)].last < 24*60*60 then
        return userData[tostring(qq)].num
    end
    return 0
end
--累加次数
local function setAccumulate(group,qq,msg,time)
    local num = (userData[tostring(qq)] and os.time() - userData[tostring(qq)].last < 24*60*60) and
    userData[tostring(qq)].num + 1 or 1
    userData[tostring(qq)] = {
        last = os.time(),
        num = num,
        group = group,
        msg = msg,
        time = time
    }
end
--白名单
local function baseWhiteList()
    local whiteList = XmlApi.Get("whiteList","imageMD5")
    return whiteList ~= "" and whiteList:split(",") or {}
end
function imageCheck.setWhiteList(image)
    local imageMD5 = image:match("%[CQ:image,file=(.-)%..-%]")
    if not imageMD5 then
        return "Error"
    end
    local whiteList = baseWhiteList()
    local exists = false
    for i = 1, #whiteList do
        if whiteList[i] == imageMD5 then
            exists = true
            break
        end
    end
    if not exists then
        table.insert(whiteList, imageMD5)
        XmlApi.Set("whiteList","imageMD5",table.concat(whiteList, ","))
        return "Done"
    end
    return "Exists"
end
function imageCheck.removeWhiteList(image)
    local imageMD5 = image:match("%[CQ:image,file=(.-)%..-%]")
    if not imageMD5 then
        return false
    end
    local whiteList = baseWhiteList()
    if #whiteList ~= 0 then
        local i = 1
        while i <= #whiteList do
            if whiteList[i] == imageMD5 then
                table.remove(whiteList, i)
                XmlApi.Set("whiteList","imageMD5",table.concat(whiteList, ","))
                return "Done"
            else
                i = i+1
            end
        end
    end
    return "Error"
end
local function checkWhiteList(image)
    local imageMD5 = image:match("%[CQ:image,file=(.-)%..-%]")
    if not imageMD5 then
        return false
    end
    local whiteList = baseWhiteList()
    if #whiteList ~= 0 then
        for i = 1, #whiteList do
            if whiteList[i] == imageMD5 then
                CQLog:Debug("涩图检查","图片在白名单")
                return true
            end
        end
    end
    return false
end
--纯检查为日后功能扩展做准备
function imageCheck.check(message)
    local imagePath = Utils.GetImagePath(message)
    return submitLocalImage(imagePath)
end
--远程图片检查
function imageCheck.remoteCheck(url)
    return submitRemoteImage(url)
end
function imageCheck.submitVault(message)
    local r
    for imageCode in message:gmatch("(%[CQ:image,file=.-%])") do
        local pic = Utils.GetPictureInfo(imageCode)
        if pic.url then
            -- local pic = apiHttpUploadFile("https://img.vim-cn.com/","image", path,36000)
            local html = asyncHttpGet("https://www.moderatecontent.com/api/upload","url="..pic.url:urlEncode().."&vault=true&client=",10000)
            r = r..(html and html:find("Done") and "Done" or "Fail").."\r\n"
        end
    end
    return r
end
--误封检查并且清空累计次数 条件为十分钟内解禁
function imageCheck.falseBanCheck(group,qq)
    if userData[tostring(qq)] and userData[tostring(qq)].group == group and
    os.time() - userData[tostring(qq)].last < (userData[tostring(qq)].time < 10*60 and userData[tostring(qq)].time or 10*60) then
        CQApi:SendGroupMessage(group,Utils.CQCode_At(qq).."已在十分钟内解禁 图将自动白名单 恢复撤回内容\r\n"..userData[tostring(qq)].msg)
        local tmpText = userData[tostring(qq)].msg
        userData[tostring(qq)] = nil
        --遍历添加白名单
        for imageCode in tmpText:gmatch("(%[CQ:image,file=.-%])") do
            imageCheck.setWhiteList(imageCode)
        end
    end
end
--立刻检查并禁言
function imageCheck.checkAndBan(data,sendMessage,time)
    if not time then
        time = 10*60 --默认5分钟
    end
    -- local groupMember = cqGetMemberInfo(group,qq)
    
    for imageCode in data.msg:gmatch("(%[CQ:image,file=.-%])") do
        local picTab = Utils.GetPictureInfo(imageCode)
        if not checkWhiteList(imageCode) and --白名单
        picTab.width+picTab.height > 500 then
            local imageCache = getCache(imageCode)
            -- local imagePath
            -- if not imageCache then
            --     imagePath = apiGetImagePath(imageCode)
            --     imagePath = imagePath and apiGetAsciiHex(imagePath):fromHex() 
            -- end
            
            if imageCache or picTab.url then
                local dataTree = imageCache or submitRemoteImage(picTab.url)
                if not imageCache and dataTree and dataTree.isAdult >= 0 then setCache(imageCode,dataTree) end
                if dataTree.isAdult == 2 then
                    local num = getAccumulate(data.qq) --禁言次数
                    for i = 1, num do --时间计算
                        time = time*2*(i+1)
                    end
                    CQApi:RemoveMessage(data.id)
                    cqSetGroupBanSpeak(data.group,data.qq,time)
                    setAccumulate(data.group,data.qq,data.msg,time)
                    --马赛克处理
                    local bmp = Utils.GetBitmap(Utils.GetImagePath(imageCode))
                    if bmp then
                        bmp = Utils.SetMosaic(bmp,25)
                    end
                    sendMessage("[CQ:emoji,id=128286]检测到涩图\r\n"..
                    "机器视觉评分达到："..tostring(math.floor(dataTree.json.predictions.adult)).." 予以"..secDateFormat(time).."禁言处罚 若有误判请十分钟内找管理员\r\n"..
                    "为方便管理判断 提供进行马赛克处理后的图\r\n"..(bmp and "[CQ:image,file="..Utils.SaveImage(bmp,getRandomString(25)).."]" or "处理失败")..
                    "\r\nScript by 老森")
                    return true
                end
            end
        end
    end

    CQLog:Debug("涩图检查","pass")
    return false
end
-- cacheInitialize()--初始化缓存
return imageCheck