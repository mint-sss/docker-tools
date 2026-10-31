# docker-tools
Docker &amp; Docker Compose 综合管理脚本 (安装/更新/彻底卸载)
# Docker & Docker Compose 一键综合管理脚本 (`dk`)

一个轻量、纯净且功能完备的 Linux 运维管理脚本。支持一键安装 Docker 与 Docker Compose 官方最新套件、平滑更新、状态巡检、以及彻底物理净盘卸载，并内置全局快捷指令 `dk`。

---

## 🌟 特性一览

- **官方源直连**：对接 Docker 官方标准源，安装官方主推的 `docker compose` (Compose V2 插件)。
- **全架构与系统自适应**：原生兼容 Debian 全系（Debian 11/12、Ubuntu 20.04/22.04/24.04）及 RHEL 系列（CentOS、AlmaLinux、Rocky Linux）。
- **全局快捷指令**：执行过一次后自动注册系统软链接，在终端任何路径输入 `dk` 即可秒级呼出菜单。
- **平滑增量升级**：仅对 Docker 核心组件与 Compose 插件定向升级，不破坏宿主机其他软件包。
- **彻底物理净盘**：提供一键卸载功能，自动清理正在运行的容器、镜像、数据卷、网络、配置目录及脚本自身，不留垃圾。
- **常驻循环菜单**：内置操作返回键机制，执行完任务直接回车即可返回主界面，避免频繁重新启动脚本。

---

## 🚀 快速开始

### 方式 1：推荐方式（单行直接执行，不落地文件）

```bash
bash <(curl -fsSL [https://raw.githubusercontent.com/mint-sss/docker-tools/main/install_docker.sh](https://raw.githubusercontent.com/mint-sss/docker-tools/main/install_docker.sh))
