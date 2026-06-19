'use client';

import React, { createContext, useContext, useState } from 'react';

export const SUPPORTED_LOCALES = ['ja', 'en', 'fr', 'zh', 'ru', 'es', 'ar'] as const;
export type SupportedLocale = typeof SUPPORTED_LOCALES[number];

interface LocaleContextValue {
  locale: SupportedLocale;
  setLocale: (locale: SupportedLocale) => void;
}

const LocaleContext = createContext<LocaleContextValue>({
  locale: 'ja',
  setLocale: () => {},
});

export function LocaleProvider({ children }: { children: React.ReactNode }) {
  const [locale, setLocale] = useState<SupportedLocale>('ja');
  return (
    <LocaleContext.Provider value={{ locale, setLocale }}>
      {children}
    </LocaleContext.Provider>
  );
}

export function useLocale(): LocaleContextValue {
  return useContext(LocaleContext);
}
