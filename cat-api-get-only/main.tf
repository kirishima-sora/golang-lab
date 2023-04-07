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
    function_name = "CatAPI_Lambda"
    role          = aws_iam_role.iam_for_lambda.arn
    handler       = "api"
    source_code_hash = data.archive_file.lambda.output_base64sha256
    runtime = "go1.x"
}


#APIGatewayの作成
##APIの作成
resource aws_api_gateway_rest_api CatAPIGateway {
    name = "CatAPIGateway"
    endpoint_configuration {
        types = ["REGIONAL"]
    }
}

##リソースの作成
resource aws_api_gateway_resource CatAPIResource {
    rest_api_id = aws_api_gateway_rest_api.CatAPIGateway.id
    parent_id   = aws_api_gateway_rest_api.CatAPIGateway.root_resource_id
    path_part   = "resource"
}

##メソッドの作成
resource aws_api_gateway_method CatAPIMethod {
    rest_api_id   = aws_api_gateway_rest_api.CatAPIGateway.id
    resource_id   = aws_api_gateway_resource.CatAPIResource.id
    http_method   = "GET"
    authorization = "NONE"
    request_parameters = {
        "method.request.querystring.Weight" = true
        "method.request.querystring.Month" = true
    }
}

##リクエスト統合の作成
resource aws_api_gateway_integration CatAPIIntegration {
    rest_api_id          = aws_api_gateway_rest_api.CatAPIGateway.id
    resource_id          = aws_api_gateway_resource.CatAPIResource.id
    http_method          = aws_api_gateway_method.CatAPIMethod.http_method
    integration_http_method = "POST"
    type = "AWS"
    uri = aws_lambda_function.CatAPI_Lambda.invoke_arn
    request_templates =  {
        "application/json" = <<-EOT
        {
            "Weight": $input.params('Weight'),
            "Month": $input.params('Month')
        }
        EOT
    }
}

##レスポンスメソッドの作成
resource aws_api_gateway_method_response CatAPIResponse {
    rest_api_id = aws_api_gateway_rest_api.CatAPIGateway.id
    resource_id = aws_api_gateway_resource.CatAPIResource.id
    http_method = aws_api_gateway_method.CatAPIMethod.http_method
    status_code = "200"
    response_models = {
        "application/json" = "Empty"
    }
}

##レスポンス統合の作成
resource aws_api_gateway_integration_response CatAPIResponseIntegration {
    rest_api_id = aws_api_gateway_rest_api.CatAPIGateway.id
    resource_id = aws_api_gateway_resource.CatAPIResource.id
    http_method = aws_api_gateway_method.CatAPIMethod.http_method
    status_code = aws_api_gateway_method_response.CatAPIResponse.status_code
}


