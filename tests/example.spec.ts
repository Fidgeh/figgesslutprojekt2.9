import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('localhost:9292/login?');
  await page.getByLabel('Username:').fill("figge");
  await page.getByLabel("Password:").fill("123");
  
  await page.getByRole('button', { name: 'Login' }).click();

  await expect(page.getByRole('heading', { name: 'Admin' })).toBeVisible();
});

test('get started link', async ({ page }) => {
  await page.goto('https://playwright.dev/');

  // Click the get started link.
  await page.getByRole('link', { name: 'Get started' }).click();

  // Expects page to have a heading with the name of Installation.
  await expect(page.getByRole('heading', { name: 'Installation' })).toBeVisible();
});
