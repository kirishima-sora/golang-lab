package main

import (
    "fmt"
    // "net/http"
	// "encoding/json"
	// Go用のLambdaプログラミングモデル
    "github.com/aws/aws-lambda-go/lambda"
    "github.com/aws/aws-lambda-go/events"
    "github.com/aws/aws-sdk-go/aws"
    "github.com/aws/aws-sdk-go/aws/session"
    "github.com/guregu/dynamo"
)

type Event struct {
    PrefectureName   string `json:"PrefectureName"`
    Region  string `json:"Region"`
    PrefecturalCapital string  `json:"PrefecturalCapital"`
}

// メソッドに応じて処理分岐
// func DBOperateAPI(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
func DBOperateAPI(req events.APIGatewayProxyRequest) () {
    db := dynamo.New(session.New(), &aws.Config{Region: aws.String("ap-northeast-1")})
    table := db.Table("PrefecturesTable")
    prefecture_name := req.QueryStringParameters["PrefectureName"]
    prefecture_region := req.QueryStringParameters["Region"]
    var result Event
    // resultをprintfすると⇒{Hokkaido Hokkaido Sapporo}
    err := table.Get("PrefectureName", prefecture_name).Range("Region", dynamo.Equal, prefecture_region).One(&result)

    // resultsをprintfすると⇒[{Hokkaido Hokkaido Sapporo}]
    // table.Get("PrefectureName", prefecture_name).All(&results)

    // switch req.HTTPMethod {
    // case "GET":
	// 	username := req.QueryStringParameters["UserName"]
    //     var result Event
    //     err := table.Get("UserName", username).One(&result)
    // // case "POST":
    // default:
    //     return clientError(http.StatusMethodNotAllowed)
    // }
}

func main() {
    lambda.Start(DBOperateAPI)
}