import fs from 'fs';
import path from 'path';

describe('Hardcoded string checks', () => {
  it('should not contain raw Japanese characters in page.tsx', () => {
    const filePath = path.resolve(__dirname, '../app/page.tsx');
    const content = fs.readFileSync(filePath, 'utf-8');

    // 同一行内のクォーテーションで囲まれた日本語（ひらがな、カタカナ、漢字）文字列リテラルを検出
    const japaneseLiteralRegex = /["'`][^"'`\r\n]*[\u3040-\u30ff\u4e00-\u9faf]+[^"'`\r\n]*["'`]/;
    
    const hasJapaneseLiteral = japaneseLiteralRegex.test(content);
    expect(hasJapaneseLiteral).toBe(false);
  });
});
