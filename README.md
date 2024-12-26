  ###                                sver00_ct8  青龙面板自动脚本
  
  ## 1、青龙面板 依赖管理--Linux 创建安装 四个依赖
       sshpss  /  curl  /  util-linux  /  jq 
       
  ## 2、青龙面板 环境变量 中添加  参数
      1>  ACCOUNTS                   # 账户信息（必须要）
      2>  WXPUSHER_TOKEN             # WXPUSHER Token   （ 2|3为一组，单设无效，非必要 ）
      3>  WXPUSHER_USER_ID           # WXPUSHER 用户ID  （ 2|3为一组，单设无效，非必要 ）
      4>  PUSHPLUS_TOKEN             # PUSHPLUS Token   （可选，非必要）
      5>  TG_BOT_TOKEN               # TG_BOT_TOKEN     （ 5|6为一组，单设无效，非必要 ）
      6>  TG_CHAT_ID                 #TG_CHAT_ID        （5|6为一组，单设无效，非必要）

  ## 3、账户信息，ACCOUNTS格式为
       user,password,server1:server2:server3|user1,password1,server4:server5:server6
       
  ## 4、功能说明：
1、SSH定时登录，并执行进程保活。

2、进程内容：
- 哪吒V1面板 / V1探针        [适配vfhky佬安装脚本](https://github.com/vfhky/serv00_ct8_nezha)
- V0探针                    [适配frankiejun佬安装脚本](https://github.com/frankiejun/serv00-play)
- singbox                   [适配frankiejun佬安装脚本](https://github.com/frankiejun/serv00-play)
- sun-panel                 [适配frankiejun佬安装脚本](https://github.com/frankiejun/serv00-play)
- webssh                    [适配frankiejun佬安装脚本](https://github.com/frankiejun/serv00-play)
- alist                     [适配frankiejun佬安装脚本](https://github.com/frankiejun/serv00-play)

3、消息通知，显示账号登录情况及进程执行明细，支持 WXPusher / PushPlus / Telegram 推送，可按需设置。

4、推送通知敏感信息（账号）遮掩，只显示部分字符。

5、多服务器地址自动轮值（需要在变量 ACCOUNTS 中设置），只要IP不全死，总有一个能登录。

  ## 5、效果展示：
<img src="images/1.png" width="200" />
<img src="images/2.png" width="200" />
<img src="images/3.png" width="200" />


