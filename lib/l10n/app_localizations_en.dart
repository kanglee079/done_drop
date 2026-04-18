// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'DoneDrop';

  @override
  String get memberFallbackName => 'DoneDrop member';

  @override
  String get greetingFallbackName => 'there';

  @override
  String get authTagline => 'Complete it. Capture it.\nShare the moment.';

  @override
  String get todayTabTitle => 'Today';

  @override
  String get todayTabSubtitle => 'Discipline stays visible.';

  @override
  String get buddyTabTitle => 'Buddy';

  @override
  String get buddyTabSubtitle => 'Private proof from your circle.';

  @override
  String get wallTabTitle => 'Wall';

  @override
  String get wallTabSubtitle => 'Your archive, grouped by memory.';

  @override
  String get meTabTitle => 'Me';

  @override
  String get meTabSubtitle => 'Stats, reminders, and settings.';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get welcomeGetStarted => 'Get Started';

  @override
  String get welcomeContinue => 'Continue';

  @override
  String get welcomeDone => 'Done';

  @override
  String get onboardingHeadline =>
      'Hold yourself accountable.\nComplete your habits. Prove it.';

  @override
  String get onboardingSubtitle =>
      'Build habits. Complete them. Capture proof. Share privately with accountability partners.';

  @override
  String get onboardingUseCaseTitle => 'WHAT BRINGS YOU HERE?';

  @override
  String get captureProofTitle => 'Capture proof';

  @override
  String get captureProofSubtitle =>
      'DoneDrop needs camera access to capture proof moments. Your photos stay private until you choose to share them.';

  @override
  String get privateByDefault => 'Private by default';

  @override
  String get privateByDefaultDesc => 'You control who sees your proof moments.';

  @override
  String get secureByDefault => 'End-to-end secure';

  @override
  String get secureByDefaultDesc => 'Your accountability data stays yours.';

  @override
  String get gentleRemindersTitle => 'Gentle reminders';

  @override
  String get gentleRemindersDesc => 'Optional nudges to complete your habits.';

  @override
  String get proofOnlyWhenYouChoose => 'Only when it matters';

  @override
  String get proofOnlyWhenYouChooseDesc =>
      'Attach proof only when the habit deserves it.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'friend@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => '••••••••';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameHint => 'Your name';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get confirmPasswordHint => 'Repeat your password';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get createAccountSubtitle =>
      'Start capturing your done moments today.';

  @override
  String get signInAction => 'Sign In';

  @override
  String get signUpAction => 'Sign Up';

  @override
  String get createAccountAction => 'Create Account';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get forgotPasswordAction => 'Forgot password?';

  @override
  String get orLabel => 'or';

  @override
  String get noAccountPrompt => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccountPrompt => 'Already have an account? ';

  @override
  String get termsAgreementPrefix => 'By continuing, you agree to our ';

  @override
  String get createTermsAgreementPrefix =>
      'By creating an account, you agree to our ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get andLabel => ' and ';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get nameTooShort => 'Name must be at least 2 characters';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get emailInvalid => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Please enter a password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get confirmPasswordMismatch => 'Passwords do not match';

  @override
  String todayGreeting(String name) {
    return 'Hi $name';
  }

  @override
  String get todayIntroTitle => 'Keep today simple and visible.';

  @override
  String todayIntroProgress(int completed, int total) {
    return '$completed of $total habits finished so far.';
  }

  @override
  String get summaryDone => 'Done';

  @override
  String get summaryToday => 'Today';

  @override
  String get summaryBestStreak => 'Best streak';

  @override
  String get summaryDays => 'Days';

  @override
  String get summaryBuddies => 'Buddies';

  @override
  String get summaryPrivate => 'Private';

  @override
  String get nextUpTitle => 'Next up';

  @override
  String get nextUpSubtitle =>
      'The one habit to finish before the rest of the day slips away.';

  @override
  String get overdueTitle => 'Overdue';

  @override
  String get overdueSubtitle => 'Recover these before tomorrow starts.';

  @override
  String get laterTodayTitle => 'Later today';

  @override
  String get laterTodayEmpty =>
      'No extra habits queued after your next priority.';

  @override
  String get laterTodayFilled => 'Keep the rest of the day glanceable.';

  @override
  String get capturedTodayTitle => 'Captured today';

  @override
  String get capturedTodaySubtitle =>
      'Proof moments and finished habits from this session.';

  @override
  String get weeklyRecapTitle => 'Weekly recap';

  @override
  String get weeklyRecapOpen => 'Open';

  @override
  String weeklyRecapSummary(int count) {
    return '$count habit completions logged in the last 7 days.';
  }

  @override
  String get needNewHabitTitle => 'Need a new habit?';

  @override
  String get needNewHabitSubtitle => 'Add it while the standard is clear.';

  @override
  String get addAction => 'Add';

  @override
  String get addHabitTitle => 'Add a habit';

  @override
  String get addHabitSubtitle =>
      'Keep it specific enough that you know exactly what “done” means.';

  @override
  String get habitNameHint => 'Habit name';

  @override
  String get habitCategoryHint => 'Category (optional)';

  @override
  String get habitTimeLabel => 'Time';

  @override
  String get pickTimeAction => 'Pick time';

  @override
  String get createHabitAction => 'Create habit';

  @override
  String get emptyTodayTitle => 'Start with one standard.';

  @override
  String get emptyTodaySubtitle =>
      'Create the first habit you want to prove to yourself today.';

  @override
  String get createFirstHabitAction => 'Create first habit';

  @override
  String get nothingCapturedTitle => 'Nothing captured yet';

  @override
  String get nothingCapturedSubtitle =>
      'Complete a habit and attach proof when it adds meaning.';

  @override
  String get capturedProofAttached => 'Proof attached';

  @override
  String get capturedSavedOnly => 'Saved only';

  @override
  String get allHabitsHandledTitle => 'All habits handled';

  @override
  String get allHabitsHandledSubtitle =>
      'You are clear for the day. Capture proof if a win deserves it.';

  @override
  String get onlyOneThingLeftTitle => 'Only one thing left';

  @override
  String get onlyOneThingLeftSubtitle =>
      'Finish your hero habit and you are done for today.';

  @override
  String get heroOverdueNow => 'Overdue now';

  @override
  String get heroNextUp => 'Next up';

  @override
  String get heroProofAttached => 'Proof attached';

  @override
  String get heroPrivateByDefault => 'Private by default';

  @override
  String get heroNeedsRecovery => 'Needs recovery';

  @override
  String get heroOneTapToFinish => 'Photo required to finish';

  @override
  String get heroCompletedWithProof => 'Completed with proof today';

  @override
  String get heroCompletedToday => 'Completed today';

  @override
  String get completeNowAction => 'Complete now';

  @override
  String get completeWithProofAction => 'Finish with photo';

  @override
  String get proofLabel => 'Proof';

  @override
  String get themeSettingsTitle => 'Theme & settings';

  @override
  String get themeSettingsSubtitle => 'App preferences and personal controls.';

  @override
  String get statsSectionTitle => 'Stats';

  @override
  String get statsSectionSubtitle => 'The numbers that matter right now.';

  @override
  String get weeklyWinsLabel => 'Weekly wins';

  @override
  String get activeHabitsLabel => 'Active habits';

  @override
  String get remindersSectionTitle => 'Reminders';

  @override
  String get remindersSectionSubtitle => 'Keep the discipline loop visible.';

  @override
  String get habitRemindersTitle => 'Habit reminders';

  @override
  String habitRemindersSubtitle(int count) {
    return '$count habits currently have reminders.';
  }

  @override
  String get archivedHabitsSectionTitle => 'Archived habits';

  @override
  String get archivedHabitsSectionSubtitle =>
      'Standards you have paused, not deleted.';

  @override
  String get noArchivedHabitsTitle => 'No archived habits';

  @override
  String get noArchivedHabitsSubtitle => 'Standards you pause will show here.';

  @override
  String get archivedHabitFallback => 'Archived habit';

  @override
  String get restoreAction => 'Restore';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeSubtitle => 'Using system theme';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSubtitle => 'Display name, username, avatar';

  @override
  String get buddyCircleTitle => 'Buddy circle';

  @override
  String get buddyCircleSubtitle =>
      'Invite, remove, and manage close accountability friends';

  @override
  String get privacySupportSectionTitle => 'Privacy & support';

  @override
  String get privacySupportSectionSubtitle =>
      'Policies, help, and release details.';

  @override
  String get privacyPolicySubtitle =>
      'Read how DoneDrop handles your account and moment data';

  @override
  String get termsSubtitle =>
      'The rules for using DoneDrop and private buddy features';

  @override
  String get supportTitle => 'Support';

  @override
  String get supportSubtitle =>
      'Report an issue or get help from inside the app';

  @override
  String get appVersionTitle => 'App version';

  @override
  String get accountActionsSectionTitle => 'Account actions';

  @override
  String get accountActionsSectionSubtitle =>
      'Sign out, or permanently remove this account.';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountSubtitle =>
      'Permanently delete your profile, habits, and moments';

  @override
  String get deleteAccountRemovingSubtitle => 'Removing your account data...';

  @override
  String get signOutAction => 'Sign out';

  @override
  String get themeSettingsSnackbarTitle => 'Theme settings';

  @override
  String get themeSettingsSnackbarMessage =>
      'Theme controls are currently following your system setting.';

  @override
  String get setupTitle => 'Set up your first 3 habits';

  @override
  String get setupSubtitle =>
      'Give today structure before you land on the home screen.';

  @override
  String setupHabitTitle(int index) {
    return 'Habit $index';
  }

  @override
  String get setupHabitPrompt => 'What do you want to show up for?';

  @override
  String get setupHabitTimePrompt => 'When should it show up today?';

  @override
  String get setupPrimaryAction => 'Start my day';

  @override
  String get setupValidationError => 'Create all 3 habits before continuing.';

  @override
  String get setupSaveError =>
      'We couldn\'t save your first habits. Please try again.';

  @override
  String get setupMorningDefault => 'Drink water';

  @override
  String get setupMiddayDefault => 'Walk for 10 minutes';

  @override
  String get setupEveningDefault => 'Read 20 pages';

  @override
  String get saveAction => 'Save';

  @override
  String get closeAction => 'Close';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get continueAction => 'Continue';

  @override
  String get deleteAction => 'Delete';

  @override
  String get removeAction => 'Remove';

  @override
  String get doneAction => 'Done';

  @override
  String get searchAction => 'Search';

  @override
  String get verifyAction => 'Verify';

  @override
  String get genericErrorTitle => 'Error';

  @override
  String get statusPreviewOnly => 'Preview only';

  @override
  String get statusQueued => 'Queued';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String statusUploading(int progress) {
    return 'Uploading $progress%';
  }

  @override
  String get statusSyncing => 'Syncing';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusPosted => 'Posted';

  @override
  String get uploadStagePreparingImage => 'Preparing image…';

  @override
  String get uploadStageFinalizingMoment => 'Finalizing moment…';

  @override
  String get uploadReady => 'Ready';

  @override
  String get buddyEmptyTitle => 'Your buddy feed is private by design.';

  @override
  String get buddyEmptySubtitle =>
      'Invite a few close people you trust to keep the proof loop intimate.';

  @override
  String get buddyViewWallAction => 'Open wall';

  @override
  String get inviteBuddyAction => 'Invite buddy';

  @override
  String manageCircleAction(int count) {
    return 'Manage circle ($count)';
  }

  @override
  String get wallSectionSubtitle =>
      'Every proof you kept, including the ones you shared.';

  @override
  String wallLeadFallback(String date) {
    return 'A kept promise from $date';
  }

  @override
  String get wallTileFallback => 'Saved to your archive';

  @override
  String get wallEmptyTitle => 'Keep one promise.';

  @override
  String get wallEmptySubtitle =>
      'The wall grows from there, one kept standard at a time.';

  @override
  String buddyWallTitle(String name) {
    return '$name\'s wall';
  }

  @override
  String buddyWallHeroSubtitle(int count) {
    return '$count shared proof moments you can revisit.';
  }

  @override
  String get buddyWallEmptyTitle => 'Nothing shared yet.';

  @override
  String buddyWallEmptySubtitle(String name) {
    return '$name hasn\'t shared a proof moment with you yet.';
  }

  @override
  String get reactionLoveLabel => 'Favorite';

  @override
  String get reactionCelebrateLabel => 'Celebrate';

  @override
  String get reactionInspiringLabel => 'Inspiring';

  @override
  String get friendFeedTitle => 'Friend Feed';

  @override
  String get markAllReadTooltip => 'Mark all as read';

  @override
  String get feedEmptyTitle => 'No moments yet';

  @override
  String get feedEmptySubtitle =>
      'Moments shared by your friends\nwill appear here.';

  @override
  String get addFriendsAction => 'Add Friends';

  @override
  String get memoryWallTitle => 'Memory Wall';

  @override
  String get memoryWallAllFilter => 'All moments';

  @override
  String get memoryWallEmptyTitle => 'No moments yet';

  @override
  String get memoryWallEmptySubtitle =>
      'Your archive of kept promises\nwill appear here.';

  @override
  String get createFirstMomentAction => 'Create your first moment';

  @override
  String get deleteMomentTitle => 'Delete Moment';

  @override
  String get deleteMomentMessage =>
      'Are you sure you want to delete this moment?';

  @override
  String get buddyCrewTitle => 'Buddy Crew';

  @override
  String get crewTabLabel => 'Crew';

  @override
  String crewTabCountLabel(int count, int limit) {
    return 'Crew ($count/$limit)';
  }

  @override
  String get requestsTabLabel => 'Requests';

  @override
  String get noFriendsYetTitle => 'No friends yet';

  @override
  String get noFriendsYetSubtitle =>
      'Add some buddies to keep you accountable.';

  @override
  String get addFriendAction => 'Add Friend';

  @override
  String get removeFriendTitle => 'Remove Friend';

  @override
  String get removeFriendMessage => 'Remove this friend?';

  @override
  String get noPendingRequestsTitle => 'No pending requests';

  @override
  String get noPendingRequestsSubtitle =>
      'Incoming and outgoing requests appear here.';

  @override
  String get incomingSectionLabel => 'INCOMING';

  @override
  String get sentSectionLabel => 'SENT';

  @override
  String get friendRequestIncomingSubtitle => 'Wants to be your friend';

  @override
  String get friendRequestSentSubtitle => 'Friend request sent';

  @override
  String get friendAddedTitle => 'Friend added';

  @override
  String friendAddedMessage(String name) {
    return '$name is now your friend';
  }

  @override
  String get friendRemovedTitle => 'Friend removed';

  @override
  String get friendRemovedMessage => 'The friendship has been removed';

  @override
  String get addBuddyTitle => 'Add Buddy';

  @override
  String get findByUsernameTitle => 'Find by Username';

  @override
  String get findByUsernameSubtitle =>
      'Enter their username to send a buddy request.';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'johndoe';

  @override
  String get buddyLimitReachedTitle => 'Buddy Limit Reached';

  @override
  String buddyLimitReachedSubtitle(int limit) {
    return 'Free plan allows up to $limit buddies. Upgrade for more.';
  }

  @override
  String get enterUsernameError => 'Enter a username';

  @override
  String get usernameTooShort => 'Username must be at least 3 characters';

  @override
  String get ownUsernameError => 'That is your own username';

  @override
  String friendCapReachedError(int limit) {
    return 'You have reached the maximum of $limit friends.';
  }

  @override
  String get requestSentTitle => 'Request Sent';

  @override
  String requestSentMessage(String name) {
    return 'Friend request sent to $name';
  }

  @override
  String get sendBuddyRequestPrompt => 'Send a buddy request?';

  @override
  String get sendBuddyRequestAction => 'Send Buddy Request';

  @override
  String get requestSentSuccessTitle => 'Request Sent!';

  @override
  String requestSentSuccessMessage(String name) {
    return 'Buddy request sent to $name';
  }

  @override
  String get addAnotherBuddyAction => 'Add Another Buddy';

  @override
  String get chatOpenAction => 'Message';

  @override
  String get chatScreenSubtitle => 'Private conversation with this buddy.';

  @override
  String get chatEmptyTitle => 'Start the conversation';

  @override
  String get chatEmptySubtitle =>
      'Keep the accountability loop private and clear.';

  @override
  String get chatInputHint => 'Send a message...';

  @override
  String get chatSendAction => 'Send';

  @override
  String get profileFieldDisplayName => 'DISPLAY NAME';

  @override
  String get profileFieldBio => 'BIO';

  @override
  String get profileNameHint => 'Your name';

  @override
  String get profileBioHint => 'Tell your friends a little about yourself';

  @override
  String get dangerZoneLabel => 'DANGER ZONE';

  @override
  String get notificationSettingsTitle => 'Notifications';

  @override
  String get notificationCenterEmptyTitle => 'No notifications yet.';

  @override
  String get notificationCenterEmptySubtitle =>
      'Friend requests and new buddy moments will show up here.';

  @override
  String get notificationPermissionOffSubtitle =>
      'Allow notifications so DoneDrop can alert you at each task\'s exact time.';

  @override
  String get notificationExactAlarmOffSubtitle =>
      'Enable exact alarms so Android can fire reminders at the precise minute on this device.';

  @override
  String get momentRemindersTitle => 'Moment Reminders';

  @override
  String get momentRemindersSubtitle =>
      'Get a gentle daily nudge to capture your moment.';

  @override
  String get notificationReminderTitle => 'Reminder';

  @override
  String get notificationReminderDesc => 'Toggle daily reminder on/off';

  @override
  String get notificationTimeTitle => 'Time';

  @override
  String get weeklyRecapSettingsTitle => 'Weekly Recap';

  @override
  String get weeklyRecapSettingsSubtitle =>
      'Receive a weekly summary of your moments.';

  @override
  String get weeklyRecapToggleTitle => 'Recap';

  @override
  String get weeklyRecapToggleDesc => 'Toggle weekly recap on/off';

  @override
  String get notificationDayTitle => 'Day';

  @override
  String get requestNotificationPermissionAction =>
      'Request Notification Permission';

  @override
  String get selectDayTitle => 'Select Day';

  @override
  String get dayMonShort => 'Mon';

  @override
  String get dayTueShort => 'Tue';

  @override
  String get dayWedShort => 'Wed';

  @override
  String get dayThuShort => 'Thu';

  @override
  String get dayFriShort => 'Fri';

  @override
  String get daySatShort => 'Sat';

  @override
  String get daySunShort => 'Sun';

  @override
  String get settingsArchiveTitle => 'The Archive';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Curate your personal experience';

  @override
  String get premiumBannerTitle => 'DoneDrop Premium';

  @override
  String get premiumBannerSubtitle => 'Unlock more friends and premium themes.';

  @override
  String get preferencesTitle => 'Preferences';

  @override
  String get habitRemindersSettingTitle => 'Habit Reminders';

  @override
  String get habitRemindersSettingSubtitle =>
      'Daily gentle nudges to complete your habits';

  @override
  String get schedulePreferencesTitle => 'Schedule & Preferences';

  @override
  String get schedulePreferencesSubtitle =>
      'Reminder time, recap day, and more';

  @override
  String get privacySharingTitle => 'Privacy & Sharing';

  @override
  String get profileSettingsDescFallback => 'Edit your name, avatar, and bio';

  @override
  String get friendsSettingsTitle => 'Friends';

  @override
  String get friendsSettingsSubtitle => 'Manage your accountability partners';

  @override
  String get visibilitySettingsTitle => 'Visibility';

  @override
  String get visibilitySettingsSubtitle => 'Current setting: Personal Only';

  @override
  String get signOutTitle => 'Sign Out';

  @override
  String get signOutSubtitle => 'Sign out of your account';

  @override
  String get signOutDialogMessage => 'Are you sure you want to sign out?';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get uploadAvatarFailed => 'Failed to upload avatar';

  @override
  String get profileNameEmpty => 'Name cannot be empty';

  @override
  String get deleteAccountDialogMessage =>
      'This permanently removes your profile, habits, proof moments, and private buddy data from DoneDrop. Subscription billing, if ever enabled later, must still be cancelled through the app store.';

  @override
  String get keepAccountAction => 'Keep account';

  @override
  String get verificationRequiredTitle => 'Verification required';

  @override
  String get verificationRequiredFallback =>
      'Could not verify your account. Please try again.';

  @override
  String get deleteFailedTitle => 'Delete failed';

  @override
  String get deleteFailedFallback => 'Failed to remove account data.';

  @override
  String get deleteIncompleteTitle => 'Delete incomplete';

  @override
  String get deleteIncompleteFallback =>
      'Account credentials could not be removed.';

  @override
  String get accountDeletedTitle => 'Account deleted';

  @override
  String get accountDeletedMessage =>
      'Your DoneDrop account has been removed from this device.';

  @override
  String get verifyWithGoogleTitle => 'Verify with Google';

  @override
  String get verifyWithGoogleMessage =>
      'To protect your account, continue with Google one more time before deletion.';

  @override
  String get unsupportedDeletionMethod =>
      'This sign-in method is not supported for in-app deletion yet. Sign in again with a supported method and retry.';

  @override
  String get confirmPasswordTitle => 'Confirm your password';

  @override
  String get currentPasswordHint => 'Enter your current password';

  @override
  String get reportTitle => 'Report';

  @override
  String get reportContentTitle => 'Report Content';

  @override
  String get reportContentSubtitle =>
      'Help us keep DoneDrop safe. Select a reason for reporting.';

  @override
  String get reportAdditionalDetailsHint => 'Additional details (optional)';

  @override
  String get submitReportAction => 'Submit Report';

  @override
  String get reportSubmittedTitle => 'Report Submitted';

  @override
  String get reportSubmittedMessage =>
      'Thank you for helping keep DoneDrop safe. We will review your report shortly.';

  @override
  String get reportReasonRequiredTitle => 'Please select a reason';

  @override
  String get reportSubmitFailedTitle => 'Failed to submit report';

  @override
  String get reportSubmitFailedMessage => 'Please try again.';

  @override
  String get weeklyRecapLoadFailed => 'Failed to load weekly recap';

  @override
  String get reportReasonInappropriate => 'Inappropriate content';

  @override
  String get reportReasonHarassment => 'Harassment or bullying';

  @override
  String get reportReasonSpam => 'Spam or misleading';

  @override
  String get reportReasonPrivacy => 'Privacy concern';

  @override
  String get reportReasonOther => 'Something else';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get checkYourEmailTitle => 'Check Your Email';

  @override
  String checkYourEmailMessage(String email) {
    return 'We sent a password reset link to\n$email.\nCheck your inbox and spam folder.';
  }

  @override
  String get backToSignInAction => 'Back to Sign In';

  @override
  String get sendResetLinkAction => 'Send Reset Link';

  @override
  String get forgotPasswordUnexpectedError =>
      'Something went wrong. Please try again.';

  @override
  String get forgotPasswordUserNotFound =>
      'No account found with this email address.';

  @override
  String get forgotPasswordInvalidEmail =>
      'Please enter a valid email address.';

  @override
  String get forgotPasswordUnableToSend =>
      'Unable to send reset email. Please try again.';

  @override
  String get premiumHiddenTitle => 'Premium is hidden in this build';

  @override
  String get premiumHiddenMessage =>
      'Store billing is not wired yet, so subscriptions stay unavailable until native purchases are ready.';

  @override
  String get premiumScreenTitle => 'Premium stays off until billing is real';

  @override
  String get premiumScreenSubtitle =>
      'This build removes fake purchase flows. When StoreKit and Play Billing are wired, pricing, restore, renewal, and cancellation details will appear here.';

  @override
  String get premiumWhatUnlocksTitle => 'What will unlock later';

  @override
  String get premiumWhatUnlocksSubtitle =>
      'Pricing, trial terms, restore, auto-renew disclosure, and manage subscription links will only ship together with native billing.';

  @override
  String get premiumBenefitUnlimitedFriendsTitle => 'Unlimited Friends';

  @override
  String get premiumBenefitUnlimitedFriendsDesc =>
      'Connect with all your accountability partners.';

  @override
  String get premiumBenefitAdvancedFiltersTitle => 'Advanced Filters';

  @override
  String get premiumBenefitAdvancedFiltersDesc =>
      'Search by mood, person, or subtle themes.';

  @override
  String get premiumBenefitCustomThemesTitle => 'Custom Recap Themes';

  @override
  String get premiumBenefitCustomThemesDesc =>
      'Exclusive editorial layouts for your memory books.';

  @override
  String get premiumBenefitHighResBackupsTitle => 'High-Res Backups';

  @override
  String get premiumBenefitHighResBackupsDesc =>
      'Lossless storage for every photo you treasure.';

  @override
  String get premiumUnavailableAction => 'Premium unavailable in this build';

  @override
  String get premiumFooterNote =>
      'Premium is intentionally hidden until store-compliant billing is implemented end to end.';

  @override
  String get momentSavedTitle => 'Moment saved';

  @override
  String get savedForSyncTitle => 'Saved for sync';

  @override
  String get proofCapturedMessage => 'Habit completed. Proof captured.';

  @override
  String get quietProofMessage => 'A quiet proof of your effort.';

  @override
  String get backToTodayAction => 'Back to Today';

  @override
  String get openBuddyAction => 'Open Buddy';

  @override
  String get capturePhotoRequired => 'No image selected';

  @override
  String get authRequiredMessage => 'You must be signed in';

  @override
  String get captureUnavailableTitle => 'Camera unavailable';

  @override
  String get captureUnavailableMessage =>
      'We couldn\'t open the proof camera. Please try again.';

  @override
  String get captureSelectBuddyError =>
      'Pick at least one buddy before sharing.';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String timeDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get visibilityCrew => 'Crew';

  @override
  String get visibilityBuddy => 'Buddy';

  @override
  String get visibilityPrivate => 'Private';

  @override
  String get visibilityFriends => 'Friends';

  @override
  String get visibilitySelected => 'Selected';

  @override
  String get visibilityPersonal => 'Personal';

  @override
  String momentPostFailed(String error) {
    return 'Failed to post moment: $error';
  }

  @override
  String get offlineSyncQueuedMessage =>
      'Will upload when you are back online.';

  @override
  String get captureOpeningProofCamera => 'Opening your proof camera…';

  @override
  String get captureMomentTitle => 'Capture moment';

  @override
  String get captureSourceCameraTitle => 'Camera';

  @override
  String get captureSourceCameraSubtitle => 'Proof is freshest right now.';

  @override
  String get captureSourceGalleryTitle => 'Gallery';

  @override
  String get captureSourceGallerySubtitle =>
      'Your recent wins are still waiting.';

  @override
  String get captureHeroProofBadge => 'Complete + proof';

  @override
  String get captureHeroMomentBadge => 'Save or share later';

  @override
  String get captureHeroProofTitle =>
      'Capture the proof while the win is fresh.';

  @override
  String get captureHeroMomentTitle => 'Add a photo when the moment matters.';

  @override
  String get captureHeroProofSubtitle =>
      'The habit only counts once you save a real photo as proof.';

  @override
  String get captureHeroMomentSubtitle =>
      'You can keep it private, attach it to a habit later, or share it with your buddy circle.';

  @override
  String get captureChooseSource => 'Choose source';

  @override
  String get previewProofTitle => 'Proof Preview';

  @override
  String get previewMomentTitle => 'Moment Preview';

  @override
  String get postAction => 'Post';

  @override
  String get previewProofBadge => 'Habit proof';

  @override
  String get previewMomentBadge => 'Private moment';

  @override
  String get previewProofSummaryTitle =>
      'Saving this proof will finish the habit.';

  @override
  String get previewMomentSummaryTitle =>
      'You can save this privately or share it with a small buddy circle.';

  @override
  String get previewProofSummarySubtitle =>
      'We\'ll mark the habit done, keep this image linked as proof, and sync everything as soon as it can.';

  @override
  String get previewMomentSummarySubtitle =>
      'Keep the loop simple: save only, add proof, or share privately.';

  @override
  String get previewProofCaptionHint => 'What did you finish?';

  @override
  String get previewMomentCaptionHint => 'Why does this moment matter?';

  @override
  String get captionLabel => 'Caption';

  @override
  String get categoryLabel => 'Category';

  @override
  String get noneLabel => 'None';

  @override
  String get audienceTitle => 'Who sees this';

  @override
  String get audienceOnlyMe => 'Only me';

  @override
  String get audienceSharePrivately => 'Share privately';

  @override
  String get audienceCloseCrew => 'Close crew';

  @override
  String get previewAddBuddyFirst =>
      'Add a buddy first to share proof privately.';

  @override
  String get confirmSignOutTitle => 'Confirm Sign Out';

  @override
  String get confirmSignOutMessage =>
      'Are you sure you want to sign out of your account?';

  @override
  String get confirmSignOutTabHint => 'Type to confirm';

  @override
  String get confirmSignOutPlaceholder => 'sign out';

  @override
  String get confirmDeleteAccountTitle => 'Delete Account';

  @override
  String get confirmDeleteAccountMessage =>
      'This will permanently delete your account and all associated data. This action cannot be undone.';

  @override
  String get confirmDeleteAccountTabHint => 'Type to confirm deletion';

  @override
  String get confirmDeleteAccountPlaceholder => 'delete my account';

  @override
  String get confirmFieldRequired => 'This field is required';

  @override
  String get confirmFieldMismatch => 'Text does not match. Please try again.';

  @override
  String get softDeleteInitiatedTitle => 'Account Scheduled for Deletion';

  @override
  String get softDeleteInitiatedMessage =>
      'Your account has been scheduled for deletion. You have 30 days to cancel this request by signing back in.';

  @override
  String get cancelRequestTitle => 'Cancel Request';

  @override
  String get cancelRequestMessage =>
      'Are you sure you want to cancel this request?';

  @override
  String get declineRequestTitle => 'Decline Request';

  @override
  String get declineRequestMessage =>
      'Are you sure you want to decline this request?';

  @override
  String get actionSuccess => 'Success';

  @override
  String get savedSuccessfully => 'Saved successfully';

  @override
  String get updatedSuccessfully => 'Updated successfully';

  @override
  String get removedSuccessfully => 'Removed successfully';

  @override
  String get actionFailed => 'Action failed';

  @override
  String get tryAgainLater => 'Please try again later';

  @override
  String get networkError => 'Network error. Please check your connection.';

  @override
  String get errorTitle => 'Error';

  @override
  String get successTitle => 'Success';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardPeriodToday => 'Today';

  @override
  String get leaderboardPeriodWeek => 'Week';

  @override
  String get leaderboardPeriodMonth => 'Month';

  @override
  String get leaderboardPeriodAll => 'All';

  @override
  String get leaderboardDoneLabel => 'done';

  @override
  String get leaderboardNoFriendsTitle => 'No friends yet';

  @override
  String get leaderboardNoFriendsSubtitle =>
      'Add friends to compete on the leaderboard.';

  @override
  String leaderboardDayStreak(int count) {
    return '$count day streak';
  }

  @override
  String get streakJourneyTitle => 'Streak Journey';

  @override
  String get streakActivityStreaksTitle => 'Activity Streaks';

  @override
  String get streakNoActivitiesYet =>
      'No activities yet. Create one to start your streak!';

  @override
  String get streakBestTitle => 'Your Best Streak';

  @override
  String get streakStartTitle => 'Start Your Streak!';

  @override
  String get streakBestStatLabel => 'Best';

  @override
  String get streakTotalStatLabel => 'Total';

  @override
  String get streakActiveStatLabel => 'Active';

  @override
  String get streakMilestoneRoadmapTitle => 'Milestone Roadmap';

  @override
  String streakDaysToGo(int count) {
    return '$count days to go';
  }

  @override
  String streakLastCompleted(Object value) {
    return 'Last: $value';
  }

  @override
  String streakBestShort(int count) {
    return 'best: ${count}d';
  }

  @override
  String get streakTodayShort => 'Today';

  @override
  String get streakYesterdayShort => 'Yesterday';

  @override
  String streakDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get streakDaysUnit => 'days';

  @override
  String get streakMilestoneGettingStarted => 'Getting Started';

  @override
  String get streakMilestoneOneWeek => 'One Week';

  @override
  String get streakMilestoneTwoWeeks => 'Two Weeks';

  @override
  String get streakMilestoneThreeWeeks => 'Three Weeks';

  @override
  String get streakMilestoneOneMonth => 'One Month';

  @override
  String get streakMilestoneTwoMonths => 'Two Months';

  @override
  String get streakMilestoneQuarter => 'Quarter';

  @override
  String get streakMilestoneCentury => 'Century';

  @override
  String get streakMilestoneHalfYear => 'Half Year';

  @override
  String get streakMilestoneOneYear => 'One Year';

  @override
  String get streakMilestoneReachedTitle => 'Milestone reached!';

  @override
  String get streakKeepGoingAction => 'Keep Going!';

  @override
  String get recapTitle => 'Your Week in Moments';

  @override
  String get recapQuote =>
      '\"You\'re building a beautiful life,\\none moment at a time.\"';

  @override
  String get recapMomentsStatLabel => 'MOMENTS';

  @override
  String get recapDayStreakStatLabel => 'DAY STREAK';

  @override
  String get recapNoMomentsYet => 'No moments this week yet.';

  @override
  String get recapShareTitle => 'Ready to share this story?';

  @override
  String get recapCaptureMomentAction => 'Capture a Moment';

  @override
  String get recapDisciplineActivitiesTitle => 'Discipline Activities';

  @override
  String get recapTodayLabel => 'Today';

  @override
  String get recapYesterdayLabel => 'Yesterday';

  @override
  String get myCodeTitle => 'My Code';

  @override
  String get myCodeSubtitle =>
      'Share this code with friends so they can add you.';

  @override
  String get scanCodeTitle => 'Scan Code';

  @override
  String get scanCodeSubtitle =>
      'Scan your friend\'s QR code to add them instantly.';

  @override
  String get addByIdTitle => 'Add by ID';

  @override
  String get addByIdSubtitle =>
      'Enter your friend\'s unique ID to send a buddy request.';

  @override
  String get userIdLabel => 'User ID';

  @override
  String get userIdHint => 'Enter their ID';

  @override
  String get findByIdAction => 'Find';

  @override
  String get findByEmailAction => 'Find by Email';

  @override
  String get shareCodeAction => 'Share my code';

  @override
  String get scanAction => 'Scan code';

  @override
  String get myCodeCopied => 'Code copied to clipboard';

  @override
  String get invalidCodeError => 'Invalid QR code';

  @override
  String get userNotFoundError => 'User not found';

  @override
  String get cantMessageSelfError => 'You cannot message yourself';

  @override
  String get onlyFriendsCanChatError => 'You can only chat with friends';

  @override
  String get selectAddMethod => 'Add friends via';
}
