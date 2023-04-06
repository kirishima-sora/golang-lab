package main

import (
    "fmt"
	// Go用のLambdaプログラミングモデル
    "github.com/aws/aws-lambda-go/lambda"
)

type GetData struct {
    Weight float32 `json:"Weight"`
    Month int `json:"Month"`
}

type ReturnData struct {
    Answer string `json:"Answer"`
}

func CatCalAPI(event GetData) (ReturnData, error) {
	var per float32 = 30 * event.Weight + 70
	switch {
	case event.Month <= 4:
		var kcal float32 = per * 3.0
		return ReturnData{Answer: fmt.Sprintf("%.1f kcal", kcal)},nil
	case event.Month <= 6:
		kcal := per * 2.5
		return ReturnData{Answer: fmt.Sprintf("%.1f kcal", kcal)},nil
	case event.Month <= 12:
		kcal := per * 2.0
		return ReturnData{Answer: fmt.Sprintf("%.1f kcal", kcal)},nil
	case event.Month <= 95:
		kcal := per * 1.2
		return ReturnData{Answer: fmt.Sprintf("%.1f kcal", kcal)},nil
	case event.Month > 95 :
		kcal := per * 1.1
		return ReturnData{Answer: fmt.Sprintf("%.1f kcal", kcal)},nil
	default :
		return ReturnData{Answer: fmt.Sprintf("error")},nil
	}
}

func main() {
    lambda.Start(CatCalAPI)
}