# Phân Tích & Phương Án: Quản Lý Tài Khoản Admin

## 1. TỔNG QUAN YÊU CẦU

### 1.1. Các chức năng cần triển khai:
1. ✅ **Xem chi tiết tài khoản** - Xem thông tin đầy đủ của một user
2. ⚠️ **Phân quyền tài khoản (admin/user)** - Thay đổi role_id giữa 1 (user) và 2 (admin)
3. ⚠️ **Khóa và mở khóa tài khoản** - Quản lý trạng thái locked của user
4. ✅ **Xóa tài khoản** - Xóa user khỏi hệ thống

---

## 2. PHÂN TÍCH BACKEND HIỆN TẠI

### 2.1. API Backend Đã Có Sẵn ✅

**File:** `fitness-backend/controllers/admin/user_admin_controller.js`
**Routes:** `fitness-backend/routes/admin/user_admin_routes.js`

| Endpoint | Method | Chức năng | Status |
|----------|--------|-----------|--------|
| `/admin/users` | GET | Lấy danh sách tất cả users | ✅ Có sẵn |
| `/admin/users/:id` | GET | Xem chi tiết 1 user | ✅ Có sẵn |
| `/admin/users/:id` | DELETE | Xóa user | ✅ Có sẵn |
| `/admin/users/:id/lock` | PATCH | Khóa user | ✅ Có sẵn |

### 2.2. API Backend Cần Bổ Sung ⚠️

| Endpoint | Method | Chức năng | Lý do |
|----------|--------|-----------|-------|
| `/admin/users/:id/unlock` | PATCH | Mở khóa user | Hiện chỉ có lock, chưa có unlock |
| `/admin/users/:id/role` | PATCH | Cập nhật role (admin/user) | Chưa có API để thay đổi role_id |

### 2.3. Database Schema

**Bảng `users`:**
- ✅ `id` (INT, PK)
- ✅ `role_id` (INT, FK → role.id)
  - `1` = User (người dùng thường)
  - `2` = Admin (quản trị viên)
- ✅ `name` (VARCHAR(100))
- ✅ `email` (VARCHAR(100), UNIQUE)
- ✅ `password` (VARCHAR(255))
- ✅ `gender` (ENUM: 'male', 'female', 'other')
- ✅ `age` (INT)
- ✅ `created_at` (DATETIME)
- ⚠️ **`locked` (BOOLEAN)** - **CẦN KIỂM TRA/THÊM**

**Lưu ý:** Controller có sử dụng `locked:true` nhưng cần xác nhận cột này đã tồn tại trong database chưa.

---

## 3. PHÂN TÍCH FRONTEND HIỆN TẠI

### 3.1. Cấu trúc hiện có:
- ✅ `AdminHomeScreen` - Có menu "Quản lý tài khoản" (đang hiển thị "Chức năng đang phát triển")
- ✅ Pattern BLoC đã được áp dụng cho Food và Exercise management
- ✅ Có `RoleStorage` để lưu role_id
- ✅ Có `TokenStorage` để lưu JWT token

### 3.2. Cấu trúc cần tạo:

```
lib/
├── domain/
│   ├── entities/
│   │   └── user.dart (nếu chưa có)
│   └── usecases/
│       └── admin/
│           ├── get_users.dart
│           ├── get_user_detail.dart
│           ├── update_user_role.dart
│           ├── lock_user.dart
│           ├── unlock_user.dart
│           └── delete_user.dart
├── data/
│   ├── dtos/
│   │   └── user_dto.dart
│   ├── datasources/
│   │   └── remote/
│   │       └── admin/
│   │           └── admin_user_api.dart
│   └── repositories_impl/
│       └── admin/
│           └── admin_user_repository_impl.dart
├── domain/
│   └── repositories/
│       └── admin/
│           └── admin_user_repository.dart
└── presentation/
    └── modules/
        └── admin/
            ├── bloc/
            │   └── user/
            │       ├── admin_user_bloc.dart
            │       ├── admin_user_event.dart
            │       └── admin_user_state.dart
            └── screens/
                └── user/
                    ├── admin_user_management_screen.dart
                    └── admin_user_detail_screen.dart
```

---

## 4. PHƯƠNG ÁN TRIỂN KHAI

### 4.1. BACKEND (Cần bổ sung)

#### Bước 1: Kiểm tra/Thêm cột `locked` vào database
```sql
-- Kiểm tra xem cột locked đã tồn tại chưa
SHOW COLUMNS FROM users LIKE 'locked';

-- Nếu chưa có, thêm cột
ALTER TABLE users ADD COLUMN locked BOOLEAN DEFAULT FALSE;
```

#### Bước 2: Thêm API Unlock User
**File:** `fitness-backend/controllers/admin/user_admin_controller.js`
```javascript
// Mở khóa user
exports.unlockUser = async (req, res) => {
  try {
    await User.update({ locked: false }, { where: { id: req.params.id } });
    res.json({ message: 'Đã mở khóa tài khoản' });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};
```

**File:** `fitness-backend/routes/admin/user_admin_routes.js`
```javascript
router.patch('/:id/unlock', protect, adminOnly, userAdmin.unlockUser);
```

#### Bước 3: Thêm API Update Role
**File:** `fitness-backend/controllers/admin/user_admin_controller.js`
```javascript
// Cập nhật role của user
exports.updateUserRole = async (req, res) => {
  try {
    const { role_id } = req.body;
    if (!role_id || ![1, 2].includes(parseInt(role_id))) {
      return res.status(400).json({ message: 'role_id phải là 1 (user) hoặc 2 (admin)' });
    }
    await User.update({ role_id: parseInt(role_id) }, { where: { id: req.params.id } });
    res.json({ message: 'Đã cập nhật quyền tài khoản' });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};
```

**File:** `fitness-backend/routes/admin/user_admin_routes.js`
```javascript
router.patch('/:id/role', protect, adminOnly, userAdmin.updateUserRole);
```

---

### 4.2. FRONTEND (Cần tạo mới)

#### Bước 1: Tạo Domain Layer

**1.1. Entity: `lib/domain/entities/user.dart`**
```dart
class User {
  final int id;
  final int? roleId;
  final String? name;
  final String email;
  final String? gender;
  final int? age;
  final DateTime? createdAt;
  final bool? locked;

  User({
    required this.id,
    this.roleId,
    this.name,
    required this.email,
    this.gender,
    this.age,
    this.createdAt,
    this.locked,
  });

  bool get isAdmin => roleId == 2;
  bool get isUser => roleId == 1;
  bool get isLocked => locked == true;
}
```

**1.2. Repository Interface: `lib/domain/repositories/admin/admin_user_repository.dart`**
```dart
abstract class AdminUserRepository {
  Future<List<User>> getUsers();
  Future<User> getUserDetail(int userId);
  Future<void> updateUserRole(int userId, int roleId);
  Future<void> lockUser(int userId);
  Future<void> unlockUser(int userId);
  Future<void> deleteUser(int userId);
}
```

**1.3. Use Cases:**
- `get_users.dart` - Lấy danh sách users
- `get_user_detail.dart` - Lấy chi tiết user
- `update_user_role.dart` - Cập nhật role
- `lock_user.dart` - Khóa user
- `unlock_user.dart` - Mở khóa user
- `delete_user.dart` - Xóa user

#### Bước 2: Tạo Data Layer

**2.1. DTO: `lib/data/dtos/user_dto.dart`**
```dart
class UserDto {
  final int id;
  final int? roleId;
  final String? name;
  final String email;
  final String? gender;
  final int? age;
  final String? createdAt;
  final bool? locked;

  UserDto({...});

  factory UserDto.fromJson(Map<String, dynamic> json) {...}
  User toEntity() {...}
}
```

**2.2. API: `lib/data/datasources/remote/admin/admin_user_api.dart`**
- Implement các method gọi API tương ứng với backend endpoints

**2.3. Repository Implementation: `lib/data/repositories_impl/admin/admin_user_repository_impl.dart`**
- Implement `AdminUserRepository` interface

#### Bước 3: Tạo Presentation Layer

**3.1. BLoC:**
- `AdminUserBloc` - Quản lý state cho user management
- Events: `LoadUsers`, `LoadUserDetail`, `UpdateUserRole`, `LockUser`, `UnlockUser`, `DeleteUser`, `SearchUsers`, `FilterUsersByRole`
- States: `AdminUserState` với các trạng thái: `isLoading`, `users`, `selectedUser`, `errorMessage`, `successMessage`, `displayedUsers`, `searchQuery`, `selectedRoleFilter`

**3.2. Screens:**

**3.2.1. `AdminUserManagementScreen`:**
- Danh sách users với search bar
- Filter theo role (Tất cả, User, Admin)
- Filter theo trạng thái (Tất cả, Đã khóa, Chưa khóa)
- Hiển thị: Avatar, Tên, Email, Role badge, Lock status
- Actions: Xem chi tiết, Khóa/Mở khóa, Phân quyền, Xóa (swipe-to-delete)

**3.2.2. `AdminUserDetailScreen`:**
- Hiển thị đầy đủ thông tin user
- Actions:
  - Nút "Phân quyền" - Dialog chọn role (User/Admin)
  - Nút "Khóa tài khoản" / "Mở khóa tài khoản"
  - Nút "Xóa tài khoản" - Dialog xác nhận

---

## 5. KẾT LUẬN

### ✅ CÓ THỂ LÀM ĐƯỢC

**Lý do:**
1. Backend đã có 4/6 API cần thiết (chỉ cần thêm 2 API)
2. Database schema đã có đầy đủ trường (có thể cần thêm cột `locked`)
3. Frontend đã có pattern BLoC rõ ràng từ Food/Exercise management
4. Có sẵn authentication và authorization middleware

### ⚠️ CẦN LƯU Ý

1. **Database:** Cần kiểm tra/thêm cột `locked` nếu chưa có
2. **Security:** 
   - Không cho phép admin tự khóa/xóa chính mình
   - Không cho phép xóa admin cuối cùng
   - Validate role_id chỉ nhận 1 hoặc 2
3. **UX:**
   - Hiển thị confirmation dialog trước khi xóa/khóa
   - Hiển thị loading state khi đang xử lý
   - Error handling rõ ràng
4. **Performance:**
   - Pagination nếu số lượng users lớn (có thể làm sau)
   - Cache danh sách users nếu cần

### 📋 THỨ TỰ TRIỂN KHAI ĐỀ XUẤT

1. **Backend:** Thêm 2 API (unlock, updateRole) + kiểm tra/update database
2. **Frontend Domain Layer:** Entity, Repository, Use Cases
3. **Frontend Data Layer:** DTO, API, Repository Implementation
4. **Frontend Presentation Layer:** BLoC (Events, States, Bloc)
5. **Frontend UI:** Screens (Management, Detail)
6. **Integration:** Cập nhật routes, injector, AdminHomeScreen
7. **Testing:** Test các chức năng cơ bản

---

## 6. ƯỚC TÍNH THỜI GIAN

- **Backend:** 30 phút (2 API + database check)
- **Frontend Domain:** 30 phút
- **Frontend Data:** 45 phút
- **Frontend BLoC:** 45 phút
- **Frontend UI:** 2-3 giờ (2 screens với đầy đủ features)
- **Integration & Testing:** 30 phút

**Tổng:** ~5-6 giờ

