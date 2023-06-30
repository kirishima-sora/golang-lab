package main
import(
	"database/sql"
	"github.com/go-sql-driver/mysql"
    "github.com/aws/aws-lambda-go/lambda"
	"fmt"
	"crypto/tls"
)

func TiDBOperation() () {
	// TiDBへの接続
	mysql.RegisterTLSConfig("tidb", &tls.Config{
		MinVersion: tls.VersionTLS12,
		ServerName: "[TiDB Cloudで表示された接続コード]",
	})
	db, err := sql.Open("mysql", "[TiDB Cloudで表示された接続コード]")
	if err != nil {
		fmt.Println("DB connection error")
	}
	defer db.Close()

	// SQL実行
	rows, err := db.Query("SELECT * from PrefecturesTable")
	if err != nil {
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

func main() {
    lambda.Start(TiDBOperation)
}
