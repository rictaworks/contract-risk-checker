import { AuthOptions } from "next-auth";
import GoogleProvider from "next-auth/providers/google";
import CredentialsProvider from "next-auth/providers/credentials";

if (process.env.NODE_ENV === "production" && process.env.NEXT_PUBLIC_DEV_AUTH_BYPASS === "true") {
  throw new Error("NEXT_PUBLIC_DEV_AUTH_BYPASS must not be set in production");
}
if (process.env.NODE_ENV === "production" && !process.env.NEXT_PUBLIC_API_URL) {
  throw new Error("NEXT_PUBLIC_API_URL must be set in production");
}
const isDevelopment =
  process.env.NODE_ENV !== "production" &&
  process.env.NEXT_PUBLIC_DEV_AUTH_BYPASS === "true";
const RAILS_JWT_LIFETIME_MS = 30 * 24 * 60 * 60 * 1000;

export const authOptions: AuthOptions = {
  providers: [
    ...(isDevelopment
      ? [
          CredentialsProvider({
            id: "credentials",
            name: "Dev Login",
            credentials: {},
            async authorize() {
              return {
                id: "dev-user-001",
                name: "Dev User",
                email: "dev-user@example.com",
                sub: "dev-user-001",
              };
            },
          }),
        ]
      : [
          GoogleProvider({
            clientId: process.env.GOOGLE_CLIENT_ID || "",
            clientSecret: process.env.GOOGLE_CLIENT_SECRET || "",
          }),
        ]),
  ],
  session: {
    strategy: "jwt",
    maxAge: 30 * 24 * 60 * 60,
  },
  callbacks: {
    async signIn() {
      if (!isDevelopment && (!process.env.GOOGLE_CLIENT_ID || !process.env.GOOGLE_CLIENT_SECRET)) {
        throw new Error("Google OAuth credentials (GOOGLE_CLIENT_ID / GOOGLE_CLIENT_SECRET) are not configured");
      }
      return true;
    },
    async jwt({ token, user, account }) {
      if (user) {
        token.sub = user.id;
        token.name = user.name;
      }
      if (account?.provider === "google") {
        token.googleIdToken = account.id_token;
        token.sub = account.providerAccountId;
      }

      if (token.railsTokenExp && Date.now() > token.railsTokenExp) {
        return { ...token, railsToken: undefined, railsTokenExp: undefined, error: "RailsTokenExpired" };
      }

      if (!token.railsToken) {
        if (isDevelopment) {
          token.railsToken = "dummy-dev-token";
        } else if (token.googleIdToken) {
          const apiUrl = process.env.NODE_ENV !== "production"
            ? (process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:3001")
            : process.env.NEXT_PUBLIC_API_URL!;
          const res = await fetch(`${apiUrl}/api/v1/auth/google`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ id_token: token.googleIdToken }),
          });

          if (!res.ok) {
            throw new Error(`Rails token exchange failed: ${res.status} ${res.statusText}`);
          }

          const data = await res.json();
          token.railsToken = data.token;
          token.railsTokenExp = Date.now() + RAILS_JWT_LIFETIME_MS;
        }
      }
      return token;
    },
    async session({ session, token }) {
      if (token.error) {
        return { ...session, error: token.error };
      }
      if (session.user) {
        session.user.sub = token.sub;
        session.user.name = token.name as string | null;
        session.railsToken = token.railsToken;
      }
      return session;
    },
  },
  pages: {
    signIn: "/login",
  },
};
