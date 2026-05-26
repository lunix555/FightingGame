# Docker 游戏资源包

这个 Docker 包把 Godot Web 导出的 `exports/web` 作为静态站点托管。

最终镜像使用 `scratch`，只包含一个很小的 Go 静态文件服务器和 `exports/web`，不会把 Go SDK、工程源码、FBX 源文件、下载缓存、测试导出目录放进最终镜像。

## 构建

```powershell
docker build -t godot-fighting-web:latest .
```

## 本地运行

```powershell
docker run --rm -p 8080:80 godot-fighting-web:latest
```

然后打开：

```text
http://127.0.0.1:8080/
```

## 查看镜像大小

```powershell
docker images godot-fighting-web:latest
```

## 重新导出后再打包

先用 Godot 导出到 `exports/web/index.html`，再重新执行 `docker build`。

当前 Dockerfile 只复制 `exports/web`，不会把工程源码、FBX 源文件、下载缓存、测试导出目录一起放进镜像。
