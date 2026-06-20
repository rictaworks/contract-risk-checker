import axios from "axios";
import { getSession, signOut } from "next-auth/react";
import { redirectToLogin } from "./navigation";

const isDevelopment = process.env.NEXT_PUBLIC_DEV_AUTH_BYPASS === "true";
const API_URL = process.env.NODE_ENV !== "production"
  ? (process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:3001")
  : process.env.NEXT_PUBLIC_API_URL!;

export const api = axios.create({
  baseURL: API_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

api.interceptors.request.use(
  async (config) => {
    if (typeof window !== "undefined") {
      const session = await getSession();

      if (session?.error === "RailsTokenExpired") {
        redirectToLogin();
        return Promise.reject(new Error("Rails token expired"));
      }

      const token = session?.railsToken;
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      } else if (isDevelopment) {
        config.headers.Authorization = "Bearer dummy-dev-token";
      }
    }

    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    if (error.response && error.response.status === 401) {
      signOut({ callbackUrl: "/login" });
    }
    return Promise.reject(error);
  }
);
