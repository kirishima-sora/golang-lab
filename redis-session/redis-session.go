package main

import (
	"context"
	"fmt"
	"math/rand"
	"time"
	"github.com/go-redis/redis/v8"
)

var redisClient *redis.Client

func main() {
	// Redisクライアントの初期化
	redisClient = redis.NewClient(&redis.Options{
		// Redisサーバーのエンドポイント
		Addr:"<Redis Endpoint>",
		// Redisサーバーのパスワード（今回は認証なし）
		Password:"",
		// Redisデータベースの選択
		DB:0,
	})

	// セッション情報の作成
	sessionID := generateSessionID()
	sessionData := "sample data"

	// Redisにセッション情報を保存する
	if err := redisClient.Set(context.Background(), sessionID, sessionData, 0).Err(); err != nil {
		panic(err)
	}

	fmt.Printf("Session created successfully: %s\n", sessionID)
}

// セッションIDをランダムに生成する関数
func generateSessionID() string {
	rand.Seed(time.Now().UnixNano())
	const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	const length = 16
	b := make([]byte, length)
	for i := range b {
		b[i] = charset[rand.Intn(len(charset))]
	}
	return string(b)
}
