// Page Object — booking screen (slots, appointments). Selectors + actions only.
exports.BookingPage = class BookingPage {
  constructor(page) {
    this.page = page;
    this.whoami = page.getByTestId('whoami');
    this.specialty = page.getByTestId('specialty');
    this.slots = page.getByTestId('slots');
    this.appointments = page.getByTestId('appointments');
    this.message = page.locator('#app-section #message, #message').last();
    this.logout = page.getByTestId('logout-btn');
  }
  slotBookButton(slotId) { return this.page.getByTestId('book-' + slotId); }
  cancelButton(appointmentId) { return this.page.getByTestId('cancel-' + appointmentId); }
  async filterBy(specialty) { await this.specialty.selectOption(specialty); }
  async book(slotId) { await this.slotBookButton(slotId).click(); }
  async slotCount() { return this.slots.getByRole('listitem').count(); }
};
