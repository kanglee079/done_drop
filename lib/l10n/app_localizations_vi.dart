// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'DoneDrop';

  @override
  String get memberFallbackName => 'Thành viên DoneDrop';

  @override
  String get greetingFallbackName => 'bạn';

  @override
  String get authTagline => 'Hoàn thành nó. Ghi lại nó.\nChia sẻ khoảnh khắc.';

  @override
  String get todayTabTitle => 'Hôm nay';

  @override
  String get todayTabSubtitle => 'Kỷ luật luôn hiện rõ.';

  @override
  String get buddyTabTitle => 'Buddy';

  @override
  String get buddyTabSubtitle =>
      'Khoảnh khắc riêng tư từ nhóm thân thiết của bạn.';

  @override
  String get wallTabTitle => 'Tường';

  @override
  String get wallTabSubtitle => 'Kho lưu trữ của bạn, sắp theo từng ký ức.';

  @override
  String get meTabTitle => 'Tôi';

  @override
  String get meTabSubtitle => 'Thống kê, nhắc nhở và cài đặt.';

  @override
  String get languageLabel => 'Ngôn ngữ';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get welcomeGetStarted => 'Bắt đầu';

  @override
  String get welcomeContinue => 'Tiếp tục';

  @override
  String get welcomeDone => 'Xong';

  @override
  String get onboardingHeadline =>
      'Tự giữ mình có trách nhiệm.\nHoàn thành thói quen. Chứng minh điều đó.';

  @override
  String get onboardingSubtitle =>
      'Tạo thói quen. Hoàn thành. Ghi lại bằng chứng. Chia sẻ riêng tư với những người đồng hành.';

  @override
  String get onboardingUseCaseTitle => 'BẠN ĐẾN ĐÂY VÌ ĐIỀU GÌ?';

  @override
  String get captureProofTitle => 'Chụp bằng chứng';

  @override
  String get captureProofSubtitle =>
      'DoneDrop cần quyền camera để ghi lại khoảnh khắc chứng minh. Ảnh của bạn luôn riêng tư cho tới khi bạn chọn chia sẻ.';

  @override
  String get privateByDefault => 'Riêng tư mặc định';

  @override
  String get privateByDefaultDesc =>
      'Bạn quyết định ai được xem khoảnh khắc của mình.';

  @override
  String get secureByDefault => 'Bảo mật đầu cuối';

  @override
  String get secureByDefaultDesc => 'Dữ liệu trách nhiệm của bạn thuộc về bạn.';

  @override
  String get gentleRemindersTitle => 'Nhắc nhở nhẹ nhàng';

  @override
  String get gentleRemindersDesc =>
      'Những lời nhắc tuỳ chọn để hoàn thành thói quen.';

  @override
  String get proofOnlyWhenYouChoose => 'Chỉ khi thật sự cần';

  @override
  String get proofOnlyWhenYouChooseDesc =>
      'Chỉ gắn bằng chứng khi thói quen đó xứng đáng.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'ban@example.com';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get passwordHint => '••••••••';

  @override
  String get fullNameLabel => 'Họ và tên';

  @override
  String get fullNameHint => 'Tên của bạn';

  @override
  String get confirmPasswordLabel => 'Xác nhận mật khẩu';

  @override
  String get confirmPasswordHint => 'Nhập lại mật khẩu';

  @override
  String get createAccountTitle => 'Tạo tài khoản';

  @override
  String get createAccountSubtitle =>
      'Bắt đầu ghi lại những khoảnh khắc hoàn thành ngay hôm nay.';

  @override
  String get signInAction => 'Đăng nhập';

  @override
  String get signUpAction => 'Đăng ký';

  @override
  String get createAccountAction => 'Tạo tài khoản';

  @override
  String get continueWithGoogle => 'Tiếp tục với Google';

  @override
  String get forgotPasswordAction => 'Quên mật khẩu?';

  @override
  String get orLabel => 'hoặc';

  @override
  String get noAccountPrompt => 'Chưa có tài khoản? ';

  @override
  String get alreadyHaveAccountPrompt => 'Đã có tài khoản? ';

  @override
  String get termsAgreementPrefix => 'Tiếp tục nghĩa là bạn đồng ý với ';

  @override
  String get createTermsAgreementPrefix =>
      'Tạo tài khoản nghĩa là bạn đồng ý với ';

  @override
  String get termsOfService => 'Điều khoản dịch vụ';

  @override
  String get privacyPolicy => 'Chính sách quyền riêng tư';

  @override
  String get andLabel => ' và ';

  @override
  String get nameRequired => 'Vui lòng nhập tên';

  @override
  String get nameTooShort => 'Tên phải có ít nhất 2 ký tự';

  @override
  String get emailRequired => 'Vui lòng nhập email';

  @override
  String get emailInvalid => 'Vui lòng nhập email hợp lệ';

  @override
  String get passwordRequired => 'Vui lòng nhập mật khẩu';

  @override
  String get passwordTooShort => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get confirmPasswordRequired => 'Vui lòng xác nhận mật khẩu';

  @override
  String get confirmPasswordMismatch => 'Mật khẩu không khớp';

  @override
  String get authSigningInStatus => 'Đang đăng nhập...';

  @override
  String get authLoadingProfileStatus => 'Đang tải tài khoản của bạn...';

  @override
  String get authCreatingAccountStatus => 'Đang tạo tài khoản...';

  @override
  String get authPreparingProfileStatus => 'Đang chuẩn bị hồ sơ của bạn...';

  @override
  String get authPreparingAppStatus => 'Đang chuẩn bị ứng dụng...';

  @override
  String get authProfileBootstrapError =>
      'Không thể hoàn tất chuẩn bị tài khoản. Vui lòng thử lại.';

  @override
  String get authAccountNotFound => 'Không tìm thấy tài khoản với email này.';

  @override
  String get authWrongPassword => 'Mật khẩu chưa đúng. Vui lòng thử lại.';

  @override
  String get authEmailAlreadyInUse => 'Email này đã được đăng ký.';

  @override
  String get authAccountDisabled => 'Tài khoản này đã bị vô hiệu hoá.';

  @override
  String get authTooManyRequests =>
      'Bạn thao tác quá nhiều lần. Hãy đợi một chút rồi thử lại.';

  @override
  String get authNetworkError => 'Lỗi mạng. Hãy kiểm tra kết nối rồi thử lại.';

  @override
  String get authInvalidCredentials =>
      'Thông tin đăng nhập chưa đúng. Hãy kiểm tra lại email và mật khẩu.';

  @override
  String get authDifferentSignInMethod =>
      'Email này đang dùng một phương thức đăng nhập khác.';

  @override
  String get authProviderUnavailable =>
      'Phương thức đăng nhập này hiện chưa khả dụng.';

  @override
  String get authRecentLoginRequired =>
      'Vui lòng xác minh lại danh tính trước khi tiếp tục.';

  @override
  String get authGenericError => 'Đăng nhập thất bại. Vui lòng thử lại.';

  @override
  String get googleSignInCancelled => 'Bạn đã huỷ đăng nhập Google.';

  @override
  String get googleSignInNetworkError =>
      'Đăng nhập Google cần kết nối internet ổn định.';

  @override
  String get googleSignInConfigError =>
      'Google Sign-In chưa sẵn sàng trên bản build này. Hãy dùng đăng nhập email trước.';

  @override
  String get googleSignInIosLimited =>
      'Google Sign-In hiện dùng được trên Android. Trên iPhone, hãy dùng đăng nhập email cho tới khi Sign in with Apple hoàn tất để đáp ứng yêu cầu App Store.';

  @override
  String get googleSignInTokenMissing =>
      'Đăng nhập Google hoàn tất nhưng thiếu token cần thiết. Hãy thử lại.';

  @override
  String get googleSignInFailed =>
      'Không thể hoàn tất đăng nhập Google. Vui lòng thử lại.';

  @override
  String todayGreeting(String name) {
    return 'Chào $name';
  }

  @override
  String get todayIntroTitle => 'Giữ hôm nay đơn giản và rõ ràng.';

  @override
  String todayIntroProgress(int completed, int total) {
    return '$completed trên $total thói quen đã hoàn thành cho hôm nay.';
  }

  @override
  String get summaryDone => 'Xong';

  @override
  String get summaryToday => 'Hôm nay';

  @override
  String get summaryBestStreak => 'Chuỗi tốt nhất';

  @override
  String get summaryDays => 'Ngày';

  @override
  String get summaryBuddies => 'Buddy';

  @override
  String get summaryPrivate => 'Riêng tư';

  @override
  String get nextUpTitle => 'Tiếp theo';

  @override
  String get nextUpSubtitle => 'Thói quen cần xong trước khi cả ngày trôi đi.';

  @override
  String get overdueTitle => 'Quá hạn';

  @override
  String get overdueSubtitle => 'Hoàn tất những việc này trước ngày mai.';

  @override
  String get laterTodayTitle => 'Phần còn lại hôm nay';

  @override
  String get laterTodayEmpty => 'Không còn thói quen nào sau ưu tiên kế tiếp.';

  @override
  String get laterTodayFilled => 'Giữ phần còn lại của ngày thật dễ nhìn.';

  @override
  String get capturedTodayTitle => 'Đã ghi lại hôm nay';

  @override
  String get capturedTodaySubtitle =>
      'Khoảnh khắc bằng chứng và thói quen đã xong trong phiên này.';

  @override
  String get weeklyRecapTitle => 'Tóm tắt tuần';

  @override
  String get weeklyRecapOpen => 'Mở';

  @override
  String weeklyRecapSummary(int count) {
    return '$count lần hoàn thành thói quen trong 7 ngày qua.';
  }

  @override
  String get needNewHabitTitle => 'Cần một thói quen mới?';

  @override
  String get needNewHabitSubtitle => 'Thêm ngay khi tiêu chuẩn vẫn còn rõ.';

  @override
  String get addAction => 'Thêm';

  @override
  String get addHabitTitle => 'Thêm thói quen';

  @override
  String get addHabitSubtitle =>
      'Giữ nó đủ cụ thể để bạn biết chính xác khi nào là “xong”.';

  @override
  String get editHabitTitle => 'Chỉnh sửa thói quen';

  @override
  String get editHabitSubtitle =>
      'Siết lại tên, thời gian hoặc nhóm để tiêu chuẩn luôn rõ ràng.';

  @override
  String get habitNameHint => 'Tên thói quen';

  @override
  String get habitCategoryHint => 'Nhóm (không bắt buộc)';

  @override
  String get habitNameRequiredError =>
      'Hãy đặt một tên rõ ràng cho thói quen này trước khi lưu.';

  @override
  String get habitTimeLabel => 'Thời gian';

  @override
  String get pickTimeAction => 'Chọn giờ';

  @override
  String get createHabitAction => 'Tạo thói quen';

  @override
  String get habitCreatedMessage =>
      'Đã thêm thói quen mới vào danh sách Hôm nay.';

  @override
  String get habitUpdatedMessage => 'Đã cập nhật thông tin thói quen.';

  @override
  String get habitCreateFailedMessage =>
      'Không thể tạo thói quen này. Vui lòng thử lại.';

  @override
  String get habitUpdateFailedMessage =>
      'Không thể lưu thay đổi của thói quen. Vui lòng thử lại.';

  @override
  String get habitActionMenuTooltip => 'Tác vụ thói quen';

  @override
  String get archiveHabitTitle => 'Lưu trữ thói quen';

  @override
  String archiveHabitMessage(String name) {
    return 'Lưu trữ \"$name\" và tạm gỡ nó khỏi Hôm nay chứ?';
  }

  @override
  String get habitArchivedMessage => 'Đã lưu trữ thói quen và gỡ khỏi Hôm nay.';

  @override
  String get habitArchiveFailedMessage =>
      'Chưa thể lưu trữ thói quen này lúc này.';

  @override
  String get deleteHabitTitle => 'Xoá thói quen';

  @override
  String deleteHabitMessage(String name) {
    return 'Xoá \"$name\" và gỡ lịch sử thói quen này khỏi DoneDrop? Các khoảnh khắc chứng minh vẫn được giữ trong lưu trữ.';
  }

  @override
  String get habitDeletedMessage => 'Đã xoá thói quen.';

  @override
  String get habitDeleteFailedMessage => 'Chưa thể xoá thói quen này lúc này.';

  @override
  String get emptyTodayTitle => 'Bắt đầu với một tiêu chuẩn.';

  @override
  String get emptyTodaySubtitle =>
      'Tạo thói quen đầu tiên bạn muốn chứng minh với chính mình hôm nay.';

  @override
  String get createFirstHabitAction => 'Tạo thói quen đầu tiên';

  @override
  String get nothingCapturedTitle => 'Chưa có gì được ghi lại';

  @override
  String get nothingCapturedSubtitle =>
      'Hoàn thành một thói quen và gắn bằng chứng khi nó có ý nghĩa.';

  @override
  String get capturedProofAttached => 'Đã gắn bằng chứng';

  @override
  String get capturedSavedOnly => 'Chỉ lưu riêng';

  @override
  String get allHabitsHandledTitle => 'Mọi thói quen đều xong';

  @override
  String get allHabitsHandledSubtitle =>
      'Bạn đã xong cho hôm nay. Hãy ghi bằng chứng nếu đó là một chiến thắng đáng nhớ.';

  @override
  String get onlyOneThingLeftTitle => 'Chỉ còn một việc';

  @override
  String get onlyOneThingLeftSubtitle =>
      'Hoàn tất thói quen chính và bạn sẽ xong cả ngày.';

  @override
  String get heroOverdueNow => 'Đang quá hạn';

  @override
  String get heroNextUp => 'Tiếp theo';

  @override
  String get heroProofAttached => 'Đã gắn bằng chứng';

  @override
  String get heroPrivateByDefault => 'Riêng tư mặc định';

  @override
  String get heroNeedsRecovery => 'Cần hoàn lại';

  @override
  String get heroOneTapToFinish => 'Cần ảnh để hoàn thành';

  @override
  String get heroCompletedWithProof => 'Hôm nay đã hoàn thành kèm bằng chứng';

  @override
  String get heroCompletedToday => 'Hôm nay đã hoàn thành';

  @override
  String get completeNowAction => 'Hoàn thành ngay';

  @override
  String get completeWithProofAction => 'Hoàn thành bằng ảnh';

  @override
  String get proofLabel => 'Bằng chứng';

  @override
  String get themeSettingsTitle => 'Giao diện & cài đặt';

  @override
  String get themeSettingsSubtitle =>
      'Tuỳ chọn ứng dụng và điều khiển cá nhân.';

  @override
  String get statsSectionTitle => 'Thống kê';

  @override
  String get statsSectionSubtitle => 'Những con số quan trọng lúc này.';

  @override
  String get weeklyWinsLabel => 'Chiến thắng tuần';

  @override
  String get activeHabitsLabel => 'Thói quen đang dùng';

  @override
  String get remindersSectionTitle => 'Nhắc nhở';

  @override
  String get remindersSectionSubtitle => 'Giữ vòng lặp kỷ luật luôn hiện rõ.';

  @override
  String get habitRemindersTitle => 'Nhắc nhở thói quen';

  @override
  String habitRemindersSubtitle(int count) {
    return '$count thói quen hiện đang có nhắc giờ.';
  }

  @override
  String get archivedHabitsSectionTitle => 'Thói quen lưu trữ';

  @override
  String get archivedHabitsSectionSubtitle =>
      'Những tiêu chuẩn bạn tạm dừng chứ không xoá.';

  @override
  String get noArchivedHabitsTitle => 'Chưa có thói quen lưu trữ';

  @override
  String get noArchivedHabitsSubtitle =>
      'Những tiêu chuẩn bạn tạm dừng sẽ hiện ở đây.';

  @override
  String get archivedHabitFallback => 'Thói quen đã lưu trữ';

  @override
  String get restoreAction => 'Khôi phục';

  @override
  String get themeTitle => 'Giao diện';

  @override
  String get themeSubtitle => 'Đang dùng giao diện hệ thống';

  @override
  String get profileTitle => 'Hồ sơ';

  @override
  String get profileSubtitle => 'Tên hiển thị, username, ảnh đại diện';

  @override
  String get buddyCircleTitle => 'Nhóm buddy';

  @override
  String get buddyCircleSubtitle =>
      'Mời, xoá và quản lý những người đồng hành thân thiết';

  @override
  String get privacySupportSectionTitle => 'Riêng tư & hỗ trợ';

  @override
  String get privacySupportSectionSubtitle =>
      'Chính sách, hỗ trợ và thông tin phát hành.';

  @override
  String get privacyPolicySubtitle =>
      'Đọc cách DoneDrop xử lý tài khoản và dữ liệu khoảnh khắc của bạn';

  @override
  String get termsSubtitle =>
      'Các quy định khi dùng DoneDrop và tính năng buddy riêng tư';

  @override
  String get supportTitle => 'Hỗ trợ';

  @override
  String get supportSubtitle => 'Báo lỗi hoặc nhận trợ giúp ngay trong app';

  @override
  String get appVersionTitle => 'Phiên bản ứng dụng';

  @override
  String get accountActionsSectionTitle => 'Tác vụ tài khoản';

  @override
  String get accountActionsSectionSubtitle =>
      'Đăng xuất, hoặc xoá vĩnh viễn tài khoản này.';

  @override
  String get deleteAccountTitle => 'Xoá tài khoản';

  @override
  String get deleteAccountSubtitle =>
      'Xoá vĩnh viễn hồ sơ, thói quen và khoảnh khắc của bạn';

  @override
  String get deleteAccountRemovingSubtitle => 'Đang xoá dữ liệu tài khoản...';

  @override
  String get signOutAction => 'Đăng xuất';

  @override
  String get retryAction => 'Thử lại';

  @override
  String get themeSettingsSnackbarTitle => 'Cài đặt giao diện';

  @override
  String get themeSettingsSnackbarMessage =>
      'Điều khiển giao diện hiện đang theo cài đặt hệ thống của bạn.';

  @override
  String get setupTitle => 'Thiết lập 3 thói quen đầu tiên';

  @override
  String get setupSubtitle =>
      'Cho hôm nay một cấu trúc rõ ràng trước khi vào màn hình chính.';

  @override
  String setupHabitTitle(int index) {
    return 'Thói quen $index';
  }

  @override
  String get setupHabitPrompt => 'Bạn muốn cam kết làm điều gì?';

  @override
  String get setupHabitTimePrompt => 'Hôm nay nó nên xuất hiện lúc nào?';

  @override
  String get setupPrimaryAction => 'Bắt đầu ngày của tôi';

  @override
  String get setupValidationError =>
      'Hãy tạo đủ 3 thói quen trước khi tiếp tục.';

  @override
  String get setupSaveError =>
      'Không thể lưu 3 thói quen đầu tiên. Vui lòng thử lại.';

  @override
  String get setupMorningDefault => 'Uống nước';

  @override
  String get setupMiddayDefault => 'Đi bộ 10 phút';

  @override
  String get setupEveningDefault => 'Đọc 20 trang';

  @override
  String get saveAction => 'Lưu';

  @override
  String get editAction => 'Chỉnh sửa';

  @override
  String get archiveAction => 'Lưu trữ';

  @override
  String get closeAction => 'Đóng';

  @override
  String get cancelAction => 'Huỷ';

  @override
  String get continueAction => 'Tiếp tục';

  @override
  String get deleteAction => 'Xoá';

  @override
  String get removeAction => 'Gỡ';

  @override
  String get doneAction => 'Xong';

  @override
  String get searchAction => 'Tìm';

  @override
  String get verifyAction => 'Xác minh';

  @override
  String get genericErrorTitle => 'Lỗi';

  @override
  String get statusPreviewOnly => 'Chỉ xem trước';

  @override
  String get statusQueued => 'Đã xếp hàng';

  @override
  String get statusPreparing => 'Đang chuẩn bị';

  @override
  String statusUploading(int progress) {
    return 'Đang tải $progress%';
  }

  @override
  String get statusSyncing => 'Đang đồng bộ';

  @override
  String get statusFailed => 'Thất bại';

  @override
  String get statusPosted => 'Đã đăng';

  @override
  String get uploadStagePreparingImage => 'Đang chuẩn bị ảnh…';

  @override
  String get uploadStageFinalizingMoment => 'Đang hoàn tất khoảnh khắc…';

  @override
  String get uploadReady => 'Sẵn sàng';

  @override
  String get buddyEmptyTitle => 'Buddy feed của bạn được thiết kế riêng tư.';

  @override
  String get buddyEmptySubtitle =>
      'Mời một vài người thân thiết mà bạn tin tưởng để vòng lặp chứng minh vẫn đủ gần gũi.';

  @override
  String get buddyViewWallAction => 'Xem tường';

  @override
  String get inviteBuddyAction => 'Mời buddy';

  @override
  String manageCircleAction(int count) {
    return 'Quản lý vòng tròn ($count)';
  }

  @override
  String get wallSectionSubtitle =>
      'Mọi bằng chứng bạn giữ lại, kể cả những khoảnh khắc đã chia sẻ.';

  @override
  String wallSectionSubtitleWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bằng chứng tháng này',
      one: '1 bằng chứng tháng này',
    );
    return '$_temp0';
  }

  @override
  String wallLeadFallback(String date) {
    return 'Một lời hứa đã giữ vào $date';
  }

  @override
  String get wallTileFallback => 'Đã lưu vào kho lưu trữ của bạn';

  @override
  String get wallEmptyTitle => 'Giữ một lời hứa.';

  @override
  String get wallEmptySubtitle =>
      'Tường sẽ lớn dần từ đó, từng tiêu chuẩn được giữ lại.';

  @override
  String buddyWallTitle(String name) {
    return 'Tường của $name';
  }

  @override
  String buddyWallHeroSubtitle(int count) {
    return '$count khoảnh khắc đã chia sẻ để bạn xem lại.';
  }

  @override
  String get buddyWallEmptyTitle => 'Chưa có gì được chia sẻ.';

  @override
  String buddyWallEmptySubtitle(String name) {
    return '$name vẫn chưa chia sẻ khoảnh khắc nào với bạn.';
  }

  @override
  String get reactionLoveLabel => 'Yêu thích';

  @override
  String get reactionCelebrateLabel => 'Chúc mừng';

  @override
  String get reactionInspiringLabel => 'Truyền cảm hứng';

  @override
  String get friendFeedTitle => 'Bảng feed buddy';

  @override
  String get markAllReadTooltip => 'Đánh dấu tất cả là đã đọc';

  @override
  String get feedEmptyTitle => 'Chưa có khoảnh khắc nào';

  @override
  String get feedEmptySubtitle =>
      'Những khoảnh khắc bạn bè chia sẻ\nsẽ xuất hiện ở đây.';

  @override
  String get addFriendsAction => 'Thêm buddy';

  @override
  String get memoryWallTitle => 'Tường ký ức';

  @override
  String get memoryWallAllFilter => 'Tất cả khoảnh khắc';

  @override
  String get memoryWallEmptyTitle => 'Chưa có khoảnh khắc nào';

  @override
  String get memoryWallEmptySubtitle =>
      'Kho lưu trữ những lời hứa bạn đã giữ\nsẽ xuất hiện ở đây.';

  @override
  String get createFirstMomentAction => 'Tạo khoảnh khắc đầu tiên';

  @override
  String get deleteMomentTitle => 'Xoá khoảnh khắc';

  @override
  String get deleteMomentMessage =>
      'Bạn có chắc muốn xoá khoảnh khắc này không?';

  @override
  String get buddyCrewTitle => 'Nhóm buddy';

  @override
  String get crewTabLabel => 'Nhóm';

  @override
  String crewTabCountLabel(int count, int limit) {
    return 'Nhóm ($count/$limit)';
  }

  @override
  String get requestsTabLabel => 'Yêu cầu';

  @override
  String get noFriendsYetTitle => 'Chưa có buddy nào';

  @override
  String get noFriendsYetSubtitle =>
      'Thêm vài buddy để giữ trách nhiệm với chính mình.';

  @override
  String get addFriendAction => 'Thêm buddy';

  @override
  String get removeFriendTitle => 'Gỡ buddy';

  @override
  String get removeFriendMessage => 'Gỡ buddy này chứ?';

  @override
  String get noPendingRequestsTitle => 'Chưa có yêu cầu nào';

  @override
  String get noPendingRequestsSubtitle =>
      'Yêu cầu đến và đi sẽ xuất hiện ở đây.';

  @override
  String get incomingSectionLabel => 'ĐẾN';

  @override
  String get sentSectionLabel => 'ĐÃ GỬI';

  @override
  String get friendRequestIncomingSubtitle => 'Muốn kết bạn với bạn';

  @override
  String get friendRequestSentSubtitle => 'Đã gửi yêu cầu kết bạn';

  @override
  String get acceptingBuddyRequestStatus => 'Đang chấp nhận yêu cầu buddy này…';

  @override
  String get friendAddedTitle => 'Đã thêm buddy';

  @override
  String friendAddedMessage(String name) {
    return '$name giờ đã là buddy của bạn';
  }

  @override
  String get friendRemovedTitle => 'Đã gỡ buddy';

  @override
  String get friendRemovedMessage => 'Mối quan hệ buddy đã được gỡ';

  @override
  String get addBuddyTitle => 'Thêm buddy';

  @override
  String get findByUsernameTitle => 'Tìm theo username';

  @override
  String get findByUsernameSubtitle =>
      'Nhập username của họ để gửi yêu cầu buddy.';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'johndoe';

  @override
  String get buddyLimitReachedTitle => 'Đã chạm giới hạn buddy';

  @override
  String buddyLimitReachedSubtitle(int limit) {
    return 'Gói miễn phí cho tối đa $limit buddy. Nâng cấp để thêm nhiều hơn.';
  }

  @override
  String get enterUsernameError => 'Hãy nhập username';

  @override
  String get usernameTooShort => 'Username phải có ít nhất 3 ký tự';

  @override
  String get ownUsernameError => 'Đó là username của chính bạn';

  @override
  String get ownAccountSearchError => 'Đó là tài khoản của chính bạn';

  @override
  String friendCapReachedError(int limit) {
    return 'Bạn đã đạt tối đa $limit buddy.';
  }

  @override
  String get requestSentTitle => 'Đã gửi yêu cầu';

  @override
  String requestSentMessage(String name) {
    return 'Đã gửi yêu cầu kết bạn tới $name';
  }

  @override
  String get buddySearchIdNotFoundError =>
      'Không tìm thấy tài khoản với ID này.';

  @override
  String get buddySearchEmailNotFoundError =>
      'Không tìm thấy tài khoản với email này.';

  @override
  String get buddySearchUsernameNotFoundError =>
      'Không tìm thấy tài khoản với username này.';

  @override
  String get buddySearchGenericError =>
      'Không thể tìm buddy lúc này. Vui lòng thử lại.';

  @override
  String get buddySearchTimeoutError => 'Tìm buddy quá lâu. Vui lòng thử lại.';

  @override
  String get buddyRequestGenericError =>
      'Không thể gửi yêu cầu buddy lúc này. Vui lòng thử lại.';

  @override
  String get buddyRequestTimeoutError =>
      'Gửi yêu cầu buddy quá lâu. Vui lòng thử lại.';

  @override
  String get alreadyBuddyError => 'Hai bạn đã là buddy của nhau rồi.';

  @override
  String get buddyRequestAlreadySentError =>
      'Yêu cầu buddy này đã được gửi trước đó.';

  @override
  String get sendBuddyRequestPrompt => 'Gửi yêu cầu buddy chứ?';

  @override
  String get sendBuddyRequestAction => 'Gửi yêu cầu buddy';

  @override
  String get requestSentSuccessTitle => 'Đã gửi yêu cầu!';

  @override
  String requestSentSuccessMessage(String name) {
    return 'Đã gửi yêu cầu buddy tới $name';
  }

  @override
  String get addAnotherBuddyAction => 'Thêm buddy khác';

  @override
  String get chatOpenAction => 'Nhắn tin';

  @override
  String get chatScreenSubtitle => 'Trò chuyện riêng tư với buddy này.';

  @override
  String get chatConnectingTitle => 'Đang kết nối cuộc trò chuyện';

  @override
  String get chatConnectingSubtitle =>
      'Đang tải tin nhắn mới nhất và đồng bộ trạng thái buddy.';

  @override
  String get chatLoadFailedTitle => 'Không tải được cuộc trò chuyện này';

  @override
  String get chatLoadFailedSubtitle =>
      'Hãy kiểm tra kết nối rồi thử tải lại đoạn chat.';

  @override
  String get chatConnectionTimeoutMessage =>
      'Tải cuộc trò chuyện quá lâu. Vui lòng thử lại.';

  @override
  String get chatEmptyTitle => 'Bắt đầu cuộc trò chuyện';

  @override
  String get chatEmptySubtitle =>
      'Giữ liên lạc riêng tư và rõ ràng với buddy này.';

  @override
  String get chatInputHint => 'Nhắn gì đó...';

  @override
  String get chatSendAction => 'Gửi';

  @override
  String get chatSendFailedMessage =>
      'Chưa thể gửi tin nhắn lúc này. Vui lòng thử lại.';

  @override
  String get profileFieldDisplayName => 'TÊN HIỂN THỊ';

  @override
  String get profileFieldBio => 'GIỚI THIỆU';

  @override
  String get profileNameHint => 'Tên của bạn';

  @override
  String get profileBioHint => 'Giới thiệu ngắn để bạn bè hiểu thêm về bạn';

  @override
  String get dangerZoneLabel => 'VÙNG NGUY HIỂM';

  @override
  String get notificationSettingsTitle => 'Thông báo';

  @override
  String get notificationCenterEmptyTitle => 'Chưa có thông báo nào.';

  @override
  String get notificationCenterEmptySubtitle =>
      'Yêu cầu kết bạn và khoảnh khắc mới từ buddy sẽ hiện ở đây.';

  @override
  String get notificationPermissionOffSubtitle =>
      'Cho phép thông báo để app nhắc bạn đúng giờ của từng task.';

  @override
  String get notificationExactAlarmOffSubtitle =>
      'Bật báo thức chính xác để Android đẩy nhắc nhở đúng phút trên thiết bị này.';

  @override
  String get momentRemindersTitle => 'Nhắc ghi khoảnh khắc';

  @override
  String get momentRemindersSubtitle =>
      'Nhận một lời nhắc nhẹ mỗi ngày để ghi lại khoảnh khắc của bạn.';

  @override
  String get notificationReminderTitle => 'Nhắc nhở';

  @override
  String get notificationReminderDesc => 'Bật hoặc tắt nhắc nhở hằng ngày';

  @override
  String get notificationTimeTitle => 'Thời gian';

  @override
  String get weeklyRecapSettingsTitle => 'Tóm tắt tuần';

  @override
  String get weeklyRecapSettingsSubtitle =>
      'Nhận bản tóm tắt hằng tuần về các khoảnh khắc của bạn.';

  @override
  String get weeklyRecapToggleTitle => 'Tóm tắt';

  @override
  String get weeklyRecapToggleDesc => 'Bật hoặc tắt tóm tắt hằng tuần';

  @override
  String get notificationDayTitle => 'Ngày';

  @override
  String get requestNotificationPermissionAction => 'Yêu cầu quyền thông báo';

  @override
  String get selectDayTitle => 'Chọn ngày';

  @override
  String get dayMonShort => 'Th 2';

  @override
  String get dayTueShort => 'Th 3';

  @override
  String get dayWedShort => 'Th 4';

  @override
  String get dayThuShort => 'Th 5';

  @override
  String get dayFriShort => 'Th 6';

  @override
  String get daySatShort => 'Th 7';

  @override
  String get daySunShort => 'CN';

  @override
  String get settingsArchiveTitle => 'Kho lưu trữ';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsSubtitle => 'Tinh chỉnh trải nghiệm cá nhân của bạn';

  @override
  String get premiumBannerTitle => 'DoneDrop Premium';

  @override
  String get premiumBannerSubtitle =>
      'Mở khoá thêm buddy và giao diện cao cấp.';

  @override
  String get preferencesTitle => 'Tuỳ chọn';

  @override
  String get habitRemindersSettingTitle => 'Nhắc nhở thói quen';

  @override
  String get habitRemindersSettingSubtitle =>
      'Những lời nhắc nhẹ mỗi ngày để hoàn thành thói quen';

  @override
  String get schedulePreferencesTitle => 'Lịch & tuỳ chọn';

  @override
  String get schedulePreferencesSubtitle =>
      'Giờ nhắc, ngày recap và nhiều hơn nữa';

  @override
  String get privacySharingTitle => 'Riêng tư & chia sẻ';

  @override
  String get profileSettingsDescFallback =>
      'Chỉnh tên, ảnh đại diện và bio của bạn';

  @override
  String get friendsSettingsTitle => 'Buddy';

  @override
  String get friendsSettingsSubtitle => 'Quản lý những người đồng hành của bạn';

  @override
  String get visibilitySettingsTitle => 'Hiển thị';

  @override
  String get visibilitySettingsSubtitle => 'Thiết lập hiện tại: Chỉ cá nhân';

  @override
  String get signOutTitle => 'Đăng xuất';

  @override
  String get signOutSubtitle => 'Đăng xuất khỏi tài khoản của bạn';

  @override
  String get signOutDialogMessage => 'Bạn có chắc muốn đăng xuất không?';

  @override
  String get profileSaved => 'Đã lưu hồ sơ';

  @override
  String get uploadAvatarFailed => 'Tải ảnh đại diện thất bại';

  @override
  String get profileNameEmpty => 'Tên không được để trống';

  @override
  String get deleteAccountDialogMessage =>
      'Thao tác này sẽ xoá vĩnh viễn hồ sơ, thói quen, khoảnh khắc chứng minh và dữ liệu buddy riêng tư của bạn khỏi DoneDrop. Nếu sau này có tính phí, việc huỷ đăng ký vẫn phải thực hiện qua cửa hàng ứng dụng.';

  @override
  String get keepAccountAction => 'Giữ tài khoản';

  @override
  String get verificationRequiredTitle => 'Cần xác minh';

  @override
  String get verificationRequiredFallback =>
      'Không thể xác minh tài khoản. Vui lòng thử lại.';

  @override
  String get deleteFailedTitle => 'Xoá thất bại';

  @override
  String get deleteFailedFallback => 'Không thể xoá dữ liệu tài khoản.';

  @override
  String get deleteIncompleteTitle => 'Xoá chưa hoàn tất';

  @override
  String get deleteIncompleteFallback =>
      'Không thể xoá thông tin xác thực tài khoản.';

  @override
  String get accountDeletedTitle => 'Đã xoá tài khoản';

  @override
  String get accountDeletedMessage =>
      'Tài khoản DoneDrop của bạn đã được xoá khỏi thiết bị này.';

  @override
  String get verifyWithGoogleTitle => 'Xác minh bằng Google';

  @override
  String get verifyWithGoogleMessage =>
      'Để bảo vệ tài khoản, hãy tiếp tục với Google thêm một lần nữa trước khi xoá.';

  @override
  String get unsupportedDeletionMethod =>
      'Phương thức đăng nhập này hiện chưa hỗ trợ xoá tài khoản trong app. Hãy đăng nhập lại bằng một phương thức được hỗ trợ rồi thử lại.';

  @override
  String get confirmPasswordTitle => 'Xác nhận mật khẩu';

  @override
  String get currentPasswordHint => 'Nhập mật khẩu hiện tại của bạn';

  @override
  String get reportTitle => 'Báo cáo';

  @override
  String get reportContentTitle => 'Báo cáo nội dung';

  @override
  String get reportContentSubtitle =>
      'Giúp chúng tôi giữ DoneDrop an toàn. Hãy chọn lý do báo cáo.';

  @override
  String get reportAdditionalDetailsHint => 'Chi tiết thêm (không bắt buộc)';

  @override
  String get submitReportAction => 'Gửi báo cáo';

  @override
  String get reportSubmittedTitle => 'Đã gửi báo cáo';

  @override
  String get reportSubmittedMessage =>
      'Cảm ơn bạn đã giúp giữ DoneDrop an toàn. Chúng tôi sẽ xem xét báo cáo của bạn sớm.';

  @override
  String get reportReasonRequiredTitle => 'Vui lòng chọn một lý do';

  @override
  String get reportSubmitFailedTitle => 'Gửi báo cáo thất bại';

  @override
  String get reportSubmitFailedMessage => 'Vui lòng thử lại.';

  @override
  String get weeklyRecapLoadFailed => 'Không thể tải tóm tắt tuần';

  @override
  String get reportReasonInappropriate => 'Nội dung không phù hợp';

  @override
  String get reportReasonHarassment => 'Quấy rối hoặc bắt nạt';

  @override
  String get reportReasonSpam => 'Spam hoặc gây hiểu lầm';

  @override
  String get reportReasonPrivacy => 'Lo ngại về quyền riêng tư';

  @override
  String get reportReasonOther => 'Lý do khác';

  @override
  String get forgotPasswordTitle => 'Đặt lại mật khẩu';

  @override
  String get forgotPasswordSubtitle =>
      'Nhập email của bạn và chúng tôi sẽ gửi liên kết để đặt lại mật khẩu.';

  @override
  String get checkYourEmailTitle => 'Kiểm tra email';

  @override
  String checkYourEmailMessage(String email) {
    return 'Chúng tôi đã gửi liên kết đặt lại mật khẩu tới\n$email.\nHãy kiểm tra hộp thư đến và cả thư rác.';
  }

  @override
  String get backToSignInAction => 'Quay lại đăng nhập';

  @override
  String get sendResetLinkAction => 'Gửi liên kết đặt lại';

  @override
  String get forgotPasswordUnexpectedError =>
      'Đã có lỗi xảy ra. Vui lòng thử lại.';

  @override
  String get forgotPasswordUserNotFound =>
      'Không tìm thấy tài khoản với email này.';

  @override
  String get forgotPasswordInvalidEmail => 'Vui lòng nhập một email hợp lệ.';

  @override
  String get forgotPasswordUnableToSend =>
      'Không thể gửi email đặt lại. Vui lòng thử lại.';

  @override
  String get premiumHiddenTitle => 'Premium bị ẩn trong bản build này';

  @override
  String get premiumHiddenMessage =>
      'Billing của store chưa được nối thật, nên subscription vẫn bị tắt cho tới khi mua hàng native sẵn sàng.';

  @override
  String get premiumScreenTitle => 'Premium sẽ tắt cho tới khi billing là thật';

  @override
  String get premiumScreenSubtitle =>
      'Bản build này loại bỏ mọi luồng mua giả. Khi StoreKit và Play Billing được nối thật, giá, restore, gia hạn và huỷ sẽ hiển thị tại đây.';

  @override
  String get premiumWhatUnlocksTitle => 'Những gì sẽ mở khoá sau này';

  @override
  String get premiumWhatUnlocksSubtitle =>
      'Giá, điều khoản dùng thử, restore, thông tin tự gia hạn và liên kết quản lý subscription sẽ chỉ xuất hiện khi native billing hoàn chỉnh.';

  @override
  String get premiumBenefitUnlimitedFriendsTitle => 'Buddy không giới hạn';

  @override
  String get premiumBenefitUnlimitedFriendsDesc =>
      'Kết nối với toàn bộ những người đồng hành của bạn.';

  @override
  String get premiumBenefitAdvancedFiltersTitle => 'Bộ lọc nâng cao';

  @override
  String get premiumBenefitAdvancedFiltersDesc =>
      'Tìm theo tâm trạng, người liên quan hoặc các chủ đề tinh tế.';

  @override
  String get premiumBenefitCustomThemesTitle => 'Giao diện recap tuỳ chỉnh';

  @override
  String get premiumBenefitCustomThemesDesc =>
      'Bố cục giàu chất biên tập dành riêng cho cuốn sổ ký ức của bạn.';

  @override
  String get premiumBenefitHighResBackupsTitle => 'Sao lưu độ phân giải cao';

  @override
  String get premiumBenefitHighResBackupsDesc =>
      'Lưu trữ không giảm chất lượng cho mọi bức ảnh bạn trân trọng.';

  @override
  String get premiumUnavailableAction =>
      'Premium chưa khả dụng trong bản build này';

  @override
  String get premiumFooterNote =>
      'Premium được cố ý ẩn cho tới khi billing đạt chuẩn store từ đầu đến cuối.';

  @override
  String get billingStatusCheckingChip => 'Đang kiểm tra store';

  @override
  String get billingStatusActiveChip => 'Premium đang active';

  @override
  String get billingStatusLiveChip => 'Store đã sẵn sàng';

  @override
  String get billingStatusIssueChip => 'Cần setup';

  @override
  String get billingPremiumActiveTitle => 'Premium đang hoạt động';

  @override
  String billingPremiumActiveSubtitle(String plan) {
    return 'Gói $plan của bạn đang hoạt động trên tài khoản này.';
  }

  @override
  String get billingCheckingSubtitle =>
      'Đang kiểm tra sản phẩm trên store và quyền Premium hiện tại của bạn.';

  @override
  String get billingCheckingRestoreMessage =>
      'Đang kiểm tra các giao dịch bạn đã có trên store.';

  @override
  String get billingPremiumReadySubtitle =>
      'Mở khoá buddy không giới hạn với gói tháng, năm hoặc lifetime.';

  @override
  String get billingCatalogSetupNeededSubtitle =>
      'Catalog trên store vẫn thiếu các product ID Premium bắt buộc.';

  @override
  String get billingStoreUnavailableTitle => 'Store chưa khả dụng';

  @override
  String get billingStoreUnavailableSubtitle =>
      'Billing của store chưa khả dụng trên thiết bị này lúc này.';

  @override
  String get billingStoreUnavailableMessage =>
      'DoneDrop chưa kết nối được tới Google Play hoặc App Store trên thiết bị này. Hãy kiểm tra tài khoản store đang đăng nhập, quyền tester và bản build internal testing.';

  @override
  String get billingRetryAction => 'Thử lại';

  @override
  String get billingCatalogMissingTitle => 'Thiếu sản phẩm trên store';

  @override
  String billingCatalogMissingMessage(String ids) {
    return 'DoneDrop chưa tìm thấy các product ID Premium này trong catalog store hiện tại: $ids';
  }

  @override
  String get billingWhatUnlocksTodaySubtitle =>
      'Hiện tại Premium mở khoá một lợi ích thật đang dùng được ngay: bỏ giới hạn 5 buddy. Gói tháng, năm và lifetime đều map vào cùng một entitlement.';

  @override
  String get billingBenefitRestoreTitle => 'Restore trên thiết bị khác';

  @override
  String get billingBenefitRestoreDesc =>
      'Khôi phục entitlement trên thiết bị khác nếu bạn đang đăng nhập cùng tài khoản store.';

  @override
  String get billingBenefitLifetimeTitle => 'Có lựa chọn lifetime';

  @override
  String get billingBenefitLifetimeDesc =>
      'Chọn mua một lần nếu bạn không muốn chu kỳ gia hạn tự động.';

  @override
  String get billingChoosePlanTitle => 'Chọn gói';

  @override
  String get billingMonthlyPlanTitle => 'Theo tháng';

  @override
  String get billingMonthlyPlanSubtitle =>
      'Tự gia hạn mỗi tháng cho tới khi bạn huỷ trên store.';

  @override
  String get billingYearlyPlanTitle => 'Theo năm';

  @override
  String get billingYearlyPlanSubtitle =>
      'Tự gia hạn mỗi năm cho tới khi bạn huỷ trên store.';

  @override
  String get billingLifetimePlanTitle => 'Lifetime';

  @override
  String get billingLifetimePlanSubtitle => 'Mua một lần. Không tự gia hạn.';

  @override
  String billingChoosePlanAction(String price) {
    return 'Tiếp tục với giá $price';
  }

  @override
  String billingSwitchPlanAction(String price) {
    return 'Chuyển sang $price';
  }

  @override
  String get billingOwnedAction => 'Đã mở khoá';

  @override
  String get billingPendingAction => 'Đang xử lý...';

  @override
  String get billingManageAction => 'Quản lý subscription';

  @override
  String get billingPurchaseQueuedMessage =>
      'Hãy hoàn tất giao dịch trong cửa sổ store để kích hoạt Premium.';

  @override
  String get billingPurchaseStartError =>
      'Store chưa mở được luồng thanh toán. Hãy thử lại.';

  @override
  String get billingRestoreSuccessTitle => 'Đã khôi phục Premium';

  @override
  String get billingRestoreSuccessMessage =>
      'Giao dịch store của bạn đã active lại trên tài khoản này.';

  @override
  String get billingRestorePendingMessage =>
      'Yêu cầu restore đã được gửi. Nếu tài khoản store này đã sở hữu Premium, quyền truy cập sẽ xuất hiện lại sớm.';

  @override
  String get billingManageUnavailableMessage =>
      'Hiện chưa có subscription tự gia hạn nào để quản lý.';

  @override
  String get billingFooterDisclosure =>
      'Subscription sẽ tự gia hạn cho tới khi bạn huỷ trên store. Lifetime là mua một lần. Product ID mặc định của bản build này: dd_premium_monthly, dd_premium_yearly, dd_premium_lifetime.';

  @override
  String get momentSavedTitle => 'Đã lưu khoảnh khắc';

  @override
  String get savedForSyncTitle => 'Đã lưu để đồng bộ';

  @override
  String get proofCapturedMessage =>
      'Thói quen đã hoàn thành. Bằng chứng đã được ghi lại.';

  @override
  String get quietProofMessage => 'Một bằng chứng nhỏ cho nỗ lực của bạn.';

  @override
  String get backToTodayAction => 'Quay lại Hôm nay';

  @override
  String get openBuddyAction => 'Mở Buddy';

  @override
  String get capturePhotoRequired => 'Chưa chọn ảnh';

  @override
  String get authRequiredMessage => 'Bạn cần đăng nhập';

  @override
  String get captureUnavailableTitle => 'Không mở được camera';

  @override
  String get captureUnavailableMessage =>
      'Không thể mở camera để chụp bằng chứng. Hãy thử lại.';

  @override
  String get captureFallbackToSystemCameraMessage =>
      'Ảnh vừa chụp chưa được ghi lại đúng trên thiết bị này. Hãy mở camera hệ thống để chụp lại.';

  @override
  String get captureSelectBuddyError =>
      'Hãy chọn ít nhất một buddy trước khi chia sẻ.';

  @override
  String get timeJustNow => 'Vừa xong';

  @override
  String timeMinutesAgo(int count) {
    return '$count phút trước';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count giờ trước';
  }

  @override
  String timeDaysAgo(int count) {
    return '$count ngày trước';
  }

  @override
  String get visibilityCrew => 'Nhóm';

  @override
  String get visibilityBuddy => 'Buddy';

  @override
  String get visibilityPrivate => 'Riêng tư';

  @override
  String get visibilityFriends => 'Bạn bè';

  @override
  String get visibilitySelected => 'Đã chọn';

  @override
  String get visibilityPersonal => 'Cá nhân';

  @override
  String momentPostFailed(String error) {
    return 'Đăng khoảnh khắc thất bại: $error';
  }

  @override
  String get offlineSyncQueuedMessage =>
      'Sẽ tải lên khi bạn trở lại trực tuyến.';

  @override
  String get captureOpeningProofCamera => 'Đang mở camera bằng chứng…';

  @override
  String get captureMomentTitle => 'Chụp khoảnh khắc';

  @override
  String get captureSourceCameraTitle => 'Camera';

  @override
  String get captureSourceCameraSubtitle =>
      'Bằng chứng rõ nhất là ngay lúc này.';

  @override
  String get captureSourceGalleryTitle => 'Thư viện';

  @override
  String get captureSourceGallerySubtitle =>
      'Những chiến thắng gần đây của bạn vẫn đang chờ.';

  @override
  String get captureHeroProofBadge => 'Hoàn thành + bằng chứng';

  @override
  String get captureHeroMomentBadge => 'Lưu hoặc chia sẻ sau';

  @override
  String get captureHeroProofTitle =>
      'Ghi lại bằng chứng khi chiến thắng còn mới.';

  @override
  String get captureHeroMomentTitle =>
      'Thêm ảnh khi khoảnh khắc đó thật sự đáng nhớ.';

  @override
  String get captureHeroProofSubtitle =>
      'Thói quen chỉ được tính khi bạn lưu một ảnh thật làm bằng chứng.';

  @override
  String get captureHeroMomentSubtitle =>
      'Bạn có thể giữ riêng, gắn vào thói quen sau, hoặc chia sẻ với vòng buddy.';

  @override
  String get captureChooseSource => 'Chọn nguồn ảnh';

  @override
  String get previewProofTitle => 'Xem trước bằng chứng';

  @override
  String get previewMomentTitle => 'Xem trước khoảnh khắc';

  @override
  String get postAction => 'Đăng';

  @override
  String get previewProofBadge => 'Bằng chứng thói quen';

  @override
  String get previewMomentBadge => 'Khoảnh khắc riêng tư';

  @override
  String get previewProofSummaryTitle =>
      'Lưu ảnh bằng chứng này sẽ chốt việc hoàn thành thói quen.';

  @override
  String get previewMomentSummaryTitle =>
      'Bạn có thể lưu riêng hoặc chia sẻ với một vòng buddy nhỏ.';

  @override
  String get previewProofSummarySubtitle =>
      'Chúng tôi sẽ đánh dấu thói quen là đã xong, gắn ảnh này làm bằng chứng và đồng bộ toàn bộ ngay khi có thể.';

  @override
  String get previewMomentSummarySubtitle =>
      'Giữ vòng lặp thật đơn giản: chỉ lưu, thêm bằng chứng hoặc chia sẻ riêng tư.';

  @override
  String get previewProofCaptionHint => 'Bạn vừa hoàn thành điều gì?';

  @override
  String get previewMomentCaptionHint => 'Vì sao khoảnh khắc này đáng nhớ?';

  @override
  String get captionLabel => 'Chú thích';

  @override
  String get categoryLabel => 'Danh mục';

  @override
  String get noneLabel => 'Không có';

  @override
  String get audienceTitle => 'Ai sẽ thấy điều này';

  @override
  String get audienceOnlyMe => 'Chỉ mình tôi';

  @override
  String get audienceSharePrivately => 'Chia sẻ riêng tư';

  @override
  String get audienceCloseCrew => 'Nhóm thân thiết';

  @override
  String get previewAddBuddyFirst =>
      'Hãy thêm buddy trước để chia sẻ bằng chứng riêng tư.';

  @override
  String get confirmSignOutTitle => 'Xác nhận đăng xuất';

  @override
  String get confirmSignOutMessage =>
      'Bạn có chắc muốn đăng xuất khỏi tài khoản không?';

  @override
  String get confirmSignOutTabHint => 'Nhập để xác nhận';

  @override
  String get confirmSignOutPlaceholder => 'đăng xuất';

  @override
  String get confirmDeleteAccountTitle => 'Xoá tài khoản';

  @override
  String get confirmDeleteAccountMessage =>
      'Thao tác này sẽ xoá vĩnh viễn tài khoản và toàn bộ dữ liệu liên quan. Không thể hoàn tác.';

  @override
  String get confirmDeleteAccountTabHint => 'Nhập để xác nhận xoá';

  @override
  String get confirmDeleteAccountPlaceholder => 'xoá tài khoản của tôi';

  @override
  String get confirmFieldRequired => 'Trường này không được để trống';

  @override
  String get confirmFieldMismatch => 'Văn bản không khớp. Vui lòng thử lại.';

  @override
  String get softDeleteInitiatedTitle => 'Tài khoản đã lên lịch xoá';

  @override
  String get softDeleteInitiatedMessage =>
      'Tài khoản của bạn đã được lên lịch xoá. Bạn có 30 ngày để huỷ yêu cầu này bằng cách đăng nhập lại.';

  @override
  String get cancelRequestTitle => 'Huỷ yêu cầu';

  @override
  String get cancelRequestMessage => 'Bạn có chắc muốn huỷ yêu cầu này không?';

  @override
  String get declineRequestTitle => 'Từ chối yêu cầu';

  @override
  String get declineRequestMessage =>
      'Bạn có chắc muốn từ chối yêu cầu này không?';

  @override
  String get actionSuccess => 'Thành công';

  @override
  String get savedSuccessfully => 'Lưu thành công';

  @override
  String get updatedSuccessfully => 'Cập nhật thành công';

  @override
  String get removedSuccessfully => 'Đã xoá thành công';

  @override
  String get actionFailed => 'Thao tác thất bại';

  @override
  String get tryAgainLater => 'Vui lòng thử lại sau';

  @override
  String get networkError => 'Lỗi mạng. Vui lòng kiểm tra kết nối.';

  @override
  String get errorTitle => 'Lỗi';

  @override
  String get successTitle => 'Thành công';

  @override
  String get leaderboardTitle => 'Bảng xếp hạng';

  @override
  String get leaderboardPeriodToday => 'Hôm nay';

  @override
  String get leaderboardPeriodWeek => 'Tuần';

  @override
  String get leaderboardPeriodMonth => 'Tháng';

  @override
  String get leaderboardPeriodAll => 'Tất cả';

  @override
  String get leaderboardDoneLabel => 'đã xong';

  @override
  String get leaderboardNoFriendsTitle => 'Chưa có bạn nào';

  @override
  String get leaderboardNoFriendsSubtitle =>
      'Hãy thêm bạn để cùng nhau lên bảng xếp hạng.';

  @override
  String leaderboardDayStreak(int count) {
    return 'chuỗi $count ngày';
  }

  @override
  String get streakJourneyTitle => 'Hành trình chuỗi';

  @override
  String get streakActivityStreaksTitle => 'Chuỗi theo thói quen';

  @override
  String get streakNoActivitiesYet =>
      'Chưa có thói quen nào. Hãy tạo một thói quen để bắt đầu chuỗi của bạn!';

  @override
  String get streakBestTitle => 'Chuỗi tốt nhất của bạn';

  @override
  String get streakStartTitle => 'Hãy bắt đầu chuỗi của bạn!';

  @override
  String get streakBestStatLabel => 'Tốt nhất';

  @override
  String get streakTotalStatLabel => 'Tổng';

  @override
  String get streakActiveStatLabel => 'Đang chạy';

  @override
  String get streakMilestoneRoadmapTitle => 'Lộ trình mốc';

  @override
  String streakDaysToGo(int count) {
    return 'còn $count ngày';
  }

  @override
  String streakLastCompleted(Object value) {
    return 'Lần cuối: $value';
  }

  @override
  String streakBestShort(int count) {
    return 'tốt nhất: ${count}d';
  }

  @override
  String get streakTodayShort => 'Hôm nay';

  @override
  String get streakYesterdayShort => 'Hôm qua';

  @override
  String streakDaysAgo(int count) {
    return '$count ngày trước';
  }

  @override
  String get streakDaysUnit => 'ngày';

  @override
  String get streakMilestoneGettingStarted => 'Khởi động';

  @override
  String get streakMilestoneOneWeek => 'Một tuần';

  @override
  String get streakMilestoneTwoWeeks => 'Hai tuần';

  @override
  String get streakMilestoneThreeWeeks => 'Ba tuần';

  @override
  String get streakMilestoneOneMonth => 'Một tháng';

  @override
  String get streakMilestoneTwoMonths => 'Hai tháng';

  @override
  String get streakMilestoneQuarter => 'Một quý';

  @override
  String get streakMilestoneCentury => 'Trăm ngày';

  @override
  String get streakMilestoneHalfYear => 'Nửa năm';

  @override
  String get streakMilestoneOneYear => 'Một năm';

  @override
  String get streakMilestoneReachedTitle => 'Bạn vừa đạt mốc mới!';

  @override
  String get streakKeepGoingAction => 'Tiếp tục thôi!';

  @override
  String get recapTitle => 'Tuần của bạn qua từng khoảnh khắc';

  @override
  String get recapQuote =>
      '\"Bạn đang xây một cuộc sống đẹp,\\ntừng khoảnh khắc một.\"';

  @override
  String get recapMomentsStatLabel => 'KHOẢNH KHẮC';

  @override
  String get recapDayStreakStatLabel => 'CHUỖI NGÀY';

  @override
  String get recapNoMomentsYet => 'Tuần này bạn chưa có khoảnh khắc nào.';

  @override
  String get recapShareTitle => 'Sẵn sàng chia sẻ câu chuyện này chưa?';

  @override
  String get recapCaptureMomentAction => 'Chụp một khoảnh khắc';

  @override
  String get recapDisciplineActivitiesTitle => 'Các thói quen kỷ luật';

  @override
  String get recapTodayLabel => 'Hôm nay';

  @override
  String get recapYesterdayLabel => 'Hôm qua';

  @override
  String get myCodeTitle => 'Mã của tôi';

  @override
  String get myCodeSubtitle => 'Chia sẻ mã này để bạn bè thêm bạn.';

  @override
  String get scanCodeTitle => 'Quét mã';

  @override
  String get scanCodeSubtitle => 'Quét mã QR của bạn bè để thêm họ ngay.';

  @override
  String get addByIdTitle => 'Thêm bằng ID';

  @override
  String get addByIdSubtitle =>
      'Nhập ID duy nhất của bạn bè để gửi lời mời kết bạn.';

  @override
  String get userIdLabel => 'ID người dùng';

  @override
  String get userIdHint => 'Nhập ID của họ';

  @override
  String get findByIdAction => 'Tìm';

  @override
  String get findByEmailAction => 'Tìm bằng Email';

  @override
  String get shareCodeAction => 'Chia sẻ mã của tôi';

  @override
  String get scanAction => 'Quét mã';

  @override
  String get myCodeCopied => 'Đã sao chép mã vào bộ nhớ tạm';

  @override
  String get yourUserId => 'ID của bạn';

  @override
  String get invalidCodeError => 'Mã QR không hợp lệ';

  @override
  String get scanCodeInvalidSubtitle =>
      'Chỉ quét mã QR mời DoneDrop hợp lệ hoặc mã buddy 6 ký tự.';

  @override
  String get scanCameraPermissionMessage =>
      'Quyền camera đang tắt. Hãy cho phép camera để quét mã buddy.';

  @override
  String get scanCameraUnsupportedMessage =>
      'Thiết bị này không hỗ trợ quét QR cho DoneDrop.';

  @override
  String get scanCameraFailedMessage =>
      'DoneDrop chưa thể mở trình quét lúc này. Vui lòng thử lại.';

  @override
  String get userNotFoundError => 'Không tìm thấy người dùng';

  @override
  String get cantMessageSelfError => 'Bạn không thể nhắn tin cho chính mình';

  @override
  String get onlyFriendsCanChatError => 'Bạn chỉ có thể nhắn tin với bạn bè';

  @override
  String get selectAddMethod => 'Thêm bạn bè qua';
}
