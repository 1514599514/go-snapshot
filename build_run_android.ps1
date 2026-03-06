# 某个命令运行错误就退出
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# 清空构建目录
if (Test-Path -Path .\build) {
    Remove-Item -Path .\build -Recurse
}

# Go 构建安卓可执行文件
$env:CGO_ENABLED = "1"  # 启用 CGO（安卓环境通常需要静态编译）
$env:CC = "C:\Users\admin\AppData\Local\Android\Sdk\ndk\27.3.13750724\toolchains\llvm\prebuilt\windows-x86_64\bin\aarch64-linux-android29-clang.cmd"
$env:CXX = "C:\Users\admin\AppData\Local\Android\Sdk\ndk\27.3.13750724\toolchains\llvm\prebuilt\windows-x86_64\bin\aarch64-linux-android29-clang++.cmd"

$env:CGO_LDFLAGS = "-L. -lltminicap"

go build -o .\build\go-snapshot .\main.go

# 打印编译完成
Write-Host "编译完成：.\build\go-snapshot"

Write-Host "开始推送"
adb push .\build\go-snapshot /data/local/tmp/

Write-Host "开始设置权限"
adb shell chmod 755 /data/local/tmp/go-snapshot

Write-Host "开始推送so文件"
adb push .\libc++_shared.so /data/local/tmp/
adb push .\libltminicap.so /data/local/tmp/
adb push .\minicap.so /data/local/tmp/

Write-Host "开始设置so文件权限"
adb shell chmod 755 /data/local/tmp/libc++_shared.so
adb shell chmod 755 /data/local/tmp/libltminicap.so
adb shell chmod 755 /data/local/tmp/minicap.so

Write-Host "开始运行（后台）"
adb shell "LD_LIBRARY_PATH=/data/local/tmp/ nohup /data/local/tmp/go-snapshot >/dev/null 2>&1 &"