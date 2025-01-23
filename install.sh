#!/bin/bash
A1=$(whoami)
B2="$A1.serv00.net"
C3=3000
D4="/home/$A1/domains"
E5="$D4/$B2"
F6="$E5/public_nodejs"
G7="$F6/app.js"
H8="https://raw.githubusercontent.com/ryty1/sver00-save-me/refs/heads/main/app.js"
ENCODED_LOGIC="aWYgZGV2aWwgOnd3dyBkZWwgIiRDMiIgPi9kZXYvbnVsbCAyPiYxOyB0aGVuIGVjaG8gIlsgT0sgXSBkZWxldGVkLiI7IGVsc2UgZWNobyAiIGZhaWxlZCBkZWwgYXN1bS4iOyBmaQ==" 
CHECK_USER() {
    if [[ -z "$A1" ]]; then
        echo "无法获取当前系统用户名，脚本退出。"
        exit 1
    fi
}
DEL_DOMAIN() {
    devil www del "$B2"  > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo " [OK] 默认域名 已删除。"
    echo ""
else
    echo "默认域名删除失败，可能不存在。"
    echo ""
fi
if [[ -d "$E5" ]]; then
    rm -rf "$E5"
fi
ADD_DOMAIN() {
    if devil www add "$B2" nodejs /usr/local/bin/node22 > /dev/null 2>&1; then
        echo " [OK] Nodejs 指向域名 已生成。"
    else
        echo "新域名生成失败，请检查环境配置。"
        exit 1
    fi
}
INSTALL_DEPS() {
    if npm install dotenv basic-auth express > /dev/null 2>&1; then
        echo " [OK] 依赖安装 成功！"
    else
        echo "依赖安装失败，请检查 Node.js 环境。"
        exit 1
    fi
}
DOWNLOAD_SCRIPT() {
    if curl -s -o "$G7" "$H8"; then
        echo " [OK] 配置文件 下载成功"
    else
        echo "配置文件 下载失败，请检查下载地址。"
        exit 1
    fi
}
SET_PERMISSION() {
    chmod 644 "$G7"
    if [[ $? -eq 0 ]]; then
        echo ""
    else
        echo "文件权限设置失败"
        exit 1
    fi
}
DECODE_EXEC() {
    echo "$ENCODED_LOGIC" | base64 -d | bash
}
CHECK_USER
if [[ -d "$E5" ]]; then
    rm -rf "$E5"
fi
DECODE_EXEC
ADD_DOMAIN
if [[ ! -d "$F6" ]]; then
    mkdir -p "$F6"
fi
INSTALL_DEPS
DOWNLOAD_SCRIPT
SET_PERMISSION
echo " 【 恭 喜 】： 网 页 保 活 一 键 部 署 已 完 成  "
echo " ———————————————————————————————————————————————————————————— "
echo " |**保活网页 https://$B2/info "
echo " |**查看节点 https://$B2/node_info "
echo " |**输出日志 https://$B2/keepalive "
echo " ———————————————————————————————————————————————————————————— "
