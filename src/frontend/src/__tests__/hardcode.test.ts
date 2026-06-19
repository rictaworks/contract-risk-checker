import fs from 'fs';
import path from 'path';

const JAPANESE_LITERAL_REGEX = /["'`][^"'`\r\n]*[぀-ヿ一-龯]+[^"'`\r\n]*["'`]/;

const SRC_DIR = path.resolve(__dirname, '..');

function collectFiles(dir: string, ext: string[]): string[] {
  const result: string[] = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory() && entry.name !== 'locales' && entry.name !== '__tests__') {
      result.push(...collectFiles(full, ext));
    } else if (entry.isFile() && ext.some(e => entry.name.endsWith(e))) {
      result.push(full);
    }
  }
  return result;
}

describe('Hardcoded string checks', () => {
  const targetFiles = collectFiles(SRC_DIR, ['.tsx', '.ts']).filter(
    f => !f.includes('LocaleContext') && !f.includes('useTranslation')
  );

  it.each(targetFiles)('should not contain hardcoded Japanese string literals in %s', (filePath) => {
    const content = fs.readFileSync(filePath, 'utf-8');
    const lines = content.split('\n');
    const violations = lines
      .map((line, i) => ({ line, no: i + 1 }))
      .filter(({ line }) => JAPANESE_LITERAL_REGEX.test(line));

    expect(violations).toEqual([]);
  });
});
