'use client';

import { useEffect } from 'react';
import { useLocale } from '@/lib/LocaleContext';

const RTL_LOCALES = ['ar'];

export function HtmlLang() {
  const { locale } = useLocale();

  useEffect(() => {
    document.documentElement.lang = locale;
    document.documentElement.dir = RTL_LOCALES.includes(locale) ? 'rtl' : 'ltr';
  }, [locale]);

  return null;
}
