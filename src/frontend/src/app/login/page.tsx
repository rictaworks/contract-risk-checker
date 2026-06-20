"use client";

import React, { useEffect } from "react";
import { signIn, signOut, useSession } from "next-auth/react";
import { useRouter } from "next/navigation";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faGoogle } from "@fortawesome/free-brands-svg-icons";
import { faFileContract } from "@fortawesome/free-solid-svg-icons";
import { useTranslation } from "@/lib/useTranslation";
import styles from "./login.module.css";

export default function LoginPage() {
  const { data: session, status } = useSession();
  const router = useRouter();
  const { t } = useTranslation();
  const isDevelopment = process.env.NEXT_PUBLIC_DEV_AUTH_BYPASS === "true";

  useEffect(() => {
    if (isDevelopment) {
      signIn("credentials", { callbackUrl: "/" });
      return;
    }

    if (session?.error === "RailsTokenExpired") {
      signOut({ callbackUrl: "/login" });
      return;
    }

    if (status === "authenticated") {
      router.push("/");
    }
  }, [status, session, router]);

  const handleGoogleLogin = () => {
    signIn("google", { callbackUrl: "/" });
  };

  if (isDevelopment || status === "loading") {
    return (
      <div className={styles.container}>
        <div className={styles.loadingBox}>
          <div className={styles.spinner}></div>
          <p className={styles.loadingText}>Loading...</p>
        </div>
      </div>
    );
  }

  return (
    <div className={styles.container}>
      <div className={styles.card}>
        <div className={styles.logoContainer}>
          <FontAwesomeIcon icon={faFileContract} className={styles.logoIcon} />
          <h1 className={styles.title}>{t("common.title")}</h1>
        </div>
        <p className={styles.subtitle}>{t("login.subtitle")}</p>
        <button className={styles.loginButton} onClick={handleGoogleLogin}>
          <FontAwesomeIcon icon={faGoogle} className={styles.googleIcon} />
          {t("login.google_button")}
        </button>
      </div>
    </div>
  );
}
