1. 首先确保您的设备已经越狱，并已经安装 openssh
2. 在仓库根目录执行：

```shell
sh ./Scripts/generate_dylib.sh -v | grep '\[GrowingAnalytics\]'
```

该命令将创建 tweak 所需的文件并自动注入到您的越狱设备中，期间需要您手动输入您设备的 ip 和 root 密码(默认密码一般是 alpine)

3. （可选）使用 Choicy 插件进行注入控制，当前 GrowingToolsKit tweak 默认注入所有非系统应用

4. 接下来，使用 GrowingToolsKit 可对您手机安装的所有 app 进行 SDK 调试
