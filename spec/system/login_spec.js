const { test, expect } = require('@playwright/test');

test.describe('Login Flow', () => {
  test('should display login and sign up links when not logged in', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('text=Sign up')).toBeVisible();
    await expect(page.locator('text=Log in')).toBeVisible();
  });

  test('should be able to sign up a new user', async ({ page }) => {
    await page.goto('/');
    await page.click('text=Sign up');
    await expect(page).toHaveURL(/.*\/users\/sign_up/);

    const email = `test${Date.now()}@example.com`;
    const realName = 'テスト太郎';
    const nickname = 'テストニックネーム';

    await page.fill('input[name="user[real_name]"]', realName);
    await page.fill('input[name="user[nickname]"]', nickname);
    await page.fill('input[name="user[email]"]', email);
    await page.fill('input[name="user[password]"]', 'password123');
    await page.fill('input[name="user[password_confirmation]"]', 'password123');
    await page.click('input[type="submit"]');

    // Should redirect to home page after sign up
    await expect(page).toHaveURL('/');
    await expect(page.locator(`text=${nickname}`)).toBeVisible();
  });

  test('should be able to log in with existing user', async ({ page }) => {
    // First create a user
    const email = `test${Date.now()}@example.com`;
    const realName = 'テスト太郎';
    const nickname = 'テストニックネーム';

    await page.goto('/users/sign_up');
    await page.fill('input[name="user[real_name]"]', realName);
    await page.fill('input[name="user[nickname]"]', nickname);
    await page.fill('input[name="user[email]"]', email);
    await page.fill('input[name="user[password]"]', 'password123');
    await page.fill('input[name="user[password_confirmation]"]', 'password123');
    await page.click('input[type="submit"]');

    // Log out
    await page.click('text=Log out');

    // Log in
    await page.click('text=Log in');
    await expect(page).toHaveURL(/.*\/users\/sign_in/);
    await page.fill('input[name="user[email]"]', email);
    await page.fill('input[name="user[password]"]', 'password123');
    await page.click('input[type="submit"]');

    // Should redirect to home page after login
    await expect(page).toHaveURL('/');
    await expect(page.locator(`text=${nickname}`)).toBeVisible();
  });
});
