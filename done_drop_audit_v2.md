# DoneDrop Audit Report V2

## Mục tiêu của tài liệu
Tài liệu này khóa lại toàn bộ các vấn đề cốt lõi của dự án `done_drop` để tránh tình trạng sửa rời rạc, vá chỗ này hỏng chỗ khác, và tiếp tục đi vòng lặp mà không đưa app đến trạng thái beta-quality thực sự.

Tài liệu này dùng làm **nguồn sự thật duy nhất** cho đợt refactor tiếp theo.

---

## Kết luận điều hành

### Đánh giá tổng quan hiện tại
- **Điểm tổng thể repo:** 6.1/10
- **Mức sẵn sàng cho user thật:** 4.5/10
- **Mức sẵn sàng cho closed beta nhỏ:** 6/10
- **Mức sẵn sàng cho public release:** 3.5/10

### Kết luận ngắn
Repo có tiềm năng, đã có một số nền tảng đúng hướng như auth gate, activity engine, friend flow cơ bản, media metadata mới, nhưng vẫn đang mắc 3 vấn đề gốc:

1. **Product direction chưa khóa chặt**: app vẫn lai giữa discipline app, private friend app, và reflection/archive app.
2. **Kiến trúc còn song song cũ/mới**: vẫn tồn tại code cũ và flow cũ, khiến app khó ổn định.
3. **Chưa có chiến lược beta-hardening hoàn chỉnh**: test, responsive, offline queue, friend cap, selected-friends visibility và cleanup chưa đủ chặt.

### Mục tiêu refactor mới
Đưa DoneDrop về đúng định nghĩa:

> **DoneDrop là app kỷ luật cá nhân có bằng chứng hình ảnh và trách nhiệm riêng tư với bạn bè.**
>
> Người dùng tạo hoạt động/routine, được nhắc nhở để thực hiện, hoàn thành xong thì ghi nhận completion log, có thể chụp ảnh làm proof moment, rồi chia sẻ riêng tư với bạn bè đã kết bạn.

---

# Phần 1 — Thang điểm và cách chấm

## Thang điểm mức độ vấn đề
- **10/10**: vấn đề blocker, có thể làm hỏng toàn bộ hướng đi hoặc gây crash/rules sai/không thể release
- **8–9/10**: vấn đề rất nghiêm trọng, nếu không sửa sẽ làm UX kém, data lệch, hoặc logic sai
- **6–7/10**: vấn đề quan trọng, ảnh hưởng mạnh tới chất lượng nhưng chưa phải blocker tuyệt đối
- **4–5/10**: vấn đề nên sửa trong đợt polish/beta hardening
- **1–3/10**: vấn đề nhỏ, cosmetic hoặc tối ưu thêm

## Nhóm ưu tiên
- **P0**: bắt buộc sửa trước khi tiếp tục phát triển tính năng
- **P1**: sửa trong giai đoạn refactor chính
- **P2**: sửa trong giai đoạn polish/beta hardening

---

# Phần 2 — Vấn đề cốt lõi cần khắc phục

## 1. Product direction chưa khóa đúng một hướng
- **Điểm mức độ:** 10/10
- **Ưu tiên:** P0

### Vấn đề
App hiện vẫn trộn 3 hướng:
- discipline app
- private friend app
- circle/archive/reflection app

Biểu hiện:
- README còn mô tả app theo hướng private circle
- Home vẫn còn ngôn ngữ kiểu reflection journey / circle feed
- Preview/post flow còn chịu ảnh hưởng từ audience cũ
- Memory wall vẫn mang tính archive mạnh hơn tiến trình kỷ luật

### Hậu quả
- UI đẹp nhưng sai mục tiêu
- AI coder càng sửa càng lệch vì không có source of truth rõ ràng
- data model và rules sẽ tiếp tục mâu thuẫn với UX

### Hướng sửa dứt điểm
Khóa lại đúng 1 định nghĩa sản phẩm:
- discipline-first
- friend-private
- proof-of-completion
- no circle as primary V1

### Kết quả mong muốn
Mọi màn hình, data model, rules, copywriting, feature gating đều phải bám đúng định nghĩa này.

---

## 2. Home UX chưa discipline-first đủ mạnh
- **Điểm mức độ:** 9/10
- **Ưu tiên:** P0

### Vấn đề
Home đã có dữ liệu activity, instances, completion logs, nhưng thứ bậc UX vẫn chưa buộc user vào hành động chính.

Hiện thiếu rõ ràng ở các câu hỏi quan trọng:
- hôm nay phải làm gì
- cái gì overdue
- cái gì pending
- complete ở đâu
- streak hiện tại là gì
- nếu không làm thì hậu quả gì

### Hậu quả
- user không bị kéo vào hành động
- app trông như một app lifestyle đẹp thay vì công cụ kỷ luật
- completion flow không tạo được cảm giác nghiêm khắc và rõ ràng

### Hướng sửa dứt điểm
Thiết kế lại Home thành 5 khối:
1. streak + discipline status
2. overdue activities
3. today’s required activities
4. completed today
5. weekly consistency preview

### Kết quả mong muốn
User mở app là biết ngay việc tiếp theo phải làm và có thể complete thật nhanh.

---

## 3. Task/activity model trước đây yếu, hiện đã tiến bộ nhưng chưa hoàn chỉnh end-to-end
- **Điểm mức độ:** 8.5/10
- **Ưu tiên:** P0

### Vấn đề
Đã có `Activity`, `ActivityInstance`, `CompletionLog`, nhưng chưa chắc toàn bộ flow đã khép kín:
- tạo activity
- sinh instance đúng ngày
- complete instance
- tạo completion log
- gắn proof moment
- cập nhật streak đúng
- xử lý missed state đúng

### Hậu quả
- activity engine có thể nhìn đúng trên code nhưng sai ở runtime
- proof moment không gắn chắc vào hành động đã hoàn thành
- thống kê và recap dễ sai

### Hướng sửa dứt điểm
Xem `Activity + ActivityInstance + CompletionLog + Moment` là một pipeline thống nhất, không phải 4 entity rời rạc.

### Kết quả mong muốn
Không có moment nào “trôi nổi” mà không biết nó chứng thực cho completion nào.

---

## 4. Friend model có nhưng chưa đủ chắc để làm private accountability layer
- **Điểm mức độ:** 8.5/10
- **Ưu tiên:** P0

### Vấn đề
Friend flow hiện có send/accept/decline/cancel/remove, nhưng chưa đủ mạnh ở:
- friend cap 5 free chưa được enforce chắc chắn
- selected-friends visibility chưa khép kín toàn bộ flow
- UI còn fallback dữ liệu bạn bè chưa đẹp
- lookup strategy có nguy cơ va chạm với rules

### Hậu quả
- social layer không đáng tin
- premium rule không thể triển khai đúng
- user thật dễ gặp case kỳ lạ ở kết bạn/chia sẻ riêng tư

### Hướng sửa dứt điểm
- khóa sharing model: `personal_only`, `all_friends`, `selected_friends`
- enforce friend cap ở tầng business logic/backend-safe flow
- redesign user lookup nếu email lookup không an toàn
- thêm selected friend selector thật sự usable

### Kết quả mong muốn
Friend system trở thành lớp accountability riêng tư thực sự, không phải module phụ.

---

## 5. Circle model vẫn còn sót và gây nhiễu kiến trúc
- **Điểm mức độ:** 8/10
- **Ưu tiên:** P0

### Vấn đề
Repo vẫn còn nhiều route/screen/repository/rules theo hướng circle.

### Hậu quả
- AI coder bị kéo sai hướng
- code cũ tiếp tục sống cùng code mới
- user flow bị mâu thuẫn

### Hướng sửa dứt điểm
- demote circle khỏi main V1
- giữ lại nếu cần cho V1.5, nhưng không để chi phối home, preview, feed, rules
- loại bỏ hoặc đánh dấu deprecated rõ ràng

### Kết quả mong muốn
Không còn sự nhập nhằng giữa friend-first và circle-first.

---

## 6. Media architecture cũ vẫn còn tồn tại trong repo
- **Điểm mức độ:** 10/10
- **Ưu tiên:** P0

### Vấn đề
Dù đã có `MediaService` dùng Firebase Storage, repo vẫn còn `ImageService` cũ lưu base64 vào Firestore.

### Hậu quả
- cực kỳ nguy hiểm vì có thể gọi nhầm service cũ
- tăng chi phí và giảm hiệu năng
- làm codebase song song hai kiến trúc media

### Hướng sửa dứt điểm
- xóa hoặc vô hiệu hóa hoàn toàn `ImageService`
- chuẩn hóa toàn bộ code sang `MediaService`
- Firestore chỉ lưu metadata media
- Firebase Storage là nguồn thật của ảnh

### Kết quả mong muốn
Toàn bộ app chỉ có **1 media pipeline duy nhất**.

---

## 7. Feed architecture mới đã có dấu hiệu đúng nhưng chưa chắc hoàn chỉnh
- **Điểm mức độ:** 8/10
- **Ưu tiên:** P1

### Vấn đề
`MomentRepository` đã có `feed_deliveries`, nhưng cần audit kỹ:
- tạo delivery đúng lúc chưa
- xóa delivery khi moment xóa chưa
- selected_friends có tạo đúng recipient list chưa
- blocked users có bị lọc chưa
- unread count có chính xác không

### Hậu quả
- friend feed có thể sai hoặc lộ dữ liệu
- UX feed không đáng tin

### Hướng sửa dứt điểm
Xem feed là private recipient inbox thực sự, không phải truy vấn lỏng.

### Kết quả mong muốn
Friend feed nhanh, riêng tư, ổn định, dễ paginate.

---

## 8. Firestore rules và Storage rules chưa chắc đã khớp 100% với hướng mới
- **Điểm mức độ:** 9/10
- **Ưu tiên:** P0

### Vấn đề
Rules trước đây mang nhiều dấu vết circle/images collection cũ.
Ngay cả khi model mới tốt hơn, rules không đồng bộ sẽ khiến app fail ở user thật.

### Hậu quả
- lỗi permission khó debug
- private data có thể lộ hoặc bị chặn sai
- selected_friends và block logic không đáng tin

### Hướng sửa dứt điểm
Viết lại rules bám đúng các collection thật đang dùng:
- users
- friend_requests / friendships
- activities / activity_instances / completion_logs
- moments
- feed_deliveries
- reactions
- reports
- blocks
- Firebase Storage paths

### Kết quả mong muốn
Rules là bản phản chiếu đúng của product model.

---

## 9. Offline-first hiện chưa đủ để tin dùng thật
- **Điểm mức độ:** 8.5/10
- **Ưu tiên:** P1

### Vấn đề
Đã có `ConnectivityService`, nhưng chưa thấy local DB và queue đủ mạnh để:
- complete offline
- draft proof moment offline
- queue upload/post
- survive app restart

### Hậu quả
- user mất dữ liệu khi mạng yếu
- trải nghiệm thực tế rất dễ vỡ

### Hướng sửa dứt điểm
Dùng Isar hoặc Drift cho:
- pending completion
- draft moment
- upload queue
- cached feed items
- cached personal wall items

### Kết quả mong muốn
App usable ở điều kiện mạng yếu, đặc biệt trên mobile thật.

---

## 10. Dependency injection và bindings chưa sạch hoàn toàn
- **Điểm mức độ:** 7.5/10
- **Ưu tiên:** P1

### Vấn đề
Một số controller vẫn tự `Get.find()` dependency bên trong thay vì injected rõ ràng, như `HomeController`.

### Hậu quả
- khó test
- dễ gãy runtime ở một số route/path
- khó đảm bảo ổn định khi app lớn hơn

### Hướng sửa dứt điểm
- inject dependency rõ ràng qua bindings
- loại bỏ phụ thuộc ẩn trong controller khi không cần thiết

### Kết quả mong muốn
Controller dễ test, dễ bảo trì, ít lỗi âm thầm.

---

## 11. UI visual có gu nhưng UX clarity chưa đạt chuẩn rất tốt
- **Điểm mức độ:** 7/10
- **Ưu tiên:** P1

### Vấn đề
App đang đẹp theo mood, chưa đẹp theo product clarity.

### Hậu quả
- người dùng thấy app “xinh” nhưng chưa hiểu hành vi chính
- product retention sẽ yếu

### Hướng sửa dứt điểm
- giảm copy mơ hồ
- tăng hierarchy hành động
- làm complete CTA nổi bật hơn capture CTA
- đưa proof moment thành phần thưởng sau completion, không phải điểm khởi đầu

### Kết quả mong muốn
UI vừa đẹp vừa ép đúng hành vi.

---

## 12. Responsive/adaptive strategy chưa đủ để đảm bảo đẹp trên nhiều thiết bị
- **Điểm mức độ:** 8/10
- **Ưu tiên:** P1

### Vấn đề
Có design tokens nhưng chưa thấy chiến lược adaptive rõ cho:
- điện thoại nhỏ
- điện thoại lớn
- tablet
- text scale
- keyboard/safe area

### Hậu quả
- dễ overflow
- spacing không đều
- trải nghiệm lệch giữa thiết bị

### Hướng sửa dứt điểm
- định nghĩa compact/regular layout strategy
- audit tất cả màn hình chính với 4 kích thước thiết bị
- xử lý text overflow, safe area, keyboard overlap

### Kết quả mong muốn
UI giữ được chất lượng trên nhiều máy thật.

---

## 13. Test coverage gần như chưa đủ cho beta-quality
- **Điểm mức độ:** 9/10
- **Ưu tiên:** P0

### Vấn đề
Hiện chỉ có smoke test rất nhẹ.

### Hậu quả
- mọi bug logic/phân quyền/feed/offline đều dễ lọt
- càng sửa càng sinh regression

### Hướng sửa dứt điểm
Tối thiểu phải có:
- auth gate tests
- activity recurrence/completion tests
- friend cap tests
- selected-friends visibility tests
- media metadata tests
- feed delivery tests
- widget tests cho Home và states quan trọng

### Kết quả mong muốn
Có lưới an toàn để refactor mà không vỡ app.

---

## 14. Beta-hardening chưa tồn tại như một phase rõ ràng
- **Điểm mức độ:** 8/10
- **Ưu tiên:** P1

### Vấn đề
Repo có nhiều phần tốt nhưng chưa có lớp cuối cùng để đưa thành beta-quality:
- empty/loading/error states nhất quán
- skeleton/loading strategy
- retry UX
- crash-safe cleanup
- analytics event audit
- release checklist

### Hậu quả
- app có thể chạy, nhưng không “đủ chín” cho user thật

### Hướng sửa dứt điểm
Tạo phase riêng cho beta-hardening, không trộn với phát triển tính năng.

### Kết quả mong muốn
Có thể tự tin mở closed beta thật.

---

# Phần 3 — Chấm điểm từng mảng lớn

| Mảng | Điểm hiện tại | Mục tiêu beta | Ghi chú |
|---|---:|---:|---|
| Product Direction | 6.5 | 9.0 | Cần relock triệt để |
| Discipline Engine | 6.8 | 8.8 | Đã đúng hướng nhưng chưa khép kín |
| Friend / Privacy Layer | 5.8 | 8.7 | Thiếu enforce + UX + rules |
| Media / Storage | 5.0 | 9.0 | Bắt buộc bỏ pipeline cũ |
| Offline-first | 4.5 | 8.2 | Cần local DB + queue thật |
| UI Visual | 7.0 | 8.8 | Có gu, cần rõ hành vi |
| UX Clarity | 5.3 | 9.0 | Phải discipline-first |
| Responsive / Device Stability | 4.8 | 8.7 | Chưa audit kỹ |
| Testing | 2.0 | 8.0 | Gần như chưa có |
| Beta Readiness | 4.0 | 8.5 | Chưa đủ mở user thật |

---

# Phần 4 — Những gì nên GIỮ LẠI

## Nên giữ
1. **AuthController + Splash/AuthGuard logic hiện tại**
2. **ActivityRepository và bộ model activity/activity_instance/completion_log**
3. **Moment model mới với MomentMedia / MediaMetadata**
4. **MediaService dùng Firebase Storage**
5. **Friend flow nền tảng hiện có**
6. **Theme tokens / AppSizes / visual system cơ bản**
7. **Memory wall dùng thumbnail + cached_network_image**
8. **ConnectivityService làm nền cho offline strategy**

## Giữ lại nhưng phải chỉnh
1. HomeController
2. HomeScreen
3. FriendRepository
4. Friends UI
5. MomentRepository
6. Rules
7. README / docs / copywriting

---

# Phần 5 — Những gì phải VIẾT LẠI HOÀN TOÀN

## Bắt buộc viết lại
1. **Product copy và luồng chính Home**
2. **Audience selection của post flow**
3. **Any old circle-first screens/routes still in primary flow**
4. **ImageService cũ**
5. **Offline queue/draft architecture**
6. **Friend cap enforcement**
7. **Rules theo model mới**
8. **Beta test suite tối thiểu**

---

# Phần 6 — 3 Sprint Recovery Plan

## Sprint 1 — Relock toàn bộ hướng đi và hạ tầng
### Mục tiêu
- Product relock
- Data relock
- Storage relock
- Xóa kiến trúc song song cũ/mới

### Việc phải làm
- khóa product definition mới vào README/docs
- bỏ circle khỏi luồng chính
- đổi post audience sang `personal_only / all_friends / selected_friends`
- xóa `ImageService` cũ và mọi reference tới images-base64 Firestore
- chuẩn hóa toàn bộ media sang `MediaService + Firebase Storage`
- audit và dọn route/binding/copy cũ

### Kết quả cần đạt
Repo chỉ còn **một hướng sản phẩm** và **một media pipeline**.

---

## Sprint 2 — Hoàn thiện lõi sản phẩm
### Mục tiêu
- Discipline engine đúng nghĩa
- Friend-private model đúng nghĩa
- Proof moment flow đúng nghĩa
- Offline-first usable

### Việc phải làm
- hoàn thiện activity → instance → completion log → moment pipeline
- complete activity rồi mới capture proof
- enforce 5 friends free
- selected friends sharing hoạt động thật
- feed delivery hoạt động thật
- thêm local DB + draft + queue + retry

### Kết quả cần đạt
Người dùng có thể dùng app đúng mục tiêu ngay cả khi mạng không ổn định.

---

## Sprint 3 — Beta hardening thật sự
### Mục tiêu
- UI/UX đạt chuẩn hơn
- đa thiết bị ổn hơn
- rules/test/release readiness đầy đủ

### Việc phải làm
- redesign/polish Home và key flows
- responsive audit trên 4 nhóm thiết bị
- text scaling / keyboard / safe area fixes
- Firestore rules + Storage rules final
- composite indexes
- widget tests + unit tests cốt lõi
- analytics / crash / release docs / checklist

### Kết quả cần đạt
Có thể tự tin mở closed beta thật.

---

# Phần 7 — File-level action map sơ bộ

## Nên giữ và chỉnh
- `lib/main.dart`
- `lib/features/auth/presentation/controllers/auth_controller.dart`
- `lib/app/routes/auth_guard.dart`
- `lib/firebase/repositories/activity_repository.dart`
- `lib/core/models/activity.dart`
- `lib/core/models/activity_instance.dart`
- `lib/core/models/completion_log.dart`
- `lib/core/models/moment.dart`
- `lib/core/services/media_service.dart`
- `lib/app/presentation/memory_wall/memory_wall_screen.dart`
- `lib/app/presentation/memory_wall/memory_wall_controller.dart`
- `lib/firebase/repositories/moment_repository.dart`
- `lib/firebase/repositories/friend_repository.dart`

## Nên viết lại hoàn toàn hoặc loại bỏ
- `lib/core/services/image_service.dart`
- phần circle-first trong Home / Feed / Preview / routes còn sống
- audience selection cũ trong preview/post flow
- mọi logic dựa vào circle là sharing model chính
- bất kỳ rules hoặc model cũ dựa vào collection `images`

## Nên thêm mới
- local DB layer (Isar/Drift)
- queue repository/service
- selected friends picker UI
- friend cap enforcement service
- beta-hardening tests
- responsive helpers

---

# Phần 8 — Top risk nếu không sửa ngay

1. Repo sẽ tiếp tục đi vòng lặp sửa giao diện nhưng product vẫn sai.
2. App có thể chạy nhưng không giữ được user vì UX không rõ ràng.
3. Media pipeline cũ có thể quay lại gây lỗi hoặc tăng chi phí.
4. Friend/private sharing có thể sai quyền truy cập.
5. Offline yếu sẽ làm user mất niềm tin.
6. Không có test sẽ khiến mỗi lần sửa lại phát sinh regression.
7. Nếu mở user thật quá sớm, feedback sẽ lẫn lộn vì sản phẩm chưa khóa đúng.

---

# Phần 9 — Định nghĩa DONE cho đợt refactor này

Chỉ được coi là xong khi thỏa tất cả:
- app chỉ còn một hướng sản phẩm duy nhất: discipline-first + private-friend + proof moment
- không còn image base64 pipeline cũ trong repo
- Home rõ ràng, mạnh, và hành động-first
- completion flow gắn chắc với proof moment
- friend cap 5 free hoạt động thật
- selected-friends share hoạt động thật
- offline draft + queue hoạt động thật
- media dùng Firebase Storage hoàn chỉnh
- rules đúng theo model mới
- app hiển thị ổn trên nhiều thiết bị phổ biến
- test cốt lõi đủ để refactor tiếp mà không gãy
- closed beta quality đạt được

