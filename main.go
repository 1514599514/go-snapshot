package main

import (
	"bytes"
	"os/exec"
	"runtime"

	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/middleware/cors"
)

func main() {
	app := fiber.New()

	app.Use(cors.New())

	app.Get("/", func(c fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})

	if runtime.GOOS == "windows" {
		app.Get("/snapshot", func(c fiber.Ctx) error {
			// 通过shell 调用安卓的adb命令，获取屏幕截图
			cmd := exec.Command("adb", "shell", "screencap", "-p")
			output, err := cmd.Output()
			if err != nil {
				return err
			}

			c.Set("Content-Type", "image/png")
			// 去除截图中的\r\n 换行符
			return c.Send(bytes.ReplaceAll(output, []byte{'\r', '\n'}, []byte{'\n'}))
		})
	} else { // android
		app.Get("/snapshot", func(c fiber.Ctx) error {
			// 通过shell 调用安卓命令，获取屏幕截图
			cmd := exec.Command("screencap", "-p")
			output, err := cmd.Output()
			if err != nil {
				return err
			}

			c.Set("Content-Type", "image/png")
			return c.Send(output)
		})
	}

	if runtime.GOOS == "Windows" {
		app.Listen("127.0.0.1:12138")
	} else {
		app.Listen(":12138")
	}
}
