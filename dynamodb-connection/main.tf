terraform {
    #AWSプロバイダーのバージョン指定
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.51.0"
        }
    }
    #tfstateファイルをS3に配置する(配置先のS3は事前に作成済み)
    backend s3 {
        bucket = "sora-tfstate-bucket"
        region = "ap-northeast-1"
        key    = "tf-test.tfstate"
    }
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
    name               = "CatAPI_Lambda_Role"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

#Lambdaへの配置ファイルのzip化
data archive_file lambda {
    type        = "zip"
    source_file = "api"
    output_path = "handler.zip"
}

#Lambdaの作成
resource aws_lambda_function CatAPI_Lambda {
    filename      = "handler.zip"
    function_name = "DynamoDBAPI_Lambda"
    role          = aws_iam_role.iam_for_lambda.arn
    handler       = "dynamodbapi"
    source_code_hash = data.archive_file.lambda.output_base64sha256
    runtime = "go1.x"
}

#DynamoDBの作成



