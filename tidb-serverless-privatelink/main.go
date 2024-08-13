package main

import (
	"database/sql"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
)

func main() {
	// TiDB Cloudにて表示された接続コード
	db, err := sql.Open("mysql", "<接続情報>:4000)/GoECSTest")
	if err != nil {
		fmt.Println("err", err)
		fmt.Println("DB connection error")
	}
	defer db.Close()

	// SQL実行
	rows, err := db.Query("SELECT * from PrefecturesTable")
	if err != nil {
		fmt.Println("err", err)
		fmt.Println("SQL error")
	}
	defer rows.Close()

	fmt.Println("都道府県名, 県庁所在地, 地域")
	for rows.Next() {
		var prefecturename, prefecturalcapital, region string
		err := rows.Scan(&prefecturename, &prefecturalcapital, &region)
		if err != nil {
			fmt.Println("Scan error")
			return
		}
		fmt.Printf("%s, %s, %s\n", prefecturename, prefecturalcapital, region)
	}
}
