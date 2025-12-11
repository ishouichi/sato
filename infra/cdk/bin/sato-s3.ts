#!/usr/bin/env node
import "source-map-support/register";
import * as cdk from "aws-cdk-lib";
import { SatoS3Stack } from "../lib/sato-s3-stack";

const app = new cdk.App();

// 環境変数または CDK コンテキストから環境・リージョンを取得（なければデフォルト）
const env: cdk.Environment = {
  account: process.env.CDK_DEFAULT_ACCOUNT,
  region: process.env.CDK_DEFAULT_REGION ?? "ap-northeast-1",
};

// フロントエンドのオリジン（CORS 用）
// 例: http://localhost:3000, https://example.com など
const allowedOrigins =
  (app.node.tryGetContext("allowedOrigins") as string[]) ?? [
    "http://localhost:3000",
  ];

new SatoS3Stack(app, "SatoS3Stack", {
  env,
  allowedOrigins,
});



