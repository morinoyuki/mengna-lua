--导入需要的命名空间
--酷q库
import("com.papapoi.ReceiverMeow","Native.Csharp.App.Common")
import("Native.Csharp.Sdk","Native.Csharp.Sdk.Cqp.Enum")
--Utils接口
import("com.papapoi.ReceiverMeow","Native.Csharp.App.LuaEnv")
--HttpTool和HttpWebClient
import("Native.Csharp.Tool","Native.Csharp.Tool.Http")

import("System.Text")

--简化某些函数的语法
CQLog = AppData.CQLog
CQApi = AppData.CQApi
CQLog:Info("lua插件","加载新虚拟机"..LuaEnvName)
CQLog:Debug("lua插件","插件版本"..Utils.GetVersion())

--重写print函数，重定向到debug接口输出
function print(...)
    local r = {}
    for i=1,select('#', ...) do
        table.insert(r,tostring(select(i, ...)))
    end
    if #r == 0 then
        table.insert(r,"nil")
    end
    CQLog:Info("lua插件("..LuaEnvName..")",table.concat(r,"  "))
end

--加上需要require的路径
local rootPath = Utils.GetAsciiHex(CQApi.AppDirectory)
rootPath = rootPath:gsub("[%s%p]", ""):upper()
rootPath = rootPath:gsub("%x%x", function(c)
                                    return string.char(tonumber(c, 16))
                                end)
package.path = package.path..
";"..rootPath.."lua/require/?.lua;"..rootPath.."lua/events/?.lua;"

--加载字符串工具包
require("strings")

--重载几个可能影响中文目录的函数
local oldrequire = require
require = function (s)
    local s = Utils.GetAsciiHex(s):fromHex()
    return oldrequire(s)
end
local oldloadfile = loadfile
loadfile = function (s)
    local s = Utils.GetAsciiHex(s):fromHex()
    return oldloadfile(s)
end

--安全的，带解析结果返回的json解析函数
--返回值：数据,是否成功,错误信息
JSON = require("JSON")
function jsonDecode(s)
    local result, info = pcall(function(t) return JSON:decode(t) end, s)
    if result then
        return info, true
    else
        return {}, false, info
    end
end
function jsonEncode(t)
    local result, info = pcall(function(t) return JSON:encode(t) end, t)
    if result then
        return info, true
    else
        return "", false, info
    end
end

--唯一id
local idTemp = 0
function getId()
    idTemp = idTemp + 1--没必要判断是否溢出，溢出自动变成负数
    return idTemp
end

--封装一个异步的http get接口
function asyncHttpGet(url,para,timeout,cookie)
    local delayFlag = "http_get_"..os.time()..getId()--基本没有重复可能性的唯一标志
    sys.async("com.papapoi.ReceiverMeow","Native.Csharp.App.LuaEnv.Utils.HttpGet",
            {url,para or "",timeout or 5000,cookie or ""},
    function (r,d)
        sys.publish(delayFlag,r,d)
    end)
    local r1,r2,d = sys.waitUntil(delayFlag, timeout)
    return d or "",r2 and r1
end

--封装一个异步的http post接口
function asyncHttpPost(url,para,timeout,cookie,contentType)
    local delayFlag = "http_post_"..os.time()..getId()--基本没有重复可能性的唯一标志
    sys.async("com.papapoi.ReceiverMeow","Native.Csharp.App.LuaEnv.Utils.HttpPost",
            {url,para or "",timeout or 5000,cookie or "",
                contentType or "application/x-www-form-urlencoded"},
    function (r,d)
        sys.publish(delayFlag,r,d)
    end)
    local r1,r2,d = sys.waitUntil(delayFlag, timeout)
    return d or "",r2 and r1
end

--封装一个异步的http file上传接口
function asyncHttpUploadFile(url,para,path,timeout,cookie)
    local delayFlag = "http_post_"..os.time()..getId()--基本没有重复可能性的唯一标志
    sys.async("com.papapoi.ReceiverMeow","Native.Csharp.App.LuaEnv.Utils.HttpUploadFile",
            {url,para,path,timeout or 10000,cookie or ""},
    function (r,d)
        sys.publish(delayFlag,r,d)
    end)
    local r1,r2,d = sys.waitUntil(delayFlag, timeout)
    return d or "",r2 and r1
end

--封装一个异步的文件下载接口
function asyncFileDownload(url, path, maxSize, timeout)
    local delayFlag = "http_file_"..os.time()..getId()--基本没有重复可能性的唯一标志
    sys.async("com.papapoi.ReceiverMeow","Native.Csharp.App.LuaEnv.Utils.HttpDownload",
            {url, path, maxSize or 1024 * 1024 * 20, timeout or 5000},
    function (r,d)
        sys.publish(delayFlag,r,d)
    end)
    return sys.waitUntil(delayFlag, timeout)
end

imageCheck = require("imageCheck")

--根据url显示图片
function asyncImage(url,check)
    local adultData
    if check then
        adultData = imageCheck.remoteCheck(url)
        if adultData.isAdult >= 1 then
            return "检测到疑似H图 已隐藏"
        end
    end
    local file = "0LuaTemp"..os.time()..getId()..".luatemp"
    local sr,fr,dr = asyncFileDownload(url,"data/image/"..file,1024 * 1024 * 20,5000)
    if sr and fr and dr then
        if adultData and adultData.isAdult < 0 then
            adultData  = imageCheck.localCheck("data/image/"..file)
            if adultData.isAdult >= 1 then
                return "检测到疑似H图 已隐藏"
            end
        end
        return "[CQ:image,file="..file.."]"
    else
        return ""
    end
end

--加强随机数随机性
math.randomseed(tostring(os.time()):reverse():sub(1, 6))
function randNum(m, n)
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    if m and n then
        return math.random(m,n)
    end
    return math.random()
end
--获取随机字符串
function getRandomString(len)
    local str = "1234567890abcdefhijklmnopqrstuvwxyz"
    local ret = ""
    for i = 1, len do
        local rchr = math.random(1, string.len(str))
        ret = ret .. string.sub(str, rchr, rchr)
    end
    return ret
end

--分配各个事件
local events = {
    AppEnable = "AppEnable",--启动事件
    --FriendAdd = "",--好友已添加
    FriendAddRequest = "FriendAddRequest",--好友请求
    --GroupAddRequest = "",--加群请求
    --GroupAddInvite = "GroupAddInvite",--机器人被邀请进群
    GroupBanSpeak = "GroupBanSpeak",--群禁言
    GroupUnBanSpeak = "GroupUnBanSpeak",--群解除禁言
    GroupManageSet = "GroupManageSet",--设置管理
    GroupManageRemove = "GroupManageRemove",--取消管理
    -- GroupMemberExit = "GroupMemberLeave",--群成员减少，主动退--┐---→统一处理
    -- GroupMemberRemove = "GroupMemberLeave",--群成员减少，被踢--┘
    -- GroupMemberInvite = "GroupMemberJoin",--群成员增加，被邀请--┐---→统一处理
    -- GroupMemberPass = "GroupMemberJoin",--群成员增加，申请的----┘
    GroupMessage = "Message",--群消息-------┐---→统一处理
    PrivateMessage = "Message",--私聊消息---┘
    -- GroupFileUpload = "GroupFileUpload",--有人上传文件
    -- TcpServer = "ReceiveTcp",--收到tcp客户端发来的数据
}

--格式化秒
function secDateFormat(sec)
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

function setAutoRemove(data,id,time,text,rmng)
    if id < 0 or not time then return end
    if not rmng then rmng = 10 end
    local pendingRepeal = Utils.GetVar("autoRepeal")
    pendingRepeal = pendingRepeal ~= "" and jsonDecode(pendingRepeal) or {}
    table.insert(pendingRepeal,{
        id = id, --信息id
        time = os.time() + time, --将消息撤回的时间
        group = LuaEnvName ~= "private" and data.group or nil, --群号
        qq = data.qq, --QQ号码
        notice = text and true or false, --是否发送通知 （通知完毕后false）
        rmngSec = rmng, --剩余多少秒通知
        msg = text, --通知内容
    })
    local json = jsonEncode(pendingRepeal)
    Utils.SetVar("autoRepeal",json)
end

--设置cd
function setCoolDownTime(data,v,time)
    -- sendMessage((group and cqCode_At(qq) or "").."cd时间已设置为"..time.."S")
    XmlApi.Set(v,tostring(data.qq),tostring(os.time()+time))
end

--检查cd
function checkCoolDownTime(data,v,sendMessage)
    -- if LuaEnvName == "private" then return true end
    local cdTime = XmlApi.Get(v,tostring(data.qq))
    cdTime = cdTime == "" and 0 or tonumber(cdTime) or 0
    local cdOver = cdTime == 0 or (cdTime < os.time() and cdTime ~= 0)
    if not cdOver and sendMessage then
        sendMessage(Utils.CQCode_At(data.qq).."冷却中 还有"..secDateFormat(cdTime - os.time()))
    end
    return cdOver
end

for i,j in pairs(events) do
    local f
    local _,info = pcall(function() f = require(j) end)
    if f then
        sys.tiggerRegister(i,f)
        CQLog:Debug("lua插件",LuaEnvName.."注册事件"..i..","..j)
    else
        CQLog:Debug("lua插件",LuaEnvName.."注册事件失败"..i..","..(info or "错误信息为空"))
    end

end
