import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/authOptions";

export async function getSessionHelper() {
  if (process.env.NODE_ENV !== "production" && process.env.NEXT_PUBLIC_DEV_AUTH_BYPASS === "true") {
    return {
      user: {
        name: "\u958b\u767a\u30e6\u30fc\u30b6\u30fc",
        email: "dev-user@example.com",
        image: null,
        sub: "dev-user-001",
      },
      sub: "dev-user-001",
      railsToken: "dummy-dev-token",
      expires: new Date(Date.now() + 2 * 3600 * 1000).toISOString(),
    };
  }
  return await getServerSession(authOptions);
}
