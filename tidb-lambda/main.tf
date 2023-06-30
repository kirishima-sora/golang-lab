terraform {
    #AWSプロバイダーのバージョン指定
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.51.0"
        }
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
    name               = "Prefecture_Lambda_Role"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

#Lambdaへの配置ファイルのzip化
data archive_file lambda {
    type        = "zip"
    source_file = "tidb-operation"
    output_path = "handler.zip"
}
#Lambdaの作成
resource aws_lambda_function Prefecture_Lambda {
    filename      = "handler.zip"
    function_name = "TiDBOperation_Lambda"
    role          = aws_iam_role.iam_for_lambda.arn
    handler       = "tidb-operation"
    source_code_hash = data.archive_file.lambda.output_base64sha256
    runtime = "go1.x"
}
