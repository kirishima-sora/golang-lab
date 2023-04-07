terraform {
    #AWSプロバイダーのバージョン指定
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.51.0"
        }
    }
    #tfstateファイルをS3に配置する(配置先のS3は事前に作成済み)
    # backend s3 {
    #     bucket = "sora-tfstate-bucket"
    #     region = "ap-northeast-1"
    #     key    = "tf-dynamo-test.tfstate"
    # }
}

#AWSプロバイダーの定義
provider aws {
    region = "ap-northeast-1"
}

#Lambda用IAMロールの信頼関係の定義
data aws_iam_policy_document assume_role {
    statement {
        effect = "Allow"
        principals {
            type = "Service"
            identifiers = ["lambda.amazonaws.com"]
        }
        actions = ["sts:AssumeRole"]
    }
}

#Lambda用IAMロールの作成
resource aws_iam_role iam_for_lambda {
    name               = "Prefecture_Lambda_Role"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
    # dynamodbへのアクセス権限を振る必要がある
}


#Lambdaへの配置ファイルのzip化
data archive_file lambda {
    type        = "zip"
    source_file = "dynamodbapi"
    output_path = "handler.zip"
}

#Lambdaの作成
resource aws_lambda_function Prefecture_Lambda {
    filename      = "handler.zip"
    function_name = "DynamoDBAPI_Lambda"
    role          = aws_iam_role.iam_for_lambda.arn
    handler       = "dynamodbapi"
    source_code_hash = data.archive_file.lambda.output_base64sha256
    runtime = "go1.x"
}

#DynamoDBの作成
resource aws_dynamodb_table prefecture_table {
    name           = "PrefecturesTable"
    billing_mode   = "PAY_PER_REQUEST"
    hash_key       = "PrefectureName"
    range_key      = "Region"
    attribute {
        name = "PrefectureName"
        type = "S"
    }
    attribute {
        name = "Region"
        type = "S"
    }
}

locals {
    csv_data = file("prefectual.csv")
    dataset = csvdecode(local.csv_data)
}

resource aws_dynamodb_table_item table_item {
    for_each = { for record in local.dataset : record.prefecturename => record }
    table_name = aws_dynamodb_table.prefecture_table.name
    hash_key   = aws_dynamodb_table.prefecture_table.hash_key
    range_key  = aws_dynamodb_table.prefecture_table.range_key
    item = <<ITEM
    {
        "PrefectureName": {"S": "${each.value.prefecturename}"},
        "PrefecturalCapital": {"S": "${each.value.prefecturalcapital}"},
        "Region": {"S": "${each.value.region}"}
    }
    ITEM
}

