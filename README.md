# Quản lý văn bản đến (GitHub Pages + Supabase)

Ứng dụng web tĩnh (một file `index.html`), đăng lên GitHub Pages. Văn bản, mốc báo cáo, danh sách cán bộ và tệp đính kèm lưu trên Supabase; nhiều người đăng nhập dùng chung và thấy thay đổi của nhau gần như tức thì.

## Cấu trúc
| File | Công dụng |
|---|---|
| `index.html` | Toàn bộ ứng dụng |
| `config.js` | Địa chỉ và khóa công khai (anon) của dự án Supabase QLVB |
| `supabase/schema.sql` | Bảng `vb_*`, bảo mật, kho tệp, đồng bộ thời gian thực (đã áp dụng sẵn cho QLVB) |
| `Day-len-GitHub.bat` | Bấm đúp để đẩy toàn bộ lên kho trungkz/QLVB (Windows) |
| `.github/workflows/pages.yml` | Tùy chọn: triển khai Pages bằng Actions (bấm chạy tay) |

## Trạng thái hiện tại
Dự án Supabase **QLVB** (`aaqiuppbcgdivtqrgqsc`) đã có sẵn bảng, kho tệp và bảo mật; `config.js` đã điền sẵn địa chỉ và khóa anon. Bạn chỉ cần làm Bước 1, 2, 3.

## Bước 1. Tạo tài khoản đăng nhập trên Supabase (QLVB)
1. **Authentication > Users > Add user**: nhập email và mật khẩu cho từng người dùng, chọn *Auto Confirm User*.
2. **Authentication > Sign In / Providers**: **tắt "Allow new users to sign up"** để người lạ không tự đăng ký được.
3. (Khuyên dùng) Bật *Leaked password protection* trong phần mật khẩu của Authentication.

## Bước 2. Đẩy lên GitHub (kho https://github.com/trungkz/QLVB)
**Cách 1, trên Windows:** cài Git (https://git-scm.com/download/win), giải nén gói, bấm đúp `Day-len-GitHub.bat`. Lần đầu Git sẽ mở trình duyệt để bạn đăng nhập GitHub.

**Cách 2, không cần Git:** vào kho trên github.com > **Add file > Upload files**, kéo thả `index.html`, `config.js`, `README.md` và thư mục `supabase`, bấm **Commit changes**.

**Cách 3, dòng lệnh:**
```bash
git init
git add .
git commit -m "Quan ly van ban den"
git branch -M main
git remote add origin https://github.com/trungkz/QLVB.git
git push -u origin main
```

## Bước 3. Bật GitHub Pages
1. Trong kho: **Settings > Pages > Build and deployment > Source: Deploy from a branch**, chọn nhánh **main**, thư mục **/ (root)**, bấm **Save**.
2. Chờ 1 đến 2 phút, trang chạy tại `https://trungkz.github.io/QLVB/`. Gói GitHub miễn phí cần kho ở chế độ **Public** mới bật được Pages.

## Chạy thử trên máy
Chạy máy chủ tĩnh trong thư mục này (không mở trực tiếp bằng `file://`):
```bash
python -m http.server 8080
```
Mở http://localhost:8080

## Chuyển dữ liệu từ bản offline
Ở bản offline cũ bấm **Sao lưu** để tải file `.json`. Ở bản này đăng nhập, bấm **Nhập từ bản offline** và chọn file đó: văn bản, cán bộ và tệp đính kèm được nạp lên Supabase (văn bản trùng mã được bỏ qua).

## Lưu ý bảo mật và vận hành
- `anon public key` là khóa công khai, nằm trong trang web là bình thường. An toàn dữ liệu dựa vào đăng nhập và chính sách RLS trong `schema.sql`. **Không** đưa `service_role key` vào kho.
- Hiện mọi tài khoản đã đăng nhập đều xem và sửa được toàn bộ văn bản. Cần phân quyền theo cán bộ thì sửa các policy RLS trong `schema.sql`.
- Tệp đính kèm lưu trong kho riêng tư `vb-attachments`, chỉ người đăng nhập mới mở được.
- Gói miễn phí của Supabase có giới hạn dung lượng, và dự án có thể bị tạm dừng nếu lâu không hoạt động.
