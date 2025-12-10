import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as s3 from "aws-cdk-lib/aws-s3";
import * as iam from "aws-cdk-lib/aws-iam";
import { HerokuAppIam, DevAppIam } from "./heroku-app-iam";

export interface SatoS3StackProps extends cdk.StackProps {
  /**
   * ブラウザから直接 S3 にアクセスさせるために許可するオリジン
   * 例: ["http://localhost:3000", "https://example.com"]
   */
  allowedOrigins: string[];
}

export class SatoS3Stack extends cdk.Stack {
  readonly bucket: s3.Bucket;
  readonly herokuUser: iam.User;
  readonly devUser: iam.User;

  constructor(scope: Construct, id: string, props: SatoS3StackProps) {
    super(scope, id, props);

    this.bucket = new s3.Bucket(this, "MatsuriImagesBucket", {
      // バケット名は CDK に自動生成させる（グローバル一意性の問題を避けるため）
      encryption: s3.BucketEncryption.S3_MANAGED,
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
      enforceSSL: true,
      versioned: true,
      removalPolicy: cdk.RemovalPolicy.RETAIN, // 本番向け: 誤削除を防ぐ
      autoDeleteObjects: false,
    });

    // ブラウザからの直接アクセス用 CORS 設定
    this.bucket.addCorsRule({
      allowedOrigins: props.allowedOrigins,
      // 画像アップロード・取得・事前検証に必要なメソッド
      allowedMethods: [
        s3.HttpMethods.GET,
        s3.HttpMethods.PUT,
        s3.HttpMethods.POST,
        s3.HttpMethods.HEAD,
      ],
      allowedHeaders: ["*"],
      exposedHeaders: ["ETag"],
      maxAge: 3000,
    });

    // Heroku 用 IAM ユーザーと S3 ポリシー（別ファイルに切り出し）
    const herokuIam = new HerokuAppIam(this, "HerokuIam", {
      bucket: this.bucket,
    });
    this.herokuUser = herokuIam.user;

    // ローカル開発用 IAM ユーザーと S3 ポリシー
    const devIam = new DevAppIam(this, "DevIam", {
      bucket: this.bucket,
    });
    this.devUser = devIam.user;

    // バケット名を CloudFormation の出力として出しておく
    new cdk.CfnOutput(this, "MatsuriImagesBucketName", {
      value: this.bucket.bucketName,
      exportName: "MatsuriImagesBucketName",
    });

    // IAM ユーザー名も出力しておく（コンソールでアクセスキーを発行するため）
    new cdk.CfnOutput(this, "HerokuAppUserName", {
      value: this.herokuUser.userName,
      exportName: "HerokuAppUserName",
    });

    new cdk.CfnOutput(this, "DevAppUserName", {
      value: this.devUser.userName,
      exportName: "DevAppUserName",
    });
  }
}
