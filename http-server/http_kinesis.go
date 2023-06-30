package main

import (
	"html/template"
	"log"
	"net/http"
	"os"
	"time"
)

func frontHandler(w http.ResponseWriter, r *http.Request) {
	// HTMLファイルのパース処理
	resp, err := template.ParseFiles("front.html")
	if err != nil {
		log.Printf("template error: %v", err)
	}	
	// 値の埋め込み＋エラー処理
	if err := resp.Execute(w, nil); err != nil {
		log.Printf("failed to execute template: %v", err)
	}
}

func accessLogHandler(next http.Handler, logger *log.Logger) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()

		next.ServeHTTP(w, r)

		logger.Printf("%s %s %v", r.Method, r.URL.Path, time.Since(start))
	})
}

func main() {
	// ログファイルのオープン
	logFile, err := os.OpenFile("../../var/log/golang-access.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Fatalf("failed to open log file: %v", err)
	}
	defer logFile.Close()
	// ログ出力先をファイルに設定
	logger := log.New(logFile, "", log.LstdFlags)

	http.HandleFunc("/front", frontHandler)
	// アクセスログを出力するようにミドルウェアを追加
	http.ListenAndServe(":8080", accessLogHandler(http.DefaultServeMux, logger))
	// リクエスト状態の開始
	log.Fatal(http.ListenAndServe(":8080", nil))
}

