# 某个命令运行错误就退出
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# 清空构建目录
if (Test-Path -Path .\build) {
    Remove-Item -Path .\build -Recurse
}

# Go 构建安卓可执行文件
$env:GOOS = "linux"
$env:GOARCH = "arm64"
$env:CGO_ENABLED = "0"  # 禁用 CGO（安卓环境通常需要静态编译）
go build -o .\build\go-snapshot .\main.go

# 打印编译完成
Write-Host "编译完成：.\build\go-snapshot"

Write-Host "开始推送"
adb push .\build\go-snapshot /data/local/tmp/

Write-Host "开始设置权限"
adb shell chmod 755 /data/local/tmp/go-snapshot

Write-Host "开始运行"
adb shell /data/local/tmp/go-snapshot
