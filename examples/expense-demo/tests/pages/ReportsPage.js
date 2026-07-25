// Page Object — post-login screen (new report, my reports, approval inbox).
// Selectors + actions only, no assertions (assertions live in tests, T2/D34).
exports.ReportsPage = class ReportsPage {
  constructor(page) {
    this.page = page;
    this.whoami = page.getByTestId('whoami');
    this.role = page.getByTestId('role');
    this.logout = page.getByTestId('logout-btn');
    this.newReportBtn = page.getByTestId('new-report-btn');
    this.currency = page.getByTestId('currency');
    this.addLineBtn = page.getByTestId('add-line-btn');
    this.submitReportBtn = page.getByTestId('submit-report-btn');
    this.mine = page.getByTestId('mine');
    this.inbox = page.getByTestId('inbox');
    this.message = page.locator('#message');
  }

  async startDraft() { await this.newReportBtn.click(); }

  async fillLine(idx, { category, amount, date, receipt }) {
    if (category !== undefined) await this.page.getByTestId('line-category-' + idx).fill(category);
    if (amount !== undefined) await this.page.getByTestId('line-amount-' + idx).fill(String(amount));
    if (date !== undefined) await this.page.getByTestId('line-date-' + idx).fill(date);
    if (receipt) await this.page.getByTestId('line-receipt-' + idx).check();
  }

  async addLine() { await this.addLineBtn.click(); }
  async submitDraft() { await this.submitReportBtn.click(); }

  // Real report cards only — distinct from the empty-state placeholder, which also carries
  // `role="listitem"` (ARIA requires it even when empty, see app.js) but no `data-testid`.
  // Selecting on the `data-testid^="report-"` prefix avoids a count-based race between the
  // two (found while automating: `getByRole('listitem')` alone can transiently match the
  // empty-state placeholder right after the accessibility fix was applied).
  mineCards() { return this.mine.locator('[data-testid^="report-"]'); }
  reportCard(id) { return this.page.getByTestId('report-' + id); }
  status(id) { return this.page.getByTestId('status-' + id); }
  editBtn(id) { return this.page.getByTestId('edit-' + id); }
  approveBtn(id) { return this.page.getByTestId('approve-' + id); }
  rejectBtn(id) { return this.page.getByTestId('reject-' + id); }
  changesBtn(id) { return this.page.getByTestId('changes-' + id); }
  comment(id) { return this.page.getByTestId('comment-' + id); }

  async decide(id, action, comment) {
    if (comment) await this.comment(id).fill(comment);
    if (action === 'approve') await this.approveBtn(id).click();
    if (action === 'reject') await this.rejectBtn(id).click();
    if (action === 'changes') await this.changesBtn(id).click();
  }
};
