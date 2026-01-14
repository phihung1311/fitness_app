# Hướng Dẫn Sửa Lỗi Google Sign-In "channel-error"

## Lỗi: PlatformException(channel-error Unable to establish connection...)

Lỗi này thường xảy ra khi package chưa được rebuild hoặc thiếu cấu hình.

## Các Bước Sửa Lỗi:

### Bước 1: Clean và Rebuild App

```bash
cd fitness_app

# Clean build
flutter clean

# Get dependencies lại
flutter pub get

# Rebuild app
flutter run
```

### Bước 2: Kiểm Tra Google Play Services

**Nếu đang dùng Android Emulator:**
- Đảm bảo emulator có Google Play Services
- Sử dụng emulator có Google APIs (không phải AOSP)
- Hoặc cài Google Play Services trên emulator

**Nếu đang dùng thiết bị thật:**
- Đảm bảo thiết bị có Google Play Services
- Kiểm tra kết nối internet

### Bước 3: Kiểm Tra Cấu Hình Google Cloud Console

1. **Package Name**: Phải khớp với `applicationId` trong `build.gradle`
   - Hiện tại: `com.stu.lv.fitness_app`

2. **SHA-1 Fingerprint**: Phải được thêm vào Android Client ID
   - Chạy: `cd android && ./gradlew signingReport`
   - Copy SHA-1 và thêm vào Google Cloud Console

3. **OAuth Consent Screen**: Phải được cấu hình
   - Vào Google Cloud Console > OAuth consent screen
   - Đảm bảo đã điền đầy đủ thông tin

### Bước 4: Kiểm Tra Backend

Đảm bảo backend đã có biến môi trường:
```env
GOOGLE_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
```

### Bước 5: Test Lại

1. Stop app hoàn toàn
2. Clean và rebuild
3. Chạy lại app
4. Test Google Sign-In

## Nếu Vẫn Lỗi:

### Kiểm Tra Logs

```bash
flutter run --verbose
```

Xem log để tìm lỗi cụ thể.

### Thử Trên Thiết Bị Thật

Nếu emulator không có Google Play Services, thử trên thiết bị thật.

### Kiểm Tra minSdkVersion

Đảm bảo `minSdkVersion >= 21` trong `build.gradle`.

## Lưu Ý:

- **Không cần** thêm Android Client ID vào `strings.xml`
- Package sẽ tự động lấy từ Google Cloud Console
- Quan trọng nhất: **SHA-1 phải được thêm vào Google Cloud Console**
