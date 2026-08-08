// Page Object — sign-in screen. Selectors only, no assertions (assertions live in tests).
exports.LoginPage = class LoginPage {
  constructor(page) {
    this.page = page;
    this.email = page.getByTestId('email');
    this.password = page.getByTestId('password');
    this.submit = page.getByTestId('login-btn');
    this.error = page.getByTestId('login-message');
  }
  async goto() { await this.page.goto('/'); }
  async signIn(email, password) {
    await this.email.fill(email);
    await this.password.fill(password);
    // Wait for the call to land, not just for the click to be dispatched. Returning early left the
    // message region present-but-empty -- i.e. hidden -- for a few milliseconds, which is enough
    // for `expect(error).toBeHidden()` to pass on its first poll. The mutation track found it:
    // inverting `toBeVisible` on the rejected-credential test produced a mutant that survived, and
    // an assertion whose negation is satisfied by the pre-state proves nothing about the app.
    await Promise.all([
      this.page.waitForResponse((r) => r.url().includes('/api/login')),
      this.submit.click(),
    ]);
  }
};
