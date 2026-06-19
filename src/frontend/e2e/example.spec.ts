import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('/');
  // タイトルに「契約」または「Contract」などが含まれているか検証
  await expect(page).toHaveTitle(/契約リスクチェッカー|Contract/);
});
