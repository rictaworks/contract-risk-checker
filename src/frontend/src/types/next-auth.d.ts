import "next-auth";
import "next-auth/jwt";

declare module "next-auth" {
  interface Session {
    railsToken?: string;
    error?: string;
    user: {
      sub?: string;
      name?: string | null;
      email?: string | null;
      image?: string | null;
    };
  }
}

declare module "next-auth/jwt" {
  interface JWT {
    railsToken?: string;
    railsTokenExp?: number;
    googleIdToken?: string;
    error?: string;
  }
}
