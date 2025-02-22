# Go 构建安卓可执行文件
$env:GOOS = "linux"
$env:GOARCH = "arm64"
$env:CGO_ENABLED = "0"  # 禁用 CGO（安卓环境通常需要静态编译）
go build -o go-snapshot .\main.go

adb push .\go-snapshot /data/local/tmp/
adb shell chmod 755 /data/local/tmp/go-snapshot
adb shell /data/local/tmp/go-snapshot
