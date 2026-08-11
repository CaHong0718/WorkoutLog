import receive_sharing_intent

/// Receives a routine `.json` shared from another app and hands it straight to
/// Workout Log.
///
/// The default `shouldAutoRedirect()` is kept: there is nothing to compose, and
/// the app's own import screen already asks for confirmation before anything is
/// written to the database.
///
/// If Xcode reports "No such module 'receive_sharing_intent'", move
/// `Embed Foundation Extension` above `Thin Binary` in the Runner target's
/// Build Phases.
class ShareViewController: RSIShareViewController {}
