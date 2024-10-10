package main

import (
	"database/sql"
	"log"
	"net/http"
	"crypto/tls"
	"github.com/go-sql-driver/mysql"
)

// 起動するポート
const port = "8080"

func helloHandler(w http.ResponseWriter, r *http.Request) {
	// データベース接続
	// TiDB Cloudにて表示されたコード（★公開時は書き換える）
	mysql.RegisterTLSConfig("tidb", &tls.Config{
		MinVersion: tls.VersionTLS12,
		ServerName: "{TiDBホスト名}",
	})
	db, err := sql.Open("mysql", "{TiDB接続情報}:4000)/{db名}?tls=tidb")
	// エラー処理
	if err != nil {
		http.Error(w, "Failed to connect to database", http.StatusInternalServerError)
		log.Printf("Failed to connect to database: %v", err)
		return
	}
	// 関数終了時にコネクション切断
	defer db.Close()

	// クエリ実行
	rows, err := db.Query("SHOW DATABASES")
	if err != nil {
		http.Error(w, "Failed to execute query", http.StatusInternalServerError)
		log.Printf("Failed to execute query: %v", err)
		return
	}
	defer rows.Close()

	// ログ出力
	for rows.Next() {
		var dbName string
		if err := rows.Scan(&dbName); err != nil {
			log.Printf("Failed to scan row: %v", err)
			return
		}
		log.Printf("%s", dbName)
	}

	if err = rows.Err(); err != nil {
		log.Printf("Error occurred during rows iteration: %v", err)
		return
	}
}

func main() {
	// ハンドラ関数を設定
	http.HandleFunc("/locust-test", helloHandler)
	// ログ出力
	log.Printf("Server is running on port %s\n", port)
	// サーバの起動
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
