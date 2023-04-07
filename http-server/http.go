package main

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
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

func main() {
	http.HandleFunc("/front", frontHandler)
	fmt.Println("Go Server Start")
	// リクエスト状態の開始
	log.Fatal(http.ListenAndServe(":8080", nil))
}

