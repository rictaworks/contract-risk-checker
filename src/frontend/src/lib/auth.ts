import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/authOptions";

export async function getSessionHelper() {
  // DEV_AUTH_BYPASS はサーバー専用の非公開変数（NEXT_PUBLIC_ 接頭辞なし）。
  // .env.local にのみ設定し、本番環境では絶対に有効化しないこと。
  if (process.env.DEV_AUTH_BYPASS === 'true') {
    return {
      user: {
        name: "開発ユーザー",
        email: "dev-user@example.com",
        image: null,
      },
      sub: "dev-user-001",
      expires: new Date(Date.now() + 2 * 3600 * 1000).toISOString(),
    };
  }
  return await getServerSession(authOptions);
}
