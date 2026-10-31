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

### 方式 1：推荐单行直接执行（轻量、无需落地文件）

  ```bash
  bash <(curl -fsSL [https://raw.githubusercontent.com/mint-sss/docker-tools/main/install_docker.sh](https://raw.githubusercontent.com/mint-sss/docker-tools/main/install_docker.sh))
  ```

---

### 方式 2：经典下载保存并执行（wget 方式）

  ```bash
  wget -O install_docker.sh "[https://raw.githubusercontent.com/mint-sss/docker-tools/main/install_docker.sh](https://raw.githubusercontent.com/mint-sss/docker-tools/main/install_docker.sh)" && chmod +x install_docker.sh && ./install_docker.sh
  ```

---

### 方式 3：curl 下载保存并执行（备用方式）

* **GitHub 直连（海外服务器）：**
  ```bash
  curl -fsSL [https://raw.githubusercontent.com/mint-sss/docker-tools/main/install_docker.sh](https://raw.githubusercontent.com/mint-sss/docker-tools/main/install_docker.sh) -o install_docker.sh && chmod +x install_docker.sh && ./install_docker.sh
  ```

### 国内加速节点

* **国内加速节点：**
  ```bash
  curl -fsSL [https://ghproxy.net/https://raw.githubusercontent.com/mint-sss/docker-tools/main/install_docker.sh](https://ghproxy.net/https://raw.githubusercontent.com/mint-sss/docker-tools/main/install_docker.sh) -o install_docker.sh && chmod +x install_docker.sh && ./install_docker.sh
  ```
* **国内加速节点：**
  ```bash
  bash <(curl -fsSL [https://ghproxy.net/https://raw.githubusercontent.com/mint-sss/docker-tools/main/install_docker.sh](https://ghproxy.net/https://raw.githubusercontent.com/mint-sss/docker-tools/main/install_docker.sh))
  ```
  
* **国内加速节点：**
  ```bash
  wget -O install_docker.sh "[https://ghproxy.net/https://raw.githubusercontent.com/mint-sss/docker-tools/main/install_docker.sh](https://ghproxy.net/https://raw.githubusercontent.com/mint-sss/docker-tools/main/install_docker.sh)" && chmod +x install_docker.sh && ./install_docker.sh
  ```

---

## ⌨️ 快捷指令使用

脚本在首次运行后会自动在 `/usr/local/bin` 生成 `dk` 命令。此后无需记住脚本下载路径，在系统任意目录下输入：

```bash
dk
```

即可立即唤出如下交互菜单：

```text
====================================================
         Docker & Docker Compose 管理工具           
====================================================
 快捷指令: 终端任意位置输入 dk 即可随时呼出此菜单
----------------------------------------------------
  1. 一键安装 Docker 与 Docker Compose (官方最新源)
  2. 一键更新 Docker 与 Compose 至最新版
  3. 检查 Docker 运行状态与版本信息
  4. 彻底清空卸载 Docker、快捷键 dk 及脚本 (净盘)
  0. 退出脚本
====================================================
```

---

## 📋 功能说明

| 选项 | 名称 | 说明 |
| :---: | :--- | :--- |
| **1** | **安装套件** | 自动补全基础环境依赖，拉取 Docker 官方通用安装流并开启 systemd 开机自启。 |
| **2** | **一键更新** | 检索 Docker 软件源，仅升级 `docker-ce`、`containerd.io` 和 `docker-compose-plugin`。 |
| **3** | **状态巡检** | 快速查看 Docker 守护进程运行状态（Active/Inactive）以及当前 CLI 与 Compose 的版本。 |
| **4** | **彻底卸载** | 停止并强制删除所有容器、移除数据目录（`/var/lib/docker`、`/etc/docker` 等）、注销 `dk` 软链接并自删除。 |
| **0** | **退出管理** | 退出当前管理界面，返回系统 Bash。 |

---

## ⚙️ 运行环境要求

- **操作系统**：Debian 10/11/12、Ubuntu 20.04/22.04/24.04、CentOS 7/8/9、AlmaLinux、Rocky Linux
- **权限要求**：必须在 **ROOT** 用户权限下执行（支持 `sudo -i` 或 `su -` 切换环境）
- **基础依赖**：脚本会自动检查并补充 `curl`、`ca-certificates` 等基础组件

---

## ⚠️ 免责声明

选项 `4. 彻底清空卸载` 为高危操作，会清除本机**所有容器内正在运行的业务和未持久化至宿主机关联目录的数据**，请在执行前确认是否已做好必要的数据备份。
