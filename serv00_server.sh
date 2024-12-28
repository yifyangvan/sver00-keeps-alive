#!/bin/bash
WXPUSHER_TOKEN="$WXPUSHER_TOKEN"
PUSHPLUS_TOKEN="$PUSHPLUS_TOKEN"
TG_BOT_TOKEN="$TG_BOT_TOKEN"
TG_CHAT_ID="$TG_CHAT_ID"
WXPUSHER_URL="https://wxpusher.zjiecode.com/api/send/message"
PUSHPLUS_URL="http://www.pushplus.plus/send"
TELEGRAM_URL="https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage"
RESULT_SUMMARY="青龙自动进程内容：\n———————————————————————\n"
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
    }" >/dev/null 2>&1 &
}
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
    }" >/dev/null 2>&1 &
}
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
    }" >/dev/null 2>&1 &
}
mask_username() {
  local username="$1"
  echo "****${username: -3}"
}
mask_server() {
  local server="$1"
  echo "$server" | cut -d '.' -f 1
}
mask_server_out() {
  local servers="$1"
  first_server=$(echo "$servers" | cut -d ':' -f 1 | cut -d ',' -f 1)  
  echo "$first_server" | cut -d '.' -f 1
}
manage_services() {
  local USERNAME="$1"
  local PASSWORD="$2"
  local SERVER="$3"
  $CMD <<EOF
    echo "——————————————————————————————————————————————————"
if [ -d "/home/$USERNAME/nezha_app/dashboard" ]; then
    pkill -f "nezha-dashboard" >/dev/null 2>&1 || true
    cd /home/$USERNAME/nezha_app/dashboard && nohup ./nezha-dashboard >/dev/null 2>&1 & 
    echo "✅ -------- 哪吒V1面板"
fi
if [ -d "/home/$USERNAME/nezha_app/agent" ]; then
    pkill -f "nezha-agent" >/dev/null 2>&1 || true
    cd /home/$USERNAME/nezha_app/agent && nohup sh nezha-agent.sh >/dev/null 2>&1 &
    echo "✅ -------- V1探针"
fi
if [ -d "/home/$USERNAME/serv00-play/nezha" ] && [ -f "/home/$USERNAME/serv00-play/nezha/nezha.json" ]; then
    pkill -f "nezha-agent" >/dev/null 2>&1 || true
    cd /home/$USERNAME/serv00-play/nezha
    nohup ./nezha-agent --report-delay 4 --disable-auto-update --disable-force-update --delay=2 \
        $( [[ "$(jq -r '.tls' nezha.json 2>/dev/null)" == "y" ]] && echo "--tls" ) \
        -s "$(jq -r '.nezha_domain' nezha.json 2>/dev/null):$(jq -r '.nezha_port' nezha.json 2>/dev/null)" \
        -p "$(jq -r '.nezha_pwd' nezha.json 2>/dev/null)" >/dev/null 2>&1 &
    echo "✅ -------- V0探针"
fi
if [ -d "/home/$USERNAME/serv00-play/singbox" ]; then
    cd /home/$USERNAME/serv00-play/singbox && nohup ./start.sh >/dev/null 2>&1 &
    echo "✅ -------- singbox"
fi
if [ -d "/home/$USERNAME/serv00-play/sunpanel" ]; then
    pkill -f "sun-panel" >/dev/null 2>&1 || true
    cd /home/$USERNAME/serv00-play/sunpanel && nohup ./sun-panel >/dev/null 2>&1 &
    echo "✅ -------- sun-panel"
fi
if [ -d "/home/$USERNAME/serv00-play/webssh" ] && [ -f "/home/$USERNAME/serv00-play/webssh/config.json" ]; then
    cd /home/$USERNAME/serv00-play/webssh
    nohup ./wssh --port=$(jq -r ".port" config.json 2>/dev/null) --fbidhttp=False --xheaders=False --encoding="utf-8" --delay=5 >/dev/null 2>&1 &
    echo "✅ -------- webssh"
fi
if [ -d "/home/piaoc/serv00-play/alist" ]; then
    pkill -f "alist server" >/dev/null 2>&1 || true
    cd /home/piaoc/serv00-play/alist && nohup ./alist server >/dev/null 2>&1 &
    echo "✅ -------- alist"
fi
    echo "——————————————————————————————————————————————————"
EOF
}
LOGIN_TIMEOUT=10
index=1
echo "正在进行 {账号+密码+服务器} 拆解重组....  "
echo ""
IFS='|' read -r -a account_info <<< "$ACCOUNTS"
for (( i=0; i<${#account_info[@]}; i++ )); do
  IFS=',' read -r USERNAME PASSWORD SERVER_LIST <<< "${account_info[$i]}"
  OPERATION_RESULT="❌"
  IFS=':' read -r -a servers <<< "$SERVER_LIST"
  for SERVER in "${servers[@]}"; do
    echo "尝试使用 [$USERNAME] 账号 登录 [$SERVER] 服务器..."
    CMD="sshpass -p "$PASSWORD" timeout $LOGIN_TIMEOUT ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=QUIET -T "$USERNAME@$SERVER""
    $CMD exit
    SSH_EXIT_CODE=$?
    if [[ $SSH_EXIT_CODE -eq 0 ]]; then
      echo "恭喜这个逼，登录成功！开始执行命令："
      MASKED_USERNAME=$(mask_username "$USERNAME")
      MASKED_SERVER=$(mask_server "$SERVER")
      OPERATION_RESULT="✅"
      RESULT_SUMMARY+="✅      $index. $MASKED_USERNAME       【 $MASKED_SERVER 】   登录成功\n"
      manage_services "$USERNAME" "$PASSWORD" "$SERVER"
      process_list=$($CMD "ps -A")
      echo "生成进程结果明细汇总到推送消息中.....  "
      echo "  "
      PROCESS_DETAILS=""
      declare -A processes=(
        ["nezha-dashboard"]="哪吒面板"
        ["nezha-agent"]="探针"
        ["serv00sb"]="singbox"
        ["sun-panel"]="sun-panel"
        ["wssh"]="webssh"
        ["alist server"]="alist"
      )
      for process in "${!processes[@]}"; do
        if echo "$process_list" | grep -q "$process"; then
          PROCESS_DETAILS+="    ${processes[$process]} |"
        fi
      done
      if [[ -n "$PROCESS_DETAILS" ]]; then
        OPERATION_RESULT="✅"
      else
        OPERATION_RESULT="❌"
      fi
      RESULT_SUMMARY+=" ------ $PROCESS_DETAILS 已启动\n"
      break
    else
      echo "登录失败，尝试下一个服务器..."
    fi
  done
  if [[ "$OPERATION_RESULT" == "❌" ]]; then
    MASKED_USERNAME=$(mask_username "$USERNAME")
    MASKED_SERVER_OUT=$(mask_server_out "$SERVER_LIST")
    RESULT_SUMMARY+="❌      $index. $MASKED_USERNAME       【 $MASKED_SERVER_OUT 】   登录失败\n"
  fi
  ((index++))
done
echo "发送 WXPusher、PushPlus、Telegram 消息推送  "
send_wxpusher_message "Serv00保活通知" "$RESULT_SUMMARY"
send_pushplus_message "Serv00保活通知" "$RESULT_SUMMARY"
send_telegram_message "$RESULT_SUMMARY"
