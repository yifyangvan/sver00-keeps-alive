  #                                sver00_ct8  青龙面板自动脚本
  
  # 1、青龙面板 依赖管理--Linux 创建安装 四个依赖
       sshpss
       curl
       util-linux
       jq 
       
  # 2、青龙面板 环境变量 中添加  参数
       ACCOUNTS                   # 账户信息（必须要）
       WXPUSHER_TOKEN             # WXPUSHER Token（可选，非必要）
       WXPUSHER_USER_ID           # WXPUSHER 用户ID（可选，非必要）
       
       PUSHPLUS_TOKEN             # PUSHPLUS Token（可选，非必要）
       
       TG_BOT_TOKEN               # TG_BOT_TOKEN（可选，非必要）
       TG_CHAT_ID                 #TG_CHAT_ID（可选，非必要）

  # 3、账户信息，ACCOUNTS格式为
       user,password,server1:server2:server3|user1,password1,server4:server5:server6
       
  # 4、功能说明：
    1、SSH定时登录，并执行进程保活。
    2、进程内容：哪吒V1面板
                探针
                singbox
                sun-panel
                webssh
                alist
    3、消息通知，显示账号登录情况及进程执行明细，支持 WXPusher / PushPlus / Telegram 推送，可按需设置。
    4、推送通知敏感信息（账号）遮掩，只显示部分字符。
    5、多服务器地址自动轮值（需要在变量 ACCOUNTS 中设置），只要IP不全死，总有一个能登录。
