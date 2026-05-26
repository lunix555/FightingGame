package main

import (
	"compress/gzip"
	"io"
	"log"
	"mime"
	"net/http"
	"os"
	"path/filepath"
	"strings"
)

const webRoot = "/www"

func main() {
	mime.AddExtensionType(".wasm", "application/wasm")
	mime.AddExtensionType(".pck", "application/octet-stream")
	mime.AddExtensionType(".worklet.js", "application/javascript")

	http.HandleFunc("/", serveFile)
	log.Println("Serving Godot Web build on :80")
	log.Fatal(http.ListenAndServe(":80", nil))
}

func serveFile(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet && r.Method != http.MethodHead {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	cleanPath := filepath.Clean("/" + r.URL.Path)
	if cleanPath == "/" {
		cleanPath = "/index.html"
	}

	fullPath := filepath.Join(webRoot, cleanPath)
	if !strings.HasPrefix(fullPath, webRoot) {
		http.NotFound(w, r)
		return
	}

	info, err := os.Stat(fullPath)
	if err != nil || info.IsDir() {
		fullPath = filepath.Join(webRoot, "index.html")
		info, err = os.Stat(fullPath)
		if err != nil {
			http.NotFound(w, r)
			return
		}
	}

	ext := filepath.Ext(fullPath)
	if contentType := mime.TypeByExtension(ext); contentType != "" {
		w.Header().Set("Content-Type", contentType)
	}

	w.Header().Set("Cache-Control", "no-store, max-age=0")
	w.Header().Set("Pragma", "no-cache")

	file, err := os.Open(fullPath)
	if err != nil {
		http.NotFound(w, r)
		return
	}
	defer file.Close()

	if r.Method == http.MethodHead {
		w.Header().Set("Content-Length", stringInt(info.Size()))
		return
	}

	if acceptsGzip(r) {
		w.Header().Set("Content-Encoding", "gzip")
		w.Header().Add("Vary", "Accept-Encoding")
		gz := gzip.NewWriter(w)
		defer gz.Close()
		_, _ = io.Copy(gz, file)
		return
	}

	http.ServeContent(w, r, info.Name(), info.ModTime(), file)
}

func acceptsGzip(r *http.Request) bool {
	return strings.Contains(r.Header.Get("Accept-Encoding"), "gzip")
}

func stringInt(value int64) string {
	return strconvFormatInt(value)
}

func strconvFormatInt(value int64) string {
	if value == 0 {
		return "0"
	}
	var buf [20]byte
	i := len(buf)
	for value > 0 {
		i--
		buf[i] = byte('0' + value%10)
		value /= 10
	}
	return string(buf[i:])
}
