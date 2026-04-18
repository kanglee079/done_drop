import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'DoneDrop'**
  String get appName;

  /// No description provided for @memberFallbackName.
  ///
  /// In en, this message translates to:
  /// **'DoneDrop member'**
  String get memberFallbackName;

  /// No description provided for @greetingFallbackName.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get greetingFallbackName;

  /// No description provided for @authTagline.
  ///
  /// In en, this message translates to:
  /// **'Complete it. Capture it.\nShare the moment.'**
  String get authTagline;

  /// No description provided for @todayTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTabTitle;

  /// No description provided for @todayTabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discipline stays visible.'**
  String get todayTabSubtitle;

  /// No description provided for @buddyTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Buddy'**
  String get buddyTabTitle;

  /// No description provided for @buddyTabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Private proof from your circle.'**
  String get buddyTabSubtitle;

  /// No description provided for @wallTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Wall'**
  String get wallTabTitle;

  /// No description provided for @wallTabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your archive, grouped by memory.'**
  String get wallTabSubtitle;

  /// No description provided for @meTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get meTabTitle;

  /// No description provided for @meTabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stats, reminders, and settings.'**
  String get meTabSubtitle;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// No description provided for @welcomeGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get welcomeGetStarted;

  /// No description provided for @welcomeContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get welcomeContinue;

  /// No description provided for @welcomeDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get welcomeDone;

  /// No description provided for @onboardingHeadline.
  ///
  /// In en, this message translates to:
  /// **'Hold yourself accountable.\nComplete your habits. Prove it.'**
  String get onboardingHeadline;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build habits. Complete them. Capture proof. Share privately with accountability partners.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingUseCaseTitle.
  ///
  /// In en, this message translates to:
  /// **'WHAT BRINGS YOU HERE?'**
  String get onboardingUseCaseTitle;

  /// No description provided for @captureProofTitle.
  ///
  /// In en, this message translates to:
  /// **'Capture proof'**
  String get captureProofTitle;

  /// No description provided for @captureProofSubtitle.
  ///
  /// In en, this message translates to:
  /// **'DoneDrop needs camera access to capture proof moments. Your photos stay private until you choose to share them.'**
  String get captureProofSubtitle;

  /// No description provided for @privateByDefault.
  ///
  /// In en, this message translates to:
  /// **'Private by default'**
  String get privateByDefault;

  /// No description provided for @privateByDefaultDesc.
  ///
  /// In en, this message translates to:
  /// **'You control who sees your proof moments.'**
  String get privateByDefaultDesc;

  /// No description provided for @secureByDefault.
  ///
  /// In en, this message translates to:
  /// **'End-to-end secure'**
  String get secureByDefault;

  /// No description provided for @secureByDefaultDesc.
  ///
  /// In en, this message translates to:
  /// **'Your accountability data stays yours.'**
  String get secureByDefaultDesc;

  /// No description provided for @gentleRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Gentle reminders'**
  String get gentleRemindersTitle;

  /// No description provided for @gentleRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Optional nudges to complete your habits.'**
  String get gentleRemindersDesc;

  /// No description provided for @proofOnlyWhenYouChoose.
  ///
  /// In en, this message translates to:
  /// **'Only when it matters'**
  String get proofOnlyWhenYouChoose;

  /// No description provided for @proofOnlyWhenYouChooseDesc.
  ///
  /// In en, this message translates to:
  /// **'Attach proof only when the habit deserves it.'**
  String get proofOnlyWhenYouChooseDesc;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'friend@example.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get fullNameHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get confirmPasswordHint;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start capturing your done moments today.'**
  String get createAccountSubtitle;

  /// No description provided for @signInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInAction;

  /// No description provided for @signUpAction.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpAction;

  /// No description provided for @createAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountAction;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @forgotPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordAction;

  /// No description provided for @orLabel.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orLabel;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccountPrompt;

  /// No description provided for @alreadyHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccountPrompt;

  /// No description provided for @termsAgreementPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get termsAgreementPrefix;

  /// No description provided for @createTermsAgreementPrefix.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our '**
  String get createTermsAgreementPrefix;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @andLabel.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get andLabel;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameRequired;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameTooShort;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @confirmPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get confirmPasswordMismatch;

  /// No description provided for @todayGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi {name}'**
  String todayGreeting(String name);

  /// No description provided for @todayIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep today simple and visible.'**
  String get todayIntroTitle;

  /// No description provided for @todayIntroProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} habits finished so far.'**
  String todayIntroProgress(int completed, int total);

  /// No description provided for @summaryDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get summaryDone;

  /// No description provided for @summaryToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get summaryToday;

  /// No description provided for @summaryBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get summaryBestStreak;

  /// No description provided for @summaryDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get summaryDays;

  /// No description provided for @summaryBuddies.
  ///
  /// In en, this message translates to:
  /// **'Buddies'**
  String get summaryBuddies;

  /// No description provided for @summaryPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get summaryPrivate;

  /// No description provided for @nextUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Next up'**
  String get nextUpTitle;

  /// No description provided for @nextUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The one habit to finish before the rest of the day slips away.'**
  String get nextUpSubtitle;

  /// No description provided for @overdueTitle.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdueTitle;

  /// No description provided for @overdueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recover these before tomorrow starts.'**
  String get overdueSubtitle;

  /// No description provided for @laterTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Later today'**
  String get laterTodayTitle;

  /// No description provided for @laterTodayEmpty.
  ///
  /// In en, this message translates to:
  /// **'No extra habits queued after your next priority.'**
  String get laterTodayEmpty;

  /// No description provided for @laterTodayFilled.
  ///
  /// In en, this message translates to:
  /// **'Keep the rest of the day glanceable.'**
  String get laterTodayFilled;

  /// No description provided for @capturedTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Captured today'**
  String get capturedTodayTitle;

  /// No description provided for @capturedTodaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Proof moments and finished habits from this session.'**
  String get capturedTodaySubtitle;

  /// No description provided for @weeklyRecapTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly recap'**
  String get weeklyRecapTitle;

  /// No description provided for @weeklyRecapOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get weeklyRecapOpen;

  /// No description provided for @weeklyRecapSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} habit completions logged in the last 7 days.'**
  String weeklyRecapSummary(int count);

  /// No description provided for @needNewHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Need a new habit?'**
  String get needNewHabitTitle;

  /// No description provided for @needNewHabitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add it while the standard is clear.'**
  String get needNewHabitSubtitle;

  /// No description provided for @addAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addAction;

  /// No description provided for @addHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a habit'**
  String get addHabitTitle;

  /// No description provided for @addHabitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep it specific enough that you know exactly what “done” means.'**
  String get addHabitSubtitle;

  /// No description provided for @habitNameHint.
  ///
  /// In en, this message translates to:
  /// **'Habit name'**
  String get habitNameHint;

  /// No description provided for @habitCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Category (optional)'**
  String get habitCategoryHint;

  /// No description provided for @habitTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get habitTimeLabel;

  /// No description provided for @pickTimeAction.
  ///
  /// In en, this message translates to:
  /// **'Pick time'**
  String get pickTimeAction;

  /// No description provided for @createHabitAction.
  ///
  /// In en, this message translates to:
  /// **'Create habit'**
  String get createHabitAction;

  /// No description provided for @emptyTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with one standard.'**
  String get emptyTodayTitle;

  /// No description provided for @emptyTodaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create the first habit you want to prove to yourself today.'**
  String get emptyTodaySubtitle;

  /// No description provided for @createFirstHabitAction.
  ///
  /// In en, this message translates to:
  /// **'Create first habit'**
  String get createFirstHabitAction;

  /// No description provided for @nothingCapturedTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing captured yet'**
  String get nothingCapturedTitle;

  /// No description provided for @nothingCapturedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete a habit and attach proof when it adds meaning.'**
  String get nothingCapturedSubtitle;

  /// No description provided for @capturedProofAttached.
  ///
  /// In en, this message translates to:
  /// **'Proof attached'**
  String get capturedProofAttached;

  /// No description provided for @capturedSavedOnly.
  ///
  /// In en, this message translates to:
  /// **'Saved only'**
  String get capturedSavedOnly;

  /// No description provided for @allHabitsHandledTitle.
  ///
  /// In en, this message translates to:
  /// **'All habits handled'**
  String get allHabitsHandledTitle;

  /// No description provided for @allHabitsHandledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are clear for the day. Capture proof if a win deserves it.'**
  String get allHabitsHandledSubtitle;

  /// No description provided for @onlyOneThingLeftTitle.
  ///
  /// In en, this message translates to:
  /// **'Only one thing left'**
  String get onlyOneThingLeftTitle;

  /// No description provided for @onlyOneThingLeftSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Finish your hero habit and you are done for today.'**
  String get onlyOneThingLeftSubtitle;

  /// No description provided for @heroOverdueNow.
  ///
  /// In en, this message translates to:
  /// **'Overdue now'**
  String get heroOverdueNow;

  /// No description provided for @heroNextUp.
  ///
  /// In en, this message translates to:
  /// **'Next up'**
  String get heroNextUp;

  /// No description provided for @heroProofAttached.
  ///
  /// In en, this message translates to:
  /// **'Proof attached'**
  String get heroProofAttached;

  /// No description provided for @heroPrivateByDefault.
  ///
  /// In en, this message translates to:
  /// **'Private by default'**
  String get heroPrivateByDefault;

  /// No description provided for @heroNeedsRecovery.
  ///
  /// In en, this message translates to:
  /// **'Needs recovery'**
  String get heroNeedsRecovery;

  /// No description provided for @heroOneTapToFinish.
  ///
  /// In en, this message translates to:
  /// **'Photo required to finish'**
  String get heroOneTapToFinish;

  /// No description provided for @heroCompletedWithProof.
  ///
  /// In en, this message translates to:
  /// **'Completed with proof today'**
  String get heroCompletedWithProof;

  /// No description provided for @heroCompletedToday.
  ///
  /// In en, this message translates to:
  /// **'Completed today'**
  String get heroCompletedToday;

  /// No description provided for @completeNowAction.
  ///
  /// In en, this message translates to:
  /// **'Complete now'**
  String get completeNowAction;

  /// No description provided for @completeWithProofAction.
  ///
  /// In en, this message translates to:
  /// **'Finish with photo'**
  String get completeWithProofAction;

  /// No description provided for @proofLabel.
  ///
  /// In en, this message translates to:
  /// **'Proof'**
  String get proofLabel;

  /// No description provided for @themeSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme & settings'**
  String get themeSettingsTitle;

  /// No description provided for @themeSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App preferences and personal controls.'**
  String get themeSettingsSubtitle;

  /// No description provided for @statsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsSectionTitle;

  /// No description provided for @statsSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The numbers that matter right now.'**
  String get statsSectionSubtitle;

  /// No description provided for @weeklyWinsLabel.
  ///
  /// In en, this message translates to:
  /// **'Weekly wins'**
  String get weeklyWinsLabel;

  /// No description provided for @activeHabitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Active habits'**
  String get activeHabitsLabel;

  /// No description provided for @remindersSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersSectionTitle;

  /// No description provided for @remindersSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the discipline loop visible.'**
  String get remindersSectionSubtitle;

  /// No description provided for @habitRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit reminders'**
  String get habitRemindersTitle;

  /// No description provided for @habitRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} habits currently have reminders.'**
  String habitRemindersSubtitle(int count);

  /// No description provided for @archivedHabitsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived habits'**
  String get archivedHabitsSectionTitle;

  /// No description provided for @archivedHabitsSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Standards you have paused, not deleted.'**
  String get archivedHabitsSectionSubtitle;

  /// No description provided for @noArchivedHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'No archived habits'**
  String get noArchivedHabitsTitle;

  /// No description provided for @noArchivedHabitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Standards you pause will show here.'**
  String get noArchivedHabitsSubtitle;

  /// No description provided for @archivedHabitFallback.
  ///
  /// In en, this message translates to:
  /// **'Archived habit'**
  String get archivedHabitFallback;

  /// No description provided for @restoreAction.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreAction;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Using system theme'**
  String get themeSubtitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display name, username, avatar'**
  String get profileSubtitle;

  /// No description provided for @buddyCircleTitle.
  ///
  /// In en, this message translates to:
  /// **'Buddy circle'**
  String get buddyCircleTitle;

  /// No description provided for @buddyCircleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite, remove, and manage close accountability friends'**
  String get buddyCircleSubtitle;

  /// No description provided for @privacySupportSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & support'**
  String get privacySupportSectionTitle;

  /// No description provided for @privacySupportSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Policies, help, and release details.'**
  String get privacySupportSectionSubtitle;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read how DoneDrop handles your account and moment data'**
  String get privacyPolicySubtitle;

  /// No description provided for @termsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The rules for using DoneDrop and private buddy features'**
  String get termsSubtitle;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTitle;

  /// No description provided for @supportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Report an issue or get help from inside the app'**
  String get supportSubtitle;

  /// No description provided for @appVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersionTitle;

  /// No description provided for @accountActionsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Account actions'**
  String get accountActionsSectionTitle;

  /// No description provided for @accountActionsSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out, or permanently remove this account.'**
  String get accountActionsSectionSubtitle;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your profile, habits, and moments'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountRemovingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Removing your account data...'**
  String get deleteAccountRemovingSubtitle;

  /// No description provided for @signOutAction.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutAction;

  /// No description provided for @themeSettingsSnackbarTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme settings'**
  String get themeSettingsSnackbarTitle;

  /// No description provided for @themeSettingsSnackbarMessage.
  ///
  /// In en, this message translates to:
  /// **'Theme controls are currently following your system setting.'**
  String get themeSettingsSnackbarMessage;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your first 3 habits'**
  String get setupTitle;

  /// No description provided for @setupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Give today structure before you land on the home screen.'**
  String get setupSubtitle;

  /// No description provided for @setupHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit {index}'**
  String setupHabitTitle(int index);

  /// No description provided for @setupHabitPrompt.
  ///
  /// In en, this message translates to:
  /// **'What do you want to show up for?'**
  String get setupHabitPrompt;

  /// No description provided for @setupHabitTimePrompt.
  ///
  /// In en, this message translates to:
  /// **'When should it show up today?'**
  String get setupHabitTimePrompt;

  /// No description provided for @setupPrimaryAction.
  ///
  /// In en, this message translates to:
  /// **'Start my day'**
  String get setupPrimaryAction;

  /// No description provided for @setupValidationError.
  ///
  /// In en, this message translates to:
  /// **'Create all 3 habits before continuing.'**
  String get setupValidationError;

  /// No description provided for @setupSaveError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your first habits. Please try again.'**
  String get setupSaveError;

  /// No description provided for @setupMorningDefault.
  ///
  /// In en, this message translates to:
  /// **'Drink water'**
  String get setupMorningDefault;

  /// No description provided for @setupMiddayDefault.
  ///
  /// In en, this message translates to:
  /// **'Walk for 10 minutes'**
  String get setupMiddayDefault;

  /// No description provided for @setupEveningDefault.
  ///
  /// In en, this message translates to:
  /// **'Read 20 pages'**
  String get setupEveningDefault;

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @closeAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @removeAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAction;

  /// No description provided for @doneAction.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneAction;

  /// No description provided for @searchAction.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchAction;

  /// No description provided for @verifyAction.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyAction;

  /// No description provided for @genericErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get genericErrorTitle;

  /// No description provided for @statusPreviewOnly.
  ///
  /// In en, this message translates to:
  /// **'Preview only'**
  String get statusPreviewOnly;

  /// No description provided for @statusQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get statusQueued;

  /// No description provided for @statusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get statusPreparing;

  /// No description provided for @statusUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading {progress}%'**
  String statusUploading(int progress);

  /// No description provided for @statusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get statusSyncing;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get statusPosted;

  /// No description provided for @uploadStagePreparingImage.
  ///
  /// In en, this message translates to:
  /// **'Preparing image…'**
  String get uploadStagePreparingImage;

  /// No description provided for @uploadStageFinalizingMoment.
  ///
  /// In en, this message translates to:
  /// **'Finalizing moment…'**
  String get uploadStageFinalizingMoment;

  /// No description provided for @uploadReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get uploadReady;

  /// No description provided for @buddyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your buddy feed is private by design.'**
  String get buddyEmptyTitle;

  /// No description provided for @buddyEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite a few close people you trust to keep the proof loop intimate.'**
  String get buddyEmptySubtitle;

  /// No description provided for @buddyViewWallAction.
  ///
  /// In en, this message translates to:
  /// **'Open wall'**
  String get buddyViewWallAction;

  /// No description provided for @inviteBuddyAction.
  ///
  /// In en, this message translates to:
  /// **'Invite buddy'**
  String get inviteBuddyAction;

  /// No description provided for @manageCircleAction.
  ///
  /// In en, this message translates to:
  /// **'Manage circle ({count})'**
  String manageCircleAction(int count);

  /// No description provided for @wallSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every proof you kept, including the ones you shared.'**
  String get wallSectionSubtitle;

  /// No description provided for @wallLeadFallback.
  ///
  /// In en, this message translates to:
  /// **'A kept promise from {date}'**
  String wallLeadFallback(String date);

  /// No description provided for @wallTileFallback.
  ///
  /// In en, this message translates to:
  /// **'Saved to your archive'**
  String get wallTileFallback;

  /// No description provided for @wallEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep one promise.'**
  String get wallEmptyTitle;

  /// No description provided for @wallEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'The wall grows from there, one kept standard at a time.'**
  String get wallEmptySubtitle;

  /// No description provided for @buddyWallTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s wall'**
  String buddyWallTitle(String name);

  /// No description provided for @buddyWallHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} shared proof moments you can revisit.'**
  String buddyWallHeroSubtitle(int count);

  /// No description provided for @buddyWallEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing shared yet.'**
  String get buddyWallEmptyTitle;

  /// No description provided for @buddyWallEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{name} hasn\'t shared a proof moment with you yet.'**
  String buddyWallEmptySubtitle(String name);

  /// No description provided for @reactionLoveLabel.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get reactionLoveLabel;

  /// No description provided for @reactionCelebrateLabel.
  ///
  /// In en, this message translates to:
  /// **'Celebrate'**
  String get reactionCelebrateLabel;

  /// No description provided for @reactionInspiringLabel.
  ///
  /// In en, this message translates to:
  /// **'Inspiring'**
  String get reactionInspiringLabel;

  /// No description provided for @friendFeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Friend Feed'**
  String get friendFeedTitle;

  /// No description provided for @markAllReadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllReadTooltip;

  /// No description provided for @feedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No moments yet'**
  String get feedEmptyTitle;

  /// No description provided for @feedEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Moments shared by your friends\nwill appear here.'**
  String get feedEmptySubtitle;

  /// No description provided for @addFriendsAction.
  ///
  /// In en, this message translates to:
  /// **'Add Friends'**
  String get addFriendsAction;

  /// No description provided for @memoryWallTitle.
  ///
  /// In en, this message translates to:
  /// **'Memory Wall'**
  String get memoryWallTitle;

  /// No description provided for @memoryWallAllFilter.
  ///
  /// In en, this message translates to:
  /// **'All moments'**
  String get memoryWallAllFilter;

  /// No description provided for @memoryWallEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No moments yet'**
  String get memoryWallEmptyTitle;

  /// No description provided for @memoryWallEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your archive of kept promises\nwill appear here.'**
  String get memoryWallEmptySubtitle;

  /// No description provided for @createFirstMomentAction.
  ///
  /// In en, this message translates to:
  /// **'Create your first moment'**
  String get createFirstMomentAction;

  /// No description provided for @deleteMomentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Moment'**
  String get deleteMomentTitle;

  /// No description provided for @deleteMomentMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this moment?'**
  String get deleteMomentMessage;

  /// No description provided for @buddyCrewTitle.
  ///
  /// In en, this message translates to:
  /// **'Buddy Crew'**
  String get buddyCrewTitle;

  /// No description provided for @crewTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get crewTabLabel;

  /// No description provided for @crewTabCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Crew ({count}/{limit})'**
  String crewTabCountLabel(int count, int limit);

  /// No description provided for @requestsTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestsTabLabel;

  /// No description provided for @noFriendsYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get noFriendsYetTitle;

  /// No description provided for @noFriendsYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add some buddies to keep you accountable.'**
  String get noFriendsYetSubtitle;

  /// No description provided for @addFriendAction.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get addFriendAction;

  /// No description provided for @removeFriendTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Friend'**
  String get removeFriendTitle;

  /// No description provided for @removeFriendMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove this friend?'**
  String get removeFriendMessage;

  /// No description provided for @noPendingRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noPendingRequestsTitle;

  /// No description provided for @noPendingRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Incoming and outgoing requests appear here.'**
  String get noPendingRequestsSubtitle;

  /// No description provided for @incomingSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'INCOMING'**
  String get incomingSectionLabel;

  /// No description provided for @sentSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'SENT'**
  String get sentSectionLabel;

  /// No description provided for @friendRequestIncomingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Wants to be your friend'**
  String get friendRequestIncomingSubtitle;

  /// No description provided for @friendRequestSentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent'**
  String get friendRequestSentSubtitle;

  /// No description provided for @friendAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'Friend added'**
  String get friendAddedTitle;

  /// No description provided for @friendAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} is now your friend'**
  String friendAddedMessage(String name);

  /// No description provided for @friendRemovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Friend removed'**
  String get friendRemovedTitle;

  /// No description provided for @friendRemovedMessage.
  ///
  /// In en, this message translates to:
  /// **'The friendship has been removed'**
  String get friendRemovedMessage;

  /// No description provided for @addBuddyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Buddy'**
  String get addBuddyTitle;

  /// No description provided for @findByUsernameTitle.
  ///
  /// In en, this message translates to:
  /// **'Find by Username'**
  String get findByUsernameTitle;

  /// No description provided for @findByUsernameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter their username to send a buddy request.'**
  String get findByUsernameSubtitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'johndoe'**
  String get usernameHint;

  /// No description provided for @buddyLimitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Buddy Limit Reached'**
  String get buddyLimitReachedTitle;

  /// No description provided for @buddyLimitReachedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free plan allows up to {limit} buddies. Upgrade for more.'**
  String buddyLimitReachedSubtitle(int limit);

  /// No description provided for @enterUsernameError.
  ///
  /// In en, this message translates to:
  /// **'Enter a username'**
  String get enterUsernameError;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameTooShort;

  /// No description provided for @ownUsernameError.
  ///
  /// In en, this message translates to:
  /// **'That is your own username'**
  String get ownUsernameError;

  /// No description provided for @friendCapReachedError.
  ///
  /// In en, this message translates to:
  /// **'You have reached the maximum of {limit} friends.'**
  String friendCapReachedError(int limit);

  /// No description provided for @requestSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Sent'**
  String get requestSentTitle;

  /// No description provided for @requestSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent to {name}'**
  String requestSentMessage(String name);

  /// No description provided for @sendBuddyRequestPrompt.
  ///
  /// In en, this message translates to:
  /// **'Send a buddy request?'**
  String get sendBuddyRequestPrompt;

  /// No description provided for @sendBuddyRequestAction.
  ///
  /// In en, this message translates to:
  /// **'Send Buddy Request'**
  String get sendBuddyRequestAction;

  /// No description provided for @requestSentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Sent!'**
  String get requestSentSuccessTitle;

  /// No description provided for @requestSentSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Buddy request sent to {name}'**
  String requestSentSuccessMessage(String name);

  /// No description provided for @addAnotherBuddyAction.
  ///
  /// In en, this message translates to:
  /// **'Add Another Buddy'**
  String get addAnotherBuddyAction;

  /// No description provided for @chatOpenAction.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatOpenAction;

  /// No description provided for @chatScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Private conversation with this buddy.'**
  String get chatScreenSubtitle;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the accountability loop private and clear.'**
  String get chatEmptySubtitle;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Send a message...'**
  String get chatInputHint;

  /// No description provided for @chatSendAction.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSendAction;

  /// No description provided for @profileFieldDisplayName.
  ///
  /// In en, this message translates to:
  /// **'DISPLAY NAME'**
  String get profileFieldDisplayName;

  /// No description provided for @profileFieldBio.
  ///
  /// In en, this message translates to:
  /// **'BIO'**
  String get profileFieldBio;

  /// No description provided for @profileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get profileNameHint;

  /// No description provided for @profileBioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell your friends a little about yourself'**
  String get profileBioHint;

  /// No description provided for @dangerZoneLabel.
  ///
  /// In en, this message translates to:
  /// **'DANGER ZONE'**
  String get dangerZoneLabel;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationSettingsTitle;

  /// No description provided for @notificationCenterEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get notificationCenterEmptyTitle;

  /// No description provided for @notificationCenterEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Friend requests and new buddy moments will show up here.'**
  String get notificationCenterEmptySubtitle;

  /// No description provided for @notificationPermissionOffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so DoneDrop can alert you at each task\'s exact time.'**
  String get notificationPermissionOffSubtitle;

  /// No description provided for @notificationExactAlarmOffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable exact alarms so Android can fire reminders at the precise minute on this device.'**
  String get notificationExactAlarmOffSubtitle;

  /// No description provided for @momentRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Moment Reminders'**
  String get momentRemindersTitle;

  /// No description provided for @momentRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get a gentle daily nudge to capture your moment.'**
  String get momentRemindersSubtitle;

  /// No description provided for @notificationReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get notificationReminderTitle;

  /// No description provided for @notificationReminderDesc.
  ///
  /// In en, this message translates to:
  /// **'Toggle daily reminder on/off'**
  String get notificationReminderDesc;

  /// No description provided for @notificationTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get notificationTimeTitle;

  /// No description provided for @weeklyRecapSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Recap'**
  String get weeklyRecapSettingsTitle;

  /// No description provided for @weeklyRecapSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive a weekly summary of your moments.'**
  String get weeklyRecapSettingsSubtitle;

  /// No description provided for @weeklyRecapToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Recap'**
  String get weeklyRecapToggleTitle;

  /// No description provided for @weeklyRecapToggleDesc.
  ///
  /// In en, this message translates to:
  /// **'Toggle weekly recap on/off'**
  String get weeklyRecapToggleDesc;

  /// No description provided for @notificationDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get notificationDayTitle;

  /// No description provided for @requestNotificationPermissionAction.
  ///
  /// In en, this message translates to:
  /// **'Request Notification Permission'**
  String get requestNotificationPermissionAction;

  /// No description provided for @selectDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Day'**
  String get selectDayTitle;

  /// No description provided for @dayMonShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMonShort;

  /// No description provided for @dayTueShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTueShort;

  /// No description provided for @dayWedShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWedShort;

  /// No description provided for @dayThuShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThuShort;

  /// No description provided for @dayFriShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFriShort;

  /// No description provided for @daySatShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySatShort;

  /// No description provided for @daySunShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySunShort;

  /// No description provided for @settingsArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'The Archive'**
  String get settingsArchiveTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Curate your personal experience'**
  String get settingsSubtitle;

  /// No description provided for @premiumBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'DoneDrop Premium'**
  String get premiumBannerTitle;

  /// No description provided for @premiumBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock more friends and premium themes.'**
  String get premiumBannerSubtitle;

  /// No description provided for @preferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesTitle;

  /// No description provided for @habitRemindersSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit Reminders'**
  String get habitRemindersSettingTitle;

  /// No description provided for @habitRemindersSettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily gentle nudges to complete your habits'**
  String get habitRemindersSettingSubtitle;

  /// No description provided for @schedulePreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule & Preferences'**
  String get schedulePreferencesTitle;

  /// No description provided for @schedulePreferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder time, recap day, and more'**
  String get schedulePreferencesSubtitle;

  /// No description provided for @privacySharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Sharing'**
  String get privacySharingTitle;

  /// No description provided for @profileSettingsDescFallback.
  ///
  /// In en, this message translates to:
  /// **'Edit your name, avatar, and bio'**
  String get profileSettingsDescFallback;

  /// No description provided for @friendsSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsSettingsTitle;

  /// No description provided for @friendsSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your accountability partners'**
  String get friendsSettingsSubtitle;

  /// No description provided for @visibilitySettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibilitySettingsTitle;

  /// No description provided for @visibilitySettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Current setting: Personal Only'**
  String get visibilitySettingsSubtitle;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutTitle;

  /// No description provided for @signOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get signOutSubtitle;

  /// No description provided for @signOutDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutDialogMessage;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @uploadAvatarFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload avatar'**
  String get uploadAvatarFailed;

  /// No description provided for @profileNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get profileNameEmpty;

  /// No description provided for @deleteAccountDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes your profile, habits, proof moments, and private buddy data from DoneDrop. Subscription billing, if ever enabled later, must still be cancelled through the app store.'**
  String get deleteAccountDialogMessage;

  /// No description provided for @keepAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Keep account'**
  String get keepAccountAction;

  /// No description provided for @verificationRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification required'**
  String get verificationRequiredTitle;

  /// No description provided for @verificationRequiredFallback.
  ///
  /// In en, this message translates to:
  /// **'Could not verify your account. Please try again.'**
  String get verificationRequiredFallback;

  /// No description provided for @deleteFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get deleteFailedTitle;

  /// No description provided for @deleteFailedFallback.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove account data.'**
  String get deleteFailedFallback;

  /// No description provided for @deleteIncompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete incomplete'**
  String get deleteIncompleteTitle;

  /// No description provided for @deleteIncompleteFallback.
  ///
  /// In en, this message translates to:
  /// **'Account credentials could not be removed.'**
  String get deleteIncompleteFallback;

  /// No description provided for @accountDeletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeletedTitle;

  /// No description provided for @accountDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your DoneDrop account has been removed from this device.'**
  String get accountDeletedMessage;

  /// No description provided for @verifyWithGoogleTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify with Google'**
  String get verifyWithGoogleTitle;

  /// No description provided for @verifyWithGoogleMessage.
  ///
  /// In en, this message translates to:
  /// **'To protect your account, continue with Google one more time before deletion.'**
  String get verifyWithGoogleMessage;

  /// No description provided for @unsupportedDeletionMethod.
  ///
  /// In en, this message translates to:
  /// **'This sign-in method is not supported for in-app deletion yet. Sign in again with a supported method and retry.'**
  String get unsupportedDeletionMethod;

  /// No description provided for @confirmPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmPasswordTitle;

  /// No description provided for @currentPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get currentPasswordHint;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportTitle;

  /// No description provided for @reportContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Content'**
  String get reportContentTitle;

  /// No description provided for @reportContentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us keep DoneDrop safe. Select a reason for reporting.'**
  String get reportContentSubtitle;

  /// No description provided for @reportAdditionalDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Additional details (optional)'**
  String get reportAdditionalDetailsHint;

  /// No description provided for @submitReportAction.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReportAction;

  /// No description provided for @reportSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Submitted'**
  String get reportSubmittedTitle;

  /// No description provided for @reportSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for helping keep DoneDrop safe. We will review your report shortly.'**
  String get reportSubmittedMessage;

  /// No description provided for @reportReasonRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason'**
  String get reportReasonRequiredTitle;

  /// No description provided for @reportSubmitFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit report'**
  String get reportSubmitFailedTitle;

  /// No description provided for @reportSubmitFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get reportSubmitFailedMessage;

  /// No description provided for @weeklyRecapLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load weekly recap'**
  String get weeklyRecapLoadFailed;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment or bullying'**
  String get reportReasonHarassment;

  /// No description provided for @reportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam or misleading'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy concern'**
  String get reportReasonPrivacy;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get reportReasonOther;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @checkYourEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get checkYourEmailTitle;

  /// No description provided for @checkYourEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'We sent a password reset link to\n{email}.\nCheck your inbox and spam folder.'**
  String checkYourEmailMessage(String email);

  /// No description provided for @backToSignInAction.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignInAction;

  /// No description provided for @sendResetLinkAction.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLinkAction;

  /// No description provided for @forgotPasswordUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get forgotPasswordUnexpectedError;

  /// No description provided for @forgotPasswordUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email address.'**
  String get forgotPasswordUserNotFound;

  /// No description provided for @forgotPasswordInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get forgotPasswordInvalidEmail;

  /// No description provided for @forgotPasswordUnableToSend.
  ///
  /// In en, this message translates to:
  /// **'Unable to send reset email. Please try again.'**
  String get forgotPasswordUnableToSend;

  /// No description provided for @premiumHiddenTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium is hidden in this build'**
  String get premiumHiddenTitle;

  /// No description provided for @premiumHiddenMessage.
  ///
  /// In en, this message translates to:
  /// **'Store billing is not wired yet, so subscriptions stay unavailable until native purchases are ready.'**
  String get premiumHiddenMessage;

  /// No description provided for @premiumScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium stays off until billing is real'**
  String get premiumScreenTitle;

  /// No description provided for @premiumScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This build removes fake purchase flows. When StoreKit and Play Billing are wired, pricing, restore, renewal, and cancellation details will appear here.'**
  String get premiumScreenSubtitle;

  /// No description provided for @premiumWhatUnlocksTitle.
  ///
  /// In en, this message translates to:
  /// **'What will unlock later'**
  String get premiumWhatUnlocksTitle;

  /// No description provided for @premiumWhatUnlocksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pricing, trial terms, restore, auto-renew disclosure, and manage subscription links will only ship together with native billing.'**
  String get premiumWhatUnlocksSubtitle;

  /// No description provided for @premiumBenefitUnlimitedFriendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Friends'**
  String get premiumBenefitUnlimitedFriendsTitle;

  /// No description provided for @premiumBenefitUnlimitedFriendsDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect with all your accountability partners.'**
  String get premiumBenefitUnlimitedFriendsDesc;

  /// No description provided for @premiumBenefitAdvancedFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get premiumBenefitAdvancedFiltersTitle;

  /// No description provided for @premiumBenefitAdvancedFiltersDesc.
  ///
  /// In en, this message translates to:
  /// **'Search by mood, person, or subtle themes.'**
  String get premiumBenefitAdvancedFiltersDesc;

  /// No description provided for @premiumBenefitCustomThemesTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Recap Themes'**
  String get premiumBenefitCustomThemesTitle;

  /// No description provided for @premiumBenefitCustomThemesDesc.
  ///
  /// In en, this message translates to:
  /// **'Exclusive editorial layouts for your memory books.'**
  String get premiumBenefitCustomThemesDesc;

  /// No description provided for @premiumBenefitHighResBackupsTitle.
  ///
  /// In en, this message translates to:
  /// **'High-Res Backups'**
  String get premiumBenefitHighResBackupsTitle;

  /// No description provided for @premiumBenefitHighResBackupsDesc.
  ///
  /// In en, this message translates to:
  /// **'Lossless storage for every photo you treasure.'**
  String get premiumBenefitHighResBackupsDesc;

  /// No description provided for @premiumUnavailableAction.
  ///
  /// In en, this message translates to:
  /// **'Premium unavailable in this build'**
  String get premiumUnavailableAction;

  /// No description provided for @premiumFooterNote.
  ///
  /// In en, this message translates to:
  /// **'Premium is intentionally hidden until store-compliant billing is implemented end to end.'**
  String get premiumFooterNote;

  /// No description provided for @momentSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Moment saved'**
  String get momentSavedTitle;

  /// No description provided for @savedForSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved for sync'**
  String get savedForSyncTitle;

  /// No description provided for @proofCapturedMessage.
  ///
  /// In en, this message translates to:
  /// **'Habit completed. Proof captured.'**
  String get proofCapturedMessage;

  /// No description provided for @quietProofMessage.
  ///
  /// In en, this message translates to:
  /// **'A quiet proof of your effort.'**
  String get quietProofMessage;

  /// No description provided for @backToTodayAction.
  ///
  /// In en, this message translates to:
  /// **'Back to Today'**
  String get backToTodayAction;

  /// No description provided for @openBuddyAction.
  ///
  /// In en, this message translates to:
  /// **'Open Buddy'**
  String get openBuddyAction;

  /// No description provided for @capturePhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get capturePhotoRequired;

  /// No description provided for @authRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'You must be signed in'**
  String get authRequiredMessage;

  /// No description provided for @captureUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable'**
  String get captureUnavailableTitle;

  /// No description provided for @captureUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open the proof camera. Please try again.'**
  String get captureUnavailableMessage;

  /// No description provided for @captureSelectBuddyError.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one buddy before sharing.'**
  String get captureSelectBuddyError;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String timeHoursAgo(int count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String timeDaysAgo(int count);

  /// No description provided for @visibilityCrew.
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get visibilityCrew;

  /// No description provided for @visibilityBuddy.
  ///
  /// In en, this message translates to:
  /// **'Buddy'**
  String get visibilityBuddy;

  /// No description provided for @visibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get visibilityPrivate;

  /// No description provided for @visibilityFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get visibilityFriends;

  /// No description provided for @visibilitySelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get visibilitySelected;

  /// No description provided for @visibilityPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get visibilityPersonal;

  /// No description provided for @momentPostFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to post moment: {error}'**
  String momentPostFailed(String error);

  /// No description provided for @offlineSyncQueuedMessage.
  ///
  /// In en, this message translates to:
  /// **'Will upload when you are back online.'**
  String get offlineSyncQueuedMessage;

  /// No description provided for @captureOpeningProofCamera.
  ///
  /// In en, this message translates to:
  /// **'Opening your proof camera…'**
  String get captureOpeningProofCamera;

  /// No description provided for @captureMomentTitle.
  ///
  /// In en, this message translates to:
  /// **'Capture moment'**
  String get captureMomentTitle;

  /// No description provided for @captureSourceCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get captureSourceCameraTitle;

  /// No description provided for @captureSourceCameraSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Proof is freshest right now.'**
  String get captureSourceCameraSubtitle;

  /// No description provided for @captureSourceGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get captureSourceGalleryTitle;

  /// No description provided for @captureSourceGallerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your recent wins are still waiting.'**
  String get captureSourceGallerySubtitle;

  /// No description provided for @captureHeroProofBadge.
  ///
  /// In en, this message translates to:
  /// **'Complete + proof'**
  String get captureHeroProofBadge;

  /// No description provided for @captureHeroMomentBadge.
  ///
  /// In en, this message translates to:
  /// **'Save or share later'**
  String get captureHeroMomentBadge;

  /// No description provided for @captureHeroProofTitle.
  ///
  /// In en, this message translates to:
  /// **'Capture the proof while the win is fresh.'**
  String get captureHeroProofTitle;

  /// No description provided for @captureHeroMomentTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a photo when the moment matters.'**
  String get captureHeroMomentTitle;

  /// No description provided for @captureHeroProofSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The habit only counts once you save a real photo as proof.'**
  String get captureHeroProofSubtitle;

  /// No description provided for @captureHeroMomentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can keep it private, attach it to a habit later, or share it with your buddy circle.'**
  String get captureHeroMomentSubtitle;

  /// No description provided for @captureChooseSource.
  ///
  /// In en, this message translates to:
  /// **'Choose source'**
  String get captureChooseSource;

  /// No description provided for @previewProofTitle.
  ///
  /// In en, this message translates to:
  /// **'Proof Preview'**
  String get previewProofTitle;

  /// No description provided for @previewMomentTitle.
  ///
  /// In en, this message translates to:
  /// **'Moment Preview'**
  String get previewMomentTitle;

  /// No description provided for @postAction.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postAction;

  /// No description provided for @previewProofBadge.
  ///
  /// In en, this message translates to:
  /// **'Habit proof'**
  String get previewProofBadge;

  /// No description provided for @previewMomentBadge.
  ///
  /// In en, this message translates to:
  /// **'Private moment'**
  String get previewMomentBadge;

  /// No description provided for @previewProofSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Saving this proof will finish the habit.'**
  String get previewProofSummaryTitle;

  /// No description provided for @previewMomentSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'You can save this privately or share it with a small buddy circle.'**
  String get previewMomentSummaryTitle;

  /// No description provided for @previewProofSummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll mark the habit done, keep this image linked as proof, and sync everything as soon as it can.'**
  String get previewProofSummarySubtitle;

  /// No description provided for @previewMomentSummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the loop simple: save only, add proof, or share privately.'**
  String get previewMomentSummarySubtitle;

  /// No description provided for @previewProofCaptionHint.
  ///
  /// In en, this message translates to:
  /// **'What did you finish?'**
  String get previewProofCaptionHint;

  /// No description provided for @previewMomentCaptionHint.
  ///
  /// In en, this message translates to:
  /// **'Why does this moment matter?'**
  String get previewMomentCaptionHint;

  /// No description provided for @captionLabel.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get captionLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @noneLabel.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneLabel;

  /// No description provided for @audienceTitle.
  ///
  /// In en, this message translates to:
  /// **'Who sees this'**
  String get audienceTitle;

  /// No description provided for @audienceOnlyMe.
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get audienceOnlyMe;

  /// No description provided for @audienceSharePrivately.
  ///
  /// In en, this message translates to:
  /// **'Share privately'**
  String get audienceSharePrivately;

  /// No description provided for @audienceCloseCrew.
  ///
  /// In en, this message translates to:
  /// **'Close crew'**
  String get audienceCloseCrew;

  /// No description provided for @previewAddBuddyFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a buddy first to share proof privately.'**
  String get previewAddBuddyFirst;

  /// No description provided for @confirmSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Sign Out'**
  String get confirmSignOutTitle;

  /// No description provided for @confirmSignOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of your account?'**
  String get confirmSignOutMessage;

  /// No description provided for @confirmSignOutTabHint.
  ///
  /// In en, this message translates to:
  /// **'Type to confirm'**
  String get confirmSignOutTabHint;

  /// No description provided for @confirmSignOutPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'sign out'**
  String get confirmSignOutPlaceholder;

  /// No description provided for @confirmDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get confirmDeleteAccountTitle;

  /// No description provided for @confirmDeleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all associated data. This action cannot be undone.'**
  String get confirmDeleteAccountMessage;

  /// No description provided for @confirmDeleteAccountTabHint.
  ///
  /// In en, this message translates to:
  /// **'Type to confirm deletion'**
  String get confirmDeleteAccountTabHint;

  /// No description provided for @confirmDeleteAccountPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'delete my account'**
  String get confirmDeleteAccountPlaceholder;

  /// No description provided for @confirmFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get confirmFieldRequired;

  /// No description provided for @confirmFieldMismatch.
  ///
  /// In en, this message translates to:
  /// **'Text does not match. Please try again.'**
  String get confirmFieldMismatch;

  /// No description provided for @softDeleteInitiatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Scheduled for Deletion'**
  String get softDeleteInitiatedTitle;

  /// No description provided for @softDeleteInitiatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account has been scheduled for deletion. You have 30 days to cancel this request by signing back in.'**
  String get softDeleteInitiatedMessage;

  /// No description provided for @cancelRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequestTitle;

  /// No description provided for @cancelRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this request?'**
  String get cancelRequestMessage;

  /// No description provided for @declineRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline Request'**
  String get declineRequestTitle;

  /// No description provided for @declineRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to decline this request?'**
  String get declineRequestMessage;

  /// No description provided for @actionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get actionSuccess;

  /// No description provided for @savedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get savedSuccessfully;

  /// No description provided for @updatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get updatedSuccessfully;

  /// No description provided for @removedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Removed successfully'**
  String get removedSuccessfully;

  /// No description provided for @actionFailed.
  ///
  /// In en, this message translates to:
  /// **'Action failed'**
  String get actionFailed;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get tryAgainLater;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @successTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successTitle;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardPeriodToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get leaderboardPeriodToday;

  /// No description provided for @leaderboardPeriodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get leaderboardPeriodWeek;

  /// No description provided for @leaderboardPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get leaderboardPeriodMonth;

  /// No description provided for @leaderboardPeriodAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get leaderboardPeriodAll;

  /// No description provided for @leaderboardDoneLabel.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get leaderboardDoneLabel;

  /// No description provided for @leaderboardNoFriendsTitle.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get leaderboardNoFriendsTitle;

  /// No description provided for @leaderboardNoFriendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add friends to compete on the leaderboard.'**
  String get leaderboardNoFriendsSubtitle;

  /// No description provided for @leaderboardDayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String leaderboardDayStreak(int count);

  /// No description provided for @streakJourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak Journey'**
  String get streakJourneyTitle;

  /// No description provided for @streakActivityStreaksTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Streaks'**
  String get streakActivityStreaksTitle;

  /// No description provided for @streakNoActivitiesYet.
  ///
  /// In en, this message translates to:
  /// **'No activities yet. Create one to start your streak!'**
  String get streakNoActivitiesYet;

  /// No description provided for @streakBestTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Best Streak'**
  String get streakBestTitle;

  /// No description provided for @streakStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Your Streak!'**
  String get streakStartTitle;

  /// No description provided for @streakBestStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get streakBestStatLabel;

  /// No description provided for @streakTotalStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get streakTotalStatLabel;

  /// No description provided for @streakActiveStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get streakActiveStatLabel;

  /// No description provided for @streakMilestoneRoadmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Milestone Roadmap'**
  String get streakMilestoneRoadmapTitle;

  /// No description provided for @streakDaysToGo.
  ///
  /// In en, this message translates to:
  /// **'{count} days to go'**
  String streakDaysToGo(int count);

  /// No description provided for @streakLastCompleted.
  ///
  /// In en, this message translates to:
  /// **'Last: {value}'**
  String streakLastCompleted(Object value);

  /// No description provided for @streakBestShort.
  ///
  /// In en, this message translates to:
  /// **'best: {count}d'**
  String streakBestShort(int count);

  /// No description provided for @streakTodayShort.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get streakTodayShort;

  /// No description provided for @streakYesterdayShort.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get streakYesterdayShort;

  /// No description provided for @streakDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String streakDaysAgo(int count);

  /// No description provided for @streakDaysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get streakDaysUnit;

  /// No description provided for @streakMilestoneGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get streakMilestoneGettingStarted;

  /// No description provided for @streakMilestoneOneWeek.
  ///
  /// In en, this message translates to:
  /// **'One Week'**
  String get streakMilestoneOneWeek;

  /// No description provided for @streakMilestoneTwoWeeks.
  ///
  /// In en, this message translates to:
  /// **'Two Weeks'**
  String get streakMilestoneTwoWeeks;

  /// No description provided for @streakMilestoneThreeWeeks.
  ///
  /// In en, this message translates to:
  /// **'Three Weeks'**
  String get streakMilestoneThreeWeeks;

  /// No description provided for @streakMilestoneOneMonth.
  ///
  /// In en, this message translates to:
  /// **'One Month'**
  String get streakMilestoneOneMonth;

  /// No description provided for @streakMilestoneTwoMonths.
  ///
  /// In en, this message translates to:
  /// **'Two Months'**
  String get streakMilestoneTwoMonths;

  /// No description provided for @streakMilestoneQuarter.
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get streakMilestoneQuarter;

  /// No description provided for @streakMilestoneCentury.
  ///
  /// In en, this message translates to:
  /// **'Century'**
  String get streakMilestoneCentury;

  /// No description provided for @streakMilestoneHalfYear.
  ///
  /// In en, this message translates to:
  /// **'Half Year'**
  String get streakMilestoneHalfYear;

  /// No description provided for @streakMilestoneOneYear.
  ///
  /// In en, this message translates to:
  /// **'One Year'**
  String get streakMilestoneOneYear;

  /// No description provided for @streakMilestoneReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Milestone reached!'**
  String get streakMilestoneReachedTitle;

  /// No description provided for @streakKeepGoingAction.
  ///
  /// In en, this message translates to:
  /// **'Keep Going!'**
  String get streakKeepGoingAction;

  /// No description provided for @recapTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Week in Moments'**
  String get recapTitle;

  /// No description provided for @recapQuote.
  ///
  /// In en, this message translates to:
  /// **'\"You\'re building a beautiful life,\\none moment at a time.\"'**
  String get recapQuote;

  /// No description provided for @recapMomentsStatLabel.
  ///
  /// In en, this message translates to:
  /// **'MOMENTS'**
  String get recapMomentsStatLabel;

  /// No description provided for @recapDayStreakStatLabel.
  ///
  /// In en, this message translates to:
  /// **'DAY STREAK'**
  String get recapDayStreakStatLabel;

  /// No description provided for @recapNoMomentsYet.
  ///
  /// In en, this message translates to:
  /// **'No moments this week yet.'**
  String get recapNoMomentsYet;

  /// No description provided for @recapShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to share this story?'**
  String get recapShareTitle;

  /// No description provided for @recapCaptureMomentAction.
  ///
  /// In en, this message translates to:
  /// **'Capture a Moment'**
  String get recapCaptureMomentAction;

  /// No description provided for @recapDisciplineActivitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discipline Activities'**
  String get recapDisciplineActivitiesTitle;

  /// No description provided for @recapTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get recapTodayLabel;

  /// No description provided for @recapYesterdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get recapYesterdayLabel;

  /// No description provided for @myCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'My Code'**
  String get myCodeTitle;

  /// No description provided for @myCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share this code with friends so they can add you.'**
  String get myCodeSubtitle;

  /// No description provided for @scanCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Code'**
  String get scanCodeTitle;

  /// No description provided for @scanCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan your friend\'s QR code to add them instantly.'**
  String get scanCodeSubtitle;

  /// No description provided for @addByIdTitle.
  ///
  /// In en, this message translates to:
  /// **'Add by ID'**
  String get addByIdTitle;

  /// No description provided for @addByIdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your friend\'s unique ID to send a buddy request.'**
  String get addByIdSubtitle;

  /// No description provided for @userIdLabel.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userIdLabel;

  /// No description provided for @userIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter their ID'**
  String get userIdHint;

  /// No description provided for @findByIdAction.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get findByIdAction;

  /// No description provided for @findByEmailAction.
  ///
  /// In en, this message translates to:
  /// **'Find by Email'**
  String get findByEmailAction;

  /// No description provided for @shareCodeAction.
  ///
  /// In en, this message translates to:
  /// **'Share my code'**
  String get shareCodeAction;

  /// No description provided for @scanAction.
  ///
  /// In en, this message translates to:
  /// **'Scan code'**
  String get scanAction;

  /// No description provided for @myCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get myCodeCopied;

  /// No description provided for @invalidCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code'**
  String get invalidCodeError;

  /// No description provided for @userNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFoundError;

  /// No description provided for @cantMessageSelfError.
  ///
  /// In en, this message translates to:
  /// **'You cannot message yourself'**
  String get cantMessageSelfError;

  /// No description provided for @onlyFriendsCanChatError.
  ///
  /// In en, this message translates to:
  /// **'You can only chat with friends'**
  String get onlyFriendsCanChatError;

  /// No description provided for @selectAddMethod.
  ///
  /// In en, this message translates to:
  /// **'Add friends via'**
  String get selectAddMethod;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
