#!/bin/bash
  # 青龙面板 依赖管理--Linux 创建安装 sshpss / curl / util-linux / jq 四个依赖
  # 青龙面板 环境变量 中添加 ACCOUNTS / WXPUSHER_TOKEN / PUSHPLUS_TOKEN / WXPUSHER_USER_ID / TG_BOT_TOKEN / TG_CHAT_ID 参数

  # 设置环境变量
  # 账户信息，ACCOUNTS格式为 user,password,server1:server2:server3|user1,password1,server4:server5:server6

export ACCOUNTS="$ACCOUNTS"   # 账户信息（必须要）
WXPUSHER_TOKEN="$WXPUSHER_TOKEN"  # WXPUSHER 推送的 Token（可选，非必要）
WXPUSHER_USER_ID="$WXPUSHER_USER_ID"  # WXPUSHER 用户ID（可选，非必要）
PUSHPLUS_TOKEN="$PUSHPLUS_TOKEN"  # PUSHPLUS 推送的 Token（可选，非必要）
TG_BOT_TOKEN="$TG_BOT_TOKEN"  # TG 机器人Token（可选，非必要）
TG_CHAT_ID="$TG_CHAT_ID"  #TG 用户ID（可选，非必要）

WXPUSHER_URL="https://wxpusher.zjiecode.com/api/send/message"
PUSHPLUS_URL="http://www.pushplus.plus/send"
TELEGRAM_URL="https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage"

RESULT_SUMMARY="青龙自动进程内容：\n———————————————————————\n 哪吒V1面板 ‖ 探针 ‖ singbox ‖ sun-panel ‖ webssh ‖ alist \n———————————————————————\n"
# 发送 WXPusher 消息
send_wxpusher_message() {
  local title="$1"
  local content="$2"
  if [[ -z "$WXPUSHER_TOKEN" || -z "$WXPUSHER_USER_ID" ]]; then
    return
  fi
  curl -s -X POST "$WXPUSHER_URL" \
    -H "Content-Type: application/json" \
    -d "{
      \"appToken\": \"$WXPUSHER_TOKEN\",
      \"content\": \"$content\",
      \"title\": \"$title\",
      \"uids\": [\"$WXPUSHER_USER_ID\"]
    }" 
}

# 发送 PushPlus 消息
send_pushplus_message() {
  local title="$1"
  local content="$2"
  if [[ -z "$PUSHPLUS_TOKEN" || -z "$PUSHPLUS_URL" ]]; then
    return
  fi
  curl -s -X POST "$PUSHPLUS_URL" \
    -H "Content-Type: application/json" \
    -d "{
      \"token\": \"$PUSHPLUS_TOKEN\",
      \"title\": \"$title\",
      \"content\": \"<pre>$content</pre>\"
    }"
}
    
# 发送 Telegram 消息
send_telegram_message() {
  local title="$1 \n"
  local content="$2 \n"
  if [[ -z "$TG_BOT_TOKEN" || -z "$TG_CHAT_ID" ]]; then
    return
  fi
  curl -s -X POST "$TELEGRAM_URL" \
    -H "Content-Type: application/json" \
    -d "{
      \"chat_id\": \"$TG_CHAT_ID\",
      \"text\": \"$title \n $content\"
    }"
}

# 遮掩用户名
mask_username() {
  local username="$1"
  echo "****${username: -3}"
}

# 遮掩服务器地址
mask_server() {
  local server="$1"
  echo "$server" | cut -d '.' -f 1
}

LOGIN_TIMEOUT=20
IFS='|' read -r -a account_info <<< "$ACCOUNTS"
index=1

# 循环处理每个账户
echo "正在进行 {账号+密码+服务器} 拆解重组....  "
echo ""
for (( i=0; i<${#account_info[@]}; i++ )); do
  USERNAME=$(echo "${account_info[$i]}" | cut -d ',' -f 1)
  PASSWORD=$(echo "${account_info[$i]}" | cut -d ',' -f 2)
  SERVER_LIST=$(echo "${account_info[$i]}" | cut -d ',' -f 3)  # 获取服务器列表
  OPERATION_RESULT="❌"

  # 尝试所有服务器
  IFS=':' read -r -a servers <<< "$SERVER_LIST"  # 将多个服务器以':'分割
  for SERVER in "${servers[@]}"; do
    echo "尝试使用 [$USERNAME] 账号 登录 [$SERVER] 服务器  "
    
    # 这里增加了超时和详细的调试输出
    sshpass -p "$PASSWORD" timeout $LOGIN_TIMEOUT ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=QUIET -T "$USERNAME@$SERVER" exit
    SSH_EXIT_CODE=$?

    if [[ $SSH_EXIT_CODE -eq 0 ]]; then
      # 登录成功
      echo "恭喜这个逼，登录成功，命令执行开始：  "
      MASKED_USERNAME=$(mask_username "$USERNAME")
      MASKED_SERVER=$(mask_server "$SERVER")
      OPERATION_RESULT="✅"  # 登录成功即记录为 ✅
      RESULT_SUMMARY+="✅      $index. $MASKED_USERNAME       【 $MASKED_SERVER 】登录成功\n"
      
      # 执行远程操作
      sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=QUIET -T "$USERNAME@$SERVER" <<EOF
        echo "正在重启 面板 进程  "
        pkill -f "nezha-dashboard" >/dev/null 2>&1 || true
        if [ -d "/home/$USERNAME/nezha_app/dashboard" ]; then
          cd /home/$USERNAME/nezha_app/dashboard
          nohup ./nezha-dashboard >/dev/null 2>&1 &
          echo "-----------哪吒V1面板 重启成功。"
        else
          echo ">>>>>>>>>>>哪吒V1面板 未安装，跳过。"
        fi

        echo "正在重启 探针 进程  "
        pkill -f "nezha-agent" >/dev/null 2>&1 || true
        if [ -d "/home/$USERNAME/nezha_app/agent" ]; then
          cd /home/$USERNAME/nezha_app/agent
          nohup sh nezha-agent.sh >/dev/null 2>&1 &
          echo "-----------v1探针 重启成功。"
        else
          echo ">>>>>>>>>>>v1探针 未安装，跳过。"
        fi

        if [ -d "cd /home/$USERNAME/serv00-play/nezha" ]; then
          cd /home/$USERNAME/nezha_app/agent
          nohup ./nezha-agent  >/dev/null 2>&1 &
          echo "-----------v0探针 重启成功。"
        else
          echo ">>>>>>>>>>>v0探针 未安装，跳过。"
        fi

        echo "正在拉取 singbox 进程  "
        if [ -d "/home/$USERNAME/serv00-play/singbox" ]; then
          cd /home/$USERNAME/serv00-play/singbox
          nohup ./start.sh >/dev/null 2>&1 &
          echo "-----------singbox 拉取成功。"
        else
          echo ">>>>>>>>>>>singbox 未安装，跳过。"
        fi

        echo "正在重启 sun-panel 进程  "
        pkill -f "sun-panel" >/dev/null 2>&1 || true
        if [ -d "/home/$USERNAME/serv00-play/sunpanel" ]; then
          cd /home/$USERNAME/serv00-play/sunpanel
          nohup ./sun-panel >/dev/null 2>&1 &
          echo "-----------sun-panel 重启成功。"
        else
          echo ">>>>>>>>>>>sun-panel 未安装，跳过。"
        fi

        echo "正在拉取 webssh 进程  "
        if [ -d "/home/$USERNAME/serv00-play/webssh" ]; then
          cd /home/$USERNAME/serv00-play/webssh
          nohup ./wssh >/dev/null 2>&1 &
          echo "-----------webssh 拉取成功。"
        else
          echo ">>>>>>>>>>>webssh 未安装，跳过。"
        fi

        echo "正在重启 alist 进程  "
        pkill -f "alist server" >/dev/null 2>&1 || true
        if [ -d "/home/piaoc/serv00-play/alist" ]; then
          cd /home/piaoc/serv00-play/alist
          nohup ./alist server >/dev/null 2>&1 &
          echo "-----------alist 重启成功。"
        else
          echo ">>>>>>>>>>>alist 未安装，跳过。"
        fi

        ps -A >/dev/null 2>&1
        exit
EOF

      # 检查进程是否启动
      declare -A processes=(
        ["nezha-dashboard"]="哪吒面板"
        ["nezha-agent"]="探针"
        ["serv00sb"]="singbox"
        ["sun-panel"]="sun-panel"
        ["wssh"]="webssh"
        ["alist server"]="alist"
      )
      process_list=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=QUIET -T "$USERNAME@$SERVER" "ps -A")
      echo "正在进行进程对比......  "
      PROCESS_DETAILS=""

      for process in "${!processes[@]}"; do
        if echo "$process_list" | grep -q "$process"; then
          PROCESS_DETAILS+="    ${processes[$process]} |"
        fi
      done

      # 如果至少有一个进程启动，记录为成功
      if [[ -n "$PROCESS_DETAILS" ]]; then
        OPERATION_RESULT="✅"
      else
        OPERATION_RESULT="❌"
      fi
      echo "对比结束，已启动进程记录在结果中。  "
      echo "  "
      RESULT_SUMMARY+=" ------ $PROCESS_DETAILS 已启动\n"
      
      break  # 退出当前服务器循环
    else
      # 登录失败时打印错误信息
      echo "登录失败，尝试下一个服务器..."
    fi
  done

  # 如果所有服务器都登录失败
  if [[ "$OPERATION_RESULT" == "❌" ]]; then
    MASKED_USERNAME=$(mask_username "$USERNAME")
    RESULT_SUMMARY+="❌      $index. $MASKED_USERNAME       【 $MASKED_SERVER 】 登录失败\n"
  fi
  ((index++))
done

# 发送消息
echo "发送 WXPusher、PushPlus、Telegram 消息推送  "
send_wxpusher_message "Serv00自救判决书" "$RESULT_SUMMARY"
send_pushplus_message "Serv00自救判决书" "$RESULT_SUMMARY"
send_telegram_message "$RESULT_SUMMARY"
