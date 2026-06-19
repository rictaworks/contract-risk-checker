'use client';

import { useLocale } from './LocaleContext';
import ja from '../locales/ja.json';
import en from '../locales/en.json';
import fr from '../locales/fr.json';
import zh from '../locales/zh.json';
import ru from '../locales/ru.json';
import es from '../locales/es.json';
import ar from '../locales/ar.json';

const MESSAGES: Record<string, unknown> = { ja, en, fr, zh, ru, es, ar };

export function useTranslation() {
  const { locale } = useLocale();
  const dict: unknown = MESSAGES[locale] ?? MESSAGES['ja'];

  const t = (key: string): string => {
    const keys = key.split('.');
    let result: unknown = dict;
    for (const k of keys) {
      if (result !== null && typeof result === 'object' && k in result) {
        result = (result as Record<string, unknown>)[k];
      } else {
        return key;
      }
    }
    return typeof result === 'string' ? result : key;
  };

  return { t };
}
