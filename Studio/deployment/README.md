# Dora Studio Linux 部署包

包内包含纯 Go Linux 服务端、Studio Web 静态资源、Agent 支持包、专用 Agent Web 引擎、独立游戏 Player，以及 systemd 运维脚本。三个 HTTPS 来源由同一进程监听，但权限和页面处理器保持隔离。

## 安装

```bash
tar -xzf dora-studio-*-linux-amd64.tar.gz
cd dora-studio-*-linux-amd64
sudo ./studio-linux.sh install
sudoedit /etc/dora-studio/studio.env
sudo install -o root -g dora-studio -m 0640 fullchain.pem /etc/dora-studio/tls/fullchain.pem
sudo install -o root -g dora-studio -m 0640 privkey.pem /etc/dora-studio/tls/privkey.pem
sudo ./studio-linux.sh check
sudo ./studio-linux.sh start
```

前端构建时已经写入打包命令指定的 Studio、Agent Host 和 Player 来源。若域名或端口改变，必须重新打包，不能只修改服务器环境文件。

常用命令：

```bash
sudo ./studio-linux.sh status
sudo ./studio-linux.sh restart
sudo ./studio-linux.sh logs
sudo ./studio-linux.sh stop
```

`install` 不会自动启动服务，也不会覆盖已有 `/etc/dora-studio/studio.env`。首次安装会生成稳定的 32 字节数据库加密密钥；已有数据库迁移时必须保留原密钥。
