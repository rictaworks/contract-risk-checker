import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import LoginPage from "@/app/login/page";
import { signIn, signOut, getSession } from "next-auth/react";
import { api } from "@/lib/api";

jest.mock("next-auth/react", () => ({
  signIn: jest.fn(),
  signOut: jest.fn(),
  useSession: jest.fn(() => ({
    data: null,
    status: "unauthenticated",
  })),
  getSession: jest.fn(),
}));

jest.mock("next/navigation", () => ({
  useRouter: () => ({
    push: jest.fn(),
  }),
}));

describe("LoginPage", () => {
  const originalEnv = process.env.NEXT_PUBLIC_DEV_AUTH_BYPASS;

  afterEach(() => {
    jest.clearAllMocks();
    process.env.NEXT_PUBLIC_DEV_AUTH_BYPASS = originalEnv;
  });

  it("非開発環境では、Googleログインボタンが表示され、クリックでsignIn('google')が呼ばれること", () => {
    process.env.NEXT_PUBLIC_DEV_AUTH_BYPASS = undefined;

    render(<LoginPage />);

    const button = screen.getByText("Googleアカウントでログイン");
    expect(button).toBeInTheDocument();

    fireEvent.click(button);
    expect(signIn).toHaveBeenCalledWith("google", { callbackUrl: "/" });
  });

  it("NEXT_PUBLIC_DEV_AUTH_BYPASS=true では、自動的にcredentialsでsignInされること", () => {
    process.env.NEXT_PUBLIC_DEV_AUTH_BYPASS = "true";

    render(<LoginPage />);

    expect(signIn).toHaveBeenCalledWith("credentials", { callbackUrl: "/" });
    expect(screen.getByText("Loading...")).toBeInTheDocument();
  });
});

describe("API Client (Axios Interceptors)", () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  it("getSessionにrailsTokenがある場合、Authorizationヘッダーにトークンがセットされること", async () => {
    (getSession as jest.Mock).mockResolvedValue({ railsToken: "test-jwt-token" });

    const config = { headers: {} as Record<string, string> };
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const requestInterceptor = (api.interceptors.request as any).handlers[0].fulfilled;
    const resultConfig = await requestInterceptor(config);

    expect(resultConfig.headers.Authorization).toBe("Bearer test-jwt-token");
  });

  it("レスポンスが 401 Unauthorized の場合、signOut を呼んで /login へ遷移すること", async () => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const responseInterceptorError = (api.interceptors.response as any).handlers[0].rejected;
    const mockError = {
      response: {
        status: 401,
      },
    };

    await expect(responseInterceptorError(mockError)).rejects.toEqual(mockError);
    expect(jest.mocked(signOut)).toHaveBeenCalledWith({ callbackUrl: "/login" });
  });
});
