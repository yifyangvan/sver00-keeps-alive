#!/bin/bash
U1=$(whoami)
if [[ -z "$U1" ]]; then
    echo "未能获取当前用户名，退出。"
    exit 1
fi
D1="$U1.serv00.net"
P1=3000
R1="/home/$U1/domains"
D2="$R1/$D1"
N1="$D2/public_nodejs"
F1="$N1/app.js"
L1="https://raw.githubusercontent.com/ryty1/sver00-save-me/refs/heads/main/app.js"

echo " ———————————————————————————————————————————————————————————— "
devil www del "$D1" > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo " [OK] 已成功删除默认域名。"
    echo ""
else
    echo "删除默认域名失败，可能不存在。"
    echo ""
fi

if [[ -d "$D2" ]]; then
    rm -rf "$D2"
fi

if devil www add "$D1" nodejs /usr/local/bin/node22 > /dev/null 2>&1; then
    echo " [OK] Nodejs 域名已成功生成。"
    echo ""
else
    echo "域名生成失败，请检查环境设置。"
    echo ""
    exit 1
fi

if [[ ! -d "$N1" ]]; then
    mkdir -p "$N1"
fi

if npm install dotenv basic-auth express > /dev/null 2>&1; then
    echo " [OK] 所有依赖已成功安装！"
    echo ""
else
    echo "依赖安装失败，请检查 Node.js 环境。"
    exit 1
fi

if curl -s -o "$F1" "$L1"; then
    echo " [OK] 配置文件已成功下载。"
else
    echo "配置文件下载失败，请检查 URL。"
    exit 1
fi

chmod 644 "$F1"
if [[ $? -ne 0 ]]; then
    echo ""
    else
    echo "文件权限更改失败，退出。"
    exit 1
fi

echo " 【 恭 喜 】： 网 页 保 活 一 键 部 署 已 完 成  "
echo " ———————————————————————————————————————————————————————————— "
echo " |**保活网页 https://$D1/info "
echo ""
echo " |**查看节点 https://$D1/node_info "
echo ""
echo " |**输出日志 https://$D1/keepalive "
echo " ———————————————————————————————————————————————————————————— "
echo ""