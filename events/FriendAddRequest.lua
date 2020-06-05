return function (data)
    CQApi:SetFriendAddRequest(data.tag,CQResponseType.PASS,"")
    CQApi:SendPrivateMessage(data.qq,
[[具体功能可发送“帮助”来获取 后面加上数字实现翻页
如果想希望让我加入你群可联系我主人：454693264购买授权
价格为5/30天
]])
--     CQApi:SendPrivateMessage(data.qq,
-- [[具体功能可发送“帮助”来获取 后面加上数字实现翻页
-- 如果想希望让我加入你群可到：https://py.lolitc.com/links/E618D974
-- 购买授权卡号 因为服务器资源有限维护需要花钱所以收点钱
-- 卡号使用说明：
-- 私聊发送：#充值+卡号+[群号]
-- 示例：#充值XXXXX[8888888]
-- 即可完成充值 之后就可以邀请进群了
-- （时间可叠加）
-- PS：如果没回复可能是被腾讯屏蔽 实际已成功充值 不用管]])
end