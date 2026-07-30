// Page object for the OWASP Juice Shop "Forgot Password" screen.
// No assertions here (rule: assertions live in tests, per plugins/qaia-playwright/skills/automate/SKILL.md).
class ForgotPasswordPage {
  constructor(page) {
    this.page = page;
    this.emailInput = page.getByPlaceholder('Enter your email');
    this.securityAnswerInput = page.locator('#securityAnswer');
    this.newPasswordInput = page.locator('#newPassword');
    this.newPasswordRepeatInput = page.locator('#newPasswordRepeat');
    this.changeButton = page.locator('#resetButton');
  }

  async goto() {
    await this.page.goto('/#/forgot-password');
    // Angular SPA route settle.
    await this.emailInput.waitFor({ state: 'visible' });
  }

  async enterEmail(email) {
    await this.emailInput.fill(email);
    await this.emailInput.blur();
    // Give the async GET /rest/user/security-question a moment to resolve
    // and the Angular form to re-evaluate the disabled state.
    await this.page.waitForTimeout(800);
  }

  async fillResetForm({ answer, newPassword, repeatPassword }) {
    if (answer !== undefined) await this.securityAnswerInput.fill(answer);
    if (newPassword !== undefined) await this.newPasswordInput.fill(newPassword);
    if (repeatPassword !== undefined) await this.newPasswordRepeatInput.fill(repeatPassword);
  }

  async submit() {
    await this.changeButton.click();
  }
}

module.exports = { ForgotPasswordPage };
