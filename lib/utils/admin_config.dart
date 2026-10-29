// simple admin check for tp go
// this only controls whether admin UI is shown in the app.
// real production security should also be enforced with firestore rules.
const String adminEmail = String.fromEnvironment('TPGO_ADMIN_EMAIL');

bool isAdminEmail(String? email) {
  if (email == null) return false;
  return email.trim().toLowerCase() == adminEmail.toLowerCase();
}
