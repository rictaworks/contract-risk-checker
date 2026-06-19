import ja from '../locales/ja.json';

export function useTranslation() {
  const t = (key: string): string => {
    const keys = key.split('.');
    let result: unknown = ja;
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
