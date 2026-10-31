cat << 'EOF' > /root/manage_docker.sh
#!/usr/bin/env bash
# =========================================================
# Docker & Docker Compose 综合管理脚本 (带快捷键 dk & 返回键支持)
# =========================================================

set -e

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
SKYBLUE="\033[36m"
PLAIN="\033[0m"

TARGET_SCRIPT="/usr/local/bin/manage_docker.sh"
SHORTCUT_LINK="/usr/local/bin/dk"

# 1. 强制 ROOT 权限检测
if [[ $EUID -ne 0 ]]; then
    clear
    echo -e "${RED}====================================================${PLAIN}"
    echo -e "${RED}                 【权限不足警告】                   ${PLAIN}"
    echo -e "${YELLOW}  本管理脚本涉及系统服务、内核网络与软件包底层配置，${PLAIN}"
    echo -e "${YELLOW}  必须在 ROOT 用户权限下运行！                      ${PLAIN}"
    echo -e "${RED}====================================================${PLAIN}"
    echo -e " 请切换为 root 用户后再执行本脚本："
    echo -e "  方法 1: 运行 ${SKYBLUE}sudo -i${PLAIN} 或 ${SKYBLUE}su -${PLAIN} 切换至 root 环境"
    echo -e "  方法 2: 使用 ${SKYBLUE}sudo bash $0${PLAIN} 临时提权执行"
    echo -e "${RED}====================================================${PLAIN}\n"
    exit 1
fi

# 2. 自动注册 dk 快捷指令到系统路径
setup_shortcut() {
    CURRENT_SCRIPT=$(readlink -f "$0" 2>/dev/null || echo "$0")

    # 如果当前脚本不在 /usr/local/bin 目录，自动复制进去
    if [[ "$CURRENT_SCRIPT" != "$TARGET_SCRIPT" && -f "$CURRENT_SCRIPT" ]]; then
        cp -f "$CURRENT_SCRIPT" "$TARGET_SCRIPT"
        chmod +x "$TARGET_SCRIPT"
    fi

    # 建立软链接 /usr/local/bin/dk
    if [[ ! -L "$SHORTCUT_LINK" || "$(readlink -f "$SHORTCUT_LINK")" != "$TARGET_SCRIPT" ]]; then
        ln -sf "$TARGET_SCRIPT" "$SHORTCUT_LINK" 2>/dev/null || true
        chmod +x "$SHORTCUT_LINK" 2>/dev/null || true
    fi
}

# 3. 通用返回键函数
back_to_menu() {
    echo ""
    read -rp "按回车键 [Enter] 返回主菜单..." dummy
}

# 检测系统包管理器
detect_os() {
    if grep -qs "ubuntu" /etc/os-release; then
        OS="ubuntu"
        PM="apt-get"
    elif grep -qs -E "debian|raspbian" /etc/os-release; then
        OS="debian"
        PM="apt-get"
    elif grep -qs -E "centos|almalinux|rocky|rhel" /etc/os-release; then
        OS="rhel"
        PM="dnf"
        command -v dnf >/dev/null 2>&1 || PM="yum"
    else
        echo -e "${RED}[错误] 未识别的 Linux 发行版，仅支持 Debian/Ubuntu/RHEL/CentOS 系列。${PLAIN}"
        exit 1
    fi
}

# 选项 1: 安装 Docker & Docker Compose
install_docker() {
    echo -e "${GREEN}>>> 正在准备基础依赖并安装 Docker 官方套件...${PLAIN}"
    detect_os

    if [ "$PM" = "apt-get" ]; then
        apt-get update -y
        apt-get install -y ca-certificates curl gnupg lsb-release
    else
        $PM install -y yum-utils device-mapper-persistent-data lvm2 curl
    fi

    echo -e "${YELLOW}>>> 正在通过官方源拉取并安装 Docker Engine & Compose Plugin...${PLAIN}"
    curl -fsSL https://get.docker.com | bash

    systemctl daemon-reload
    systemctl enable docker
    systemctl start docker

    echo -e "\n${GREEN}[成功] Docker 及 Docker Compose 安装完成！${PLAIN}"
    echo -e "${SKYBLUE}[提示] 以后在终端任意路径直接输入 ${GREEN}dk${SKYBLUE} 即可随时呼出此管理菜单。${PLAIN}"
    check_status_info
    back_to_menu
}

# 选项 2: 更新 Docker 核心组件
update_docker() {
    echo -e "${GREEN}>>> 正在检查并更新 Docker 核心组件...${PLAIN}"
    detect_os

    if [ "$PM" = "apt-get" ]; then
        apt-get update -y
        apt-get --only-upgrade install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    else
        $PM check-update docker-ce docker-ce-cli containerd.io docker-compose-plugin 2>/dev/null || true
        $PM update -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    fi

    systemctl restart docker
    echo -e "\n${GREEN}[成功] Docker 核心组件已升级至软件源最新版本！${PLAIN}"
    check_status_info
    back_to_menu
}

# 状态信息展示逻辑
check_status_info() {
    echo -e "\n${YELLOW}---------- [ 运行状态与版本 ] ----------${PLAIN}"
    if systemctl is-active --quiet docker; then
        echo -e "服务状态: ${GREEN}运行中 (Active)${PLAIN}"
        docker --version 2>/dev/null || echo -e "${RED}Docker 命令行未就绪${PLAIN}"
        docker compose version 2>/dev/null || echo -e "${RED}Docker Compose 插件未就绪${PLAIN}"
    else
        echo -e "服务状态: ${RED}未运行或未安装${PLAIN}"
    fi
    echo -e "${YELLOW}-----------------------------------------${PLAIN}"
}

# 选项 3: 查看状态并返回
check_status() {
    check_status_info
    back_to_menu
}

# 选项 4: 彻底清空卸载
uninstall_docker() {
    echo -e "${RED}====================================================${PLAIN}"
    echo -e "${RED}                 【高危卸载确认】                   ${PLAIN}"
    echo -e "${RED} 此操作将强制停止所有正在运行的容器，并彻底删除：  ${PLAIN}"
    echo -e "${RED} 1. 所有 Docker 镜像、数据卷、容器及自建网络        ${PLAIN}"
    echo -e "${RED} 2. Docker 底层软件包与系统配置目录 (/var/lib/docker)${PLAIN}"
    echo -e "${RED} 3. 系统全局快捷指令 dk 与管理脚本本体             ${PLAIN}"
    echo -e "${RED}====================================================${PLAIN}"
    read -rp "请确认是否继续彻底卸载? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}已取消卸载。${PLAIN}"
        back_to_menu
        return
    fi

    echo -e "\n${YELLOW}>>> 1. 强制停止并删除所有运行中的容器...${PLAIN}"
    if command -v docker >/dev/null 2>&1; then
        docker stop $(docker ps -aq) 2>/dev/null || true
        docker rm -f $(docker ps -aq) 2>/dev/null || true
    fi
    systemctl stop docker docker.socket containerd 2>/dev/null || true

    echo -e "${YELLOW}>>> 2. 彻底卸载核心软件包...${PLAIN}"
    detect_os
    if [ "$PM" = "apt-get" ]; then
        apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker.io docker-clean 2>/dev/null || true
        apt-get autoremove -y --purge 2>/dev/null || true
    else
        $PM remove -y docker \
            docker-client \
            docker-client-latest \
            docker-common \
            docker-latest \
            docker-latest-logrotate \
            docker-logrotate \
            docker-engine \
            docker-ce \
            docker-ce-cli \
            containerd.io \
            docker-compose-plugin 2>/dev/null || true
    fi

    echo -e "${YELLOW}>>> 3. 清理残留数据目录、网络配置与系统组...${PLAIN}"
    rm -rf /var/lib/docker
    rm -rf /var/lib/containerd
    rm -rf /etc/docker
    rm -rf /var/run/docker.sock
    rm -rf /etc/systemd/system/docker.service.d
    rm -f /etc/apparmor.d/docker
    groupdel docker 2>/dev/null || true
    systemctl daemon-reload

    echo -e "${YELLOW}>>> 4. 清理快捷指令与脚本本体...${PLAIN}"
    CURRENT_SCRIPT=$(readlink -f "$0" 2>/dev/null || echo "$0")
    rm -f "$SHORTCUT_LINK"
    rm -f "$TARGET_SCRIPT"
    rm -f "$CURRENT_SCRIPT"

    echo -e "${GREEN}[成功] Docker 环境、快捷指令 dk 及管理脚本已全部彻底清除！${PLAIN}\n"
    exit 0
}

# 主菜单循环
menu() {
    setup_shortcut
    while true; do
        clear
        echo -e "${GREEN}====================================================${PLAIN}"
        echo -e "${GREEN}         Docker & Docker Compose 管理工具           ${PLAIN}"
        echo -e "${GREEN}====================================================${PLAIN}"
        echo -e " ${SKYBLUE}快捷指令: 终端任意位置输入 ${YELLOW}dk${SKYBLUE} 即可随时呼出此菜单${PLAIN}"
        echo -e "${GREEN}----------------------------------------------------${PLAIN}"
        echo -e "  1. 一键安装 Docker 与 Docker Compose (官方最新源)"
        echo -e "  2. 一键更新 Docker 与 Compose 至最新版"
        echo -e "  3. 检查 Docker 运行状态与版本信息"
        echo -e "  4. ${RED}彻底清空卸载 Docker、快捷键 dk 及脚本 (净盘)${PLAIN}"
        echo -e "  0. 退出脚本"
        echo -e "${GREEN}====================================================${PLAIN}"
        read -rp "请输入选项 [0-4]: " choice

        case "$choice" in
            1) install_docker ;;
            2) update_docker ;;
            3) check_status ;;
            4) uninstall_docker ;;
            0) 
                echo -e "\n${YELLOW}已退出脚本。随时输入 dk 即可再次打开。${PLAIN}\n"
                exit 0 
                ;;
            *) 
                echo -e "${RED}[错误] 输入无效，请输入 0-4 之间的数字！${PLAIN}"
                sleep 1.5
                ;;
        esac
    done
}

menu
EOF
chmod +x /root/manage_docker.sh && /root/manage_docker.sh
