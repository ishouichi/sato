#!/usr/bin/env node
import "source-map-support/register";
import * as cdk from "aws-cdk-lib";
import { SatoS3Stack } from "../lib/sato-s3-stack";

const app = new cdk.App();

// 共通のデプロイ環境設定（他の Stack からも再利用する想定）
const env: cdk.Environment = {
  account: process.env.CDK_DEFAULT_ACCOUNT,
  region: process.env.CDK_DEFAULT_REGION ?? "ap-northeast-1",
};

// フロントエンドのオリジン（CORS 用）
// 例: http://localhost:3000, https://example.com など
// CDK の -c allowedOrigins=["http://localhost:3000"] のような文字列入力にも対応する
type AllowedOriginsContext = string[] | string | undefined;
const allowedOriginsContext = app.node.tryGetContext(
  "allowedOrigins",
) as AllowedOriginsContext;

let allowedOrigins: string[];

if (Array.isArray(allowedOriginsContext)) {
  allowedOrigins = allowedOriginsContext;
} else if (
  typeof allowedOriginsContext === "string" &&
  allowedOriginsContext.trim().length > 0
) {
  try {
    const parsed = JSON.parse(allowedOriginsContext);
    allowedOrigins = Array.isArray(parsed)
      ? parsed
      : [allowedOriginsContext];
  } catch {
    allowedOrigins = allowedOriginsContext
      .split(",")
      .map((origin) => origin.trim())
      .filter((origin) => origin.length > 0);
  }
} else {
  allowedOrigins = ["http://localhost:3000"];
}

// 画像アップロード用 S3 バケット Stack
new SatoS3Stack(app, "SatoS3Stack", {
  env,
  allowedOrigins,
});

// 将来的に Stack を追加する場合は、ここに追記していく
// new AnotherStack(app, "AnotherStack", { env });
