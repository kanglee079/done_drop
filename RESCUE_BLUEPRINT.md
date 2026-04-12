# DoneDrop — Phase 1 深度审计报告 + 救援蓝图

**生成日期**: 2026-04-12
**执行人**: Repo-Rescue AI Agent
**审计范围**: 完整 Flutter 源码库 + Firebase 配置

---

## A. Phase 名称

**Deep Repo Audit + Rescue Blueprint**

---

## B. 为什么重要

这个仓库存在严重的产品漂移、架构违规和安全漏洞。直接在这个代码库上构建会产出：
- 一个 Firestore 计费炸弹（base64 图片）
- 一个没有习惯追踪能力的"习惯"app
- 一个朋友圈照片分享 app，而不是纪律执行引擎
- 一个无限隐私泄露风险的 app
- 一个无法离线工作的 app

必须先做完整的审计和蓝图规划，否则 Phase 2-9 会反复返工。

---

## C. 发现的所有问题汇总

### 🔴 严重问题（必须修复）

#### 1. 图片架构致命违规 — Firestore 存储 base64
- **文件**: `lib/core/services/image_service.dart`
- **现状**: 图片被压缩后以 base64 存储进 Firestore `images` 集合，`ImageService` 是唯一的图片处理方式
- **问题**:
  - Firestore 单文档 1MB 限制 → 图片压缩到 800KB 严重损失质量
  - 每次加载图片触发一次 Firestore 读取 → 极度昂贵的读操作计费
  - Feed 中每个 Moment 配一张图 → 一个 feed 页 = N 次 Firestore 读取
  - Firestore 不应该用作 CDN
  - `firestore.rules` 中 `match /images/{imageId}` 确认了这种用法
- **违规**: 直接违反"存储策略 — 非协商"规则

#### 2. Discipline Engine 完全缺失
- **文件**: `lib/core/models/moment.dart` 中的 `TaskTemplate` 模型
- **现状**:
  - `TaskTemplate` 只有一个 `isArchived` 字段
  - 完成即归档 → 习惯/routine 模型完全错误
  - 没有 recurrence（重复频率）
  - 没有 reminder scheduling（提醒调度）
  - 没有 next due date（下次到期）
  - 没有 completion log（完成日志）
  - 没有 streak tracking（连续追踪）
  - 没有 missed state（错过状态）
  - HomeScreen 的 "Your Reflection Journey" 是假功能
- **问题**: 这是一个一次性任务列表，不是习惯/活动追踪系统

#### 3. Firestore 安全规则关键 Bug
- **文件**: `firestore.rules`
- **问题 1** — `images` 集合读取规则:
  ```javascript
  // ❌ 当前代码（会崩溃/误判）
  && request.auth.uid in get(/databases/$(database)/documents/circles/$(resource.data.circleId)).data.memberIds
  ```
  当 `circleId` 为 null（personal_only 图片）时，`get()` 会失败，导致所有 personal_only 图片权限检查失败。
  
- **问题 2** — Storage `allow read: if request.auth != null`:
  所有头像、动态图片、圈子封面对任何登录用户可见 → 隐私完全失效

#### 4. 没有本地数据库（离线支持缺失）
- **现状**:
  - 无 Isar / Drift / SQLite
  - 只有 `SharedPreferences`（存 boolean/string）
  - 图片用文件系统缓存，但 Firestore 数据无本地副本
- **问题**:
  - 离线时无法创建活动
  - 离线时无法标记完成
  - 离线时无法保存 proof draft
  - 离线时无法排队上传
  - App 重启后 pending 状态丢失

#### 5. 分享模型以 Circle 为中心 — 与最终产品冲突
- **现状**:
  - `Moment.visibility` 只有 `'personal_only'` 和 `'circle'`
  - HomeScreen Tab 1 = Circle Feed
  - Feed = Circle moments
  - PreviewScreen Audience 选择 = Circle chips
  - Invite/Join Circle 是核心流程
- **问题**: 最终产品要求 visibility = `personal_only / all_friends / selected_friends`，Circle 应该是 V1.5 功能

---

### 🟡 中等问题（Phase 2-3 修复）

#### 6. Friend 系统不完整
- **现状**:
  - `friend_requests` 作为好友关系唯一来源
  - 没有 `friendships` 集合
  - 没有 5 friend 上限逻辑
  - `add_friend` 通过 email 搜索（隐私风险）
- **问题**: 5 friend 限制必须在前端和业务逻辑层强制执行

#### 7. Feed 架构低效（N+1 查询）
- **现状**: `FeedController._loadFeed()` 先获取所有 circles，再对每个 circle 调用 `getCircleMomentsSync()` → 每个 circle 一次 Firestore 查询
- **问题**: 有 10 个 circles = 11 次查询

#### 8. 没有分页
- **现状**: `watchPersonalMoments(limit: 200)` 用 hard limit，无 cursor pagination
- **问题**: 数据增长后 Feed 和 Memory Wall 无限加载会 OOM

#### 9. 没有缩略图策略
- **现状**: `CachedNetworkImage` 加载完整图片（可能是 4K）
- **问题**: Feed 列表中加载原图极大浪费带宽和内存

#### 10. Reaction 查询每个 Moment 都要读 Firestore
- **现状**: `reactionCounts` 存在 `Moment` 文档里，但 `DDReactionButton` 需要单独查询 reactions 子集合
- **问题**: Feed 中每个 Moment 的 reaction 都要一次查询

#### 11. 没有 pending sync 状态 UI
- **现状**: 离线时无视觉反馈，用户不知道操作被排队
- **问题**: 用户体验不透明

#### 12. Premium 架构占位符
- **现状**: `PremiumController` 是假的，`isPremium` 来自 SharedPreferences
- **问题**: 需要真实 RevenueCat 集成或至少诚实占位

#### 13. Analytics 初始化未完成
- **现状**: `AnalyticsService` 有事件定义但未在 `main.dart` 初始化
- **问题**: 无遥测数据

#### 14. 没有 required indexes 说明文档
- **现状**: 未提供 Firestore composite indexes
- **问题**: 部分查询（如 compound filters）需要 indexes

---

### 🟢 轻微问题（后续阶段修复）

#### 15. UI 语言软化问题
- **现状**: 大量使用 "reflection"、"journey"、"heirloom"、"museum"、"curate" 等词汇
- **问题**: 削弱了 discipline engine 的清晰度

#### 16. Memory Wall 和 Recap 优先级过高
- **现状**: BottomNav Tab 4 = Memory Wall, RecapScreen 有 CTA
- **问题**: 应该在 Activity/Proof 之后

#### 17. AddFriendController 通过 email 搜索
- **现状**: `findUserByEmail()` 暴露了 email 索引
- **问题**: 建议改用 username 或 friend code

#### 18. PreviewScreen 的 caption 使用 serif italic 字体
- **问题**: 正式发布时可能需要更规范的排版

#### 19. No Apple Sign In 实现
- **现状**: SignInScreen 有 Apple 按钮但只是 TODO
- **问题**: iOS 应用商店要求

#### 20. 没有启动稳定性处理
- **现状**: SplashScreen 直接导航，无错误处理
- **问题**: 网络慢时可能白屏

---

## D. 产品决策

基于最终产品定义和当前代码审计，做出以下产品决策：

### 保留的部分
| 模块 | 决策 | 原因 |
|------|------|------|
| GetX 状态管理 | 保留 | 工作正常，团队熟悉 |
| Firebase 全家桶 | 保留 | 生态完整 |
| CachedNetworkImage | 保留 | 图片缓存业界标准 |
| `flutter_local_notifications` | 保留 | 提醒功能需要 |
| `image_picker` + `image_cropper` | 保留 | 用户选图需要 |
| Analytics / Crashlytics 集成 | 保留 | 遥测需要 |
| 视觉设计系统（颜色/字体/组件） | 保留 | 设计质量高 |
| Auth 流程（SignIn/SignUp/Onboarding） | 保留并加强 | 基础可用 |
| Friend Request 系统 | 保留并加强 | 符合 private friend 要求 |

### 重构的部分
| 模块 | 决策 | 说明 |
|------|------|------|
| ImageService | **完全重写** | 改用 Firebase Storage |
| TaskTemplate | **升级为 Activity** | 完整习惯模型 |
| Circle sharing | **降级为 V1.5** | 改为 selected_friends |
| Feed 架构 | **重建为 feed_deliveries** | 私有化 + 高效 |
| 本地数据库 | **新增 Isar** | 离线支持 |
| Security rules | **重写** | 修复权限 bug |
| Storage rules | **重写** | 修复隐私泄露 |
| Premium 架构 | **诚实占位** | 不伪造购买 |

### 删除的部分
| 模块 | 决策 |
|------|------|
| Firestore `images` 集合 | 删除（改用 Storage） |
| Circle-centric Feed Tab | 降级为 Friends Tab |
| Circle Detail / Invite / Join 流程 | 保留但改名（用于 Friends） |
| Memory Wall 作为 Tab | 降级为二级页面 |
| Premium 的"preserve memories"文案 | 替换为 discipline 文案 |

### 新增的部分
| 模块 | 说明 |
|------|------|
| Activity model | 包含 recurrence, reminders, streaks |
| ActivityInstance model | 每次活动的实例记录 |
| CompletionLog model | 完成日志 |
| Friendships collection | 接受的好友关系 |
| feed_deliveries collection | 私有 feed 架构 |
| Local Isar DB | 离线队列 |
| PendingSync UI | 离线状态指示 |
| Thumbnail generation | 缩略图策略 |
| Streak calculation | 连续打卡逻辑 |

---

## E. 文件级行动方案

### Phase 2 需修改的文件

#### 删除文件
```
lib/core/services/image_service.dart          # ❌ base64 in Firestore
lib/core/services/upload_service.dart         # ❌ 已废弃，重复功能
```

#### 新建文件（Phase 2）
```
lib/core/services/media_service.dart          # Firebase Storage 封装
lib/core/services/local_db_service.dart       # Isar 数据库初始化
lib/core/models/activity.dart                 # Activity 领域模型
lib/core/models/activity_instance.dart        # ActivityInstance 模型
lib/core/models/completion_log.dart           # CompletionLog 模型
lib/core/models/friendship.dart               # Friendship 模型
lib/core/models/pending_sync.dart             # PendingSync 本地队列模型
lib/core/models/media_metadata.dart           # Storage 元数据模型
lib/data/local/activity_local_dao.dart        # Isar Activity DAO
lib/data/local/moment_local_dao.dart         # Isar Moment 本地 DAO
lib/data/local/sync_queue_dao.dart            # Isar 同步队列 DAO
```

#### 重构文件
```
lib/core/models/moment.dart                   # 添加 visibility = all_friends/selected_friends
lib/core/models/circle.dart                   # 降级为 V1.5 dormant
lib/core/models/friend_request.dart           # 添加好友上限检查逻辑
lib/core/services/storage_service.dart        # 扩展支持 Isar 初始化
lib/core/services/connectivity_service.dart   # 增强离线状态管理
lib/core/services/notification_service.dart  # 适配 Activity reminders
lib/firebase/repositories/moment_repository.dart  # 重写 media 逻辑
lib/firebase/repositories/circle_repository.dart   # 降级 Circle
lib/firebase/repositories/friend_repository.dart  # 添加 friendships + cap
lib/app/presentation/capture/moment_controller.dart  # 改用 Storage URL
lib/app/presentation/profile/profile_controller.dart  # 改用 Storage URL
```

### Phase 3 需修改的文件

```
lib/app/presentation/home/home_controller.dart  # 重写为 discipline-first
lib/app/presentation/home/task_controller.dart  # 重写为 activity controller
lib/app/presentation/home/home_screen.dart       # 重写 UI 和文案
lib/core/services/analytics_service.dart        # 初始化调用
```

### Phase 4 需修改的文件

```
lib/app/presentation/friends/friends_controller.dart   # 添加 cap=5 检查
lib/app/presentation/friends/add_friend_controller.dart  # 改用 username/code
lib/firebase/repositories/friend_repository.dart  # 添加 friendships 集合
lib/core/models/user_profile.dart                  # 添加 username 字段
```

### Phase 5 需修改的文件

```
lib/app/presentation/capture/preview_screen.dart   # 改 audience 选择逻辑
lib/app/presentation/capture/moment_controller.dart  # Storage 上传流程
lib/firebase/repositories/moment_repository.dart    # 添加 feed_deliveries 写入
```

### Phase 6 需修改的文件

```
lib/main.dart                                   # Isar 初始化
lib/core/services/local_db_service.dart          # Isar service
lib/app/presentation/home/home_screen.dart       # 添加 pending sync badge
lib/app/presentation/feed/feed_controller.dart  # 从 feed_deliveries 读取
```

### Phase 9 需修改的文件

```
firestore.rules                                 # 完全重写
storage.rules                                   # 完全重写
README.md                                       # 添加 Firebase/Storage/Isar 配置说明
```

---

## F. 数据模型 / Firebase 影响

### 新增 Firestore 集合

| 集合名 | 用途 | 关键字段 |
|--------|------|---------|
| `activities` | 用户创建的活动/习惯 | ownerId, title, recurrence, reminderTime, nextDue, streak, isArchived |
| `activity_instances` | 每次活动实例 | activityId, ownerId, date, status(pending/completed/missed), completedAt, momentId |
| `completion_logs` | 完成日志 | activityInstanceId, ownerId, completedAt, momentId, caption |
| `friendships` | 已接受的好友关系 | userId1, userId2, createdAt |
| `feed_deliveries` | 接收者 feed 条目 | recipientId, momentId, createdAt, isRead |

### 修改 Firestore 集合

| 集合名 | 修改内容 |
|--------|---------|
| `moments` | 添加 `visibility: all_friends \| selected_friends \| personal_only`，添加 `selectedFriendIds[]`，删除 `circleId` |
| `users` | 添加 `username` 字段，添加 `friendshipCount` 计数 |
| `friend_requests` | 添加 `senderUsername` |

### 删除 Firestore 集合

| 集合名 | 原因 |
|--------|------|
| `images` | 改用 Firebase Storage |
| `task_templates` | 替换为 `activities` |
| `circles` | 降级为 V1.5 dormant |
| `circle_memberships` | 同上 |
| `invites` | Circle 邀请码暂时移除 |

### Firebase Storage 路径

```
/avatars/{userId}/avatar.jpg          # 用户头像
/moments/{userId}/{momentId}/original.jpg  # 原图
/moments/{userId}/{momentId}/thumb.jpg     # 缩略图 (400px宽)
```

---

## G. 实施摘要

### Phase 2 — Architecture Relock（预计改动文件 ~25 个）

1. **删除** `ImageService`（base64 方案）
2. **新建** `MediaService`（Firebase Storage 封装，包含压缩 + 上传 + 缩略图 + 元数据）
3. **新建** Isar 数据库 schema（activity, activity_instance, completion_log, pending_sync, cached_moment）
4. **修改** 所有使用 `ImageService` 的地方 → `MediaService`
5. **重写** `firestore.rules`（修复 `images` 权限 bug，添加新集合规则）
6. **重写** `storage.rules`（修复公开读取 bug）
7. **扩展** `UserProfile` 模型（添加 username）
8. **扩展** `Moment` 模型（添加 all_friends/selected_friends visibility）

### Phase 3 — Discipline Engine（预计改动文件 ~15 个）

9. **新建** `Activity` + `ActivityInstance` + `CompletionLog` 模型
10. **新建** `ActivityRepository`（Firestore 读写）
11. **重写** `HomeScreen`（discipline-first UI）
12. **重写** `HomeController`（管理今日活动）
13. **实现** streak 计算逻辑
14. **实现** reminder scheduling（使用现有 NotificationService）
15. **实现** missed state 检测

### Phase 4 — Friend System（预计改动文件 ~10 个）

16. **新建** `Friendship` 模型
17. **新建** `FriendshipsRepository`
18. **重写** `FriendRepository`（添加 friendships + cap=5 检查）
19. **重写** `AddFriendScreen`（改用 username/friend code）
20. **重写** `FriendsScreen`（显示好友计数和上限）

### Phase 5 — Proof Moment Pipeline（预计改动文件 ~8 个）

21. **重写** `MomentController`（完整的上传→Storage→元数据→feed_deliveries 流程）
22. **重写** `PreviewScreen`（改变 audience 选择逻辑）
23. **新建** `FeedDeliveriesRepository`
24. **实现** selected_friends 权限过滤

### Phase 6 — Offline Queue（预计改动文件 ~12 个）

25. **新建** Isar DAOs（activity_local_dao, moment_local_dao, sync_queue_dao）
26. **新建** `SyncEngine`（重试逻辑 + 幂等写入）
27. **修改** `ConnectivityService`（连接恢复触发 sync）
28. **添加** pending sync badge UI

### Phase 7 — Private Feed（预计改动文件 ~10 个）

29. **重写** `FeedController`（从 feed_deliveries 读取）
30. **添加** cursor pagination
31. **添加** 缩略图加载策略
32. **优化** reaction counts 显示

### Phase 8 — Recap + Differentiators（预计改动文件 ~8 个）

33. **重写** Recap 文案和逻辑
34. **添加** 2-4 个差异化功能（TBD）

### Phase 9 — Rules + Tests + Docs（预计改动文件 ~6 个）

35. **最终审计** Firestore rules
36. **最终审计** Storage rules
37. **添加** composite indexes
38. **添加** 单元测试 + widget 测试
39. **更新** README

---

## H. 手动测试清单

### Phase 2 测试
- [ ] 头像上传 → Firebase Storage 有文件，Firestore 有 metadata
- [ ] 动态图片上传 → Storage 有 original + thumb
- [ ] 离线时图片选择 → 成功保存到本地
- [ ] 用户名设置 → Firestore 更新成功
- [ ] Firestore rules 测试：
  - [ ] 未登录用户无法读取任何数据
  - [ ] 用户只能读写自己的 profile
  - [ ] 用户只能读写自己的 activities
  - [ ] 用户无法读取其他人的 personal_only moments
  - [ ] accepted friend 可以读取对方的 all_friends moments
  - [ ] selected_friends moments 只有被选中的人能读取
- [ ] Storage rules 测试：
  - [ ] 未登录无法读取任何文件
  - [ ] 用户只能写入自己的 avatar
  - [ ] 用户只能写入自己的 moment images

### Phase 3 测试
- [ ] 创建活动 → 出现在今日视图
- [ ] 设置 recurrence → 每日/每周重复
- [ ] 完成活动 → completion_log 记录，streak 更新
- [ ] 跳过活动 → missed 状态
- [ ] 设置 reminder → 本地通知触发
- [ ] Archive 活动 → 从今日视图消失

### Phase 4 测试
- [ ] 发送好友请求 → friend_request 创建
- [ ] 接受好友请求 → friendships 记录创建
- [ ] 达到 5 个好友后 → UI 显示限制，无法再添加
- [ ] 删除好友 → friendships 记录删除，feed_deliveries 清理
- [ ] 封禁用户 → 双向关系清理

### Phase 5 测试
- [ ] 发布 personal_only → 只有自己能在 wall 看到
- [ ] 发布 all_friends → 所有好友 feed 收到
- [ ] 发布 selected_friends → 只有被选中的好友收到
- [ ] 离线发布 → 保存 draft，联网后上传

### Phase 6 测试
- [ ] 离线创建活动 → 保存到 Isar
- [ ] 离线完成活动 → 保存到 Isar sync queue
- [ ] 联网后 → 自动 sync，无数据丢失
- [ ] App 重启 → pending sync 仍然存在
- [ ] Upload 失败后重试 → 最多重试 3 次

### Phase 7 测试
- [ ] Feed 分页 → 滚动加载下一页
- [ ] 离线时 → 显示缓存内容 + offline banner
- [ ] 刷新 → 拉取最新

---

## I. 风险与权衡

| 风险 | 影响 | 缓解策略 |
|------|------|---------|
| Isar 增加包体积 | 安装包增大 | 评估实际使用大小 |
| Firebase Storage 冷启动延迟 | 图片首次加载慢 | 预加载 + placeholder |
| feed_deliveries fan-out 写入放大 | 发布 moment 时写入 N 个文档 | 接受这个 trade-off，换取读性能 |
| base64 图片历史数据迁移 | 已有图片无法迁移 | Phase 2 中添加迁移脚本 |
| Circle 功能降级用户流失 | 现有用户依赖 Circle | 提供清晰的 V1.5 roadmap |
| 5 friend 限制导致用户不满 | 免费用户体验受限 | 诚实的 premium 入口 |

---

## J. Next Phase

**Phase 2: Architecture Relock**

优先事项：
1. 建立 Firebase Storage 基础设施（MediaService）
2. 设置 Isar 数据库
3. 重写安全规则
4. 迁移基础模型（Activity, Friendship, Moment visibility）
5. 确保 app 在 Phase 2 结束时能正常编译和运行

Phase 2 的第一个具体任务：**创建 `lib/core/services/media_service.dart`**，移除所有 base64 逻辑，改用 Firebase Storage 路径结构。
