# 儿童学习进度监督系统 - 手机版 APK 打包说明

---

## 📱 方案一：在线打包（推荐，最简单）

### 步骤 1：准备文件
确保 `www/index.html` 文件已准备好

### 步骤 2：选择打包服务

| 服务 | 网址 | 费用 | 说明 |
|------|------|------|------|
| **WebIntoApp** | https://www.webintoapp.com | 免费 | 推荐，无广告 |
| **AppsGeyser** | https://www.appsgeyser.com | 免费 | 有广告 |
| **Median.co** | https://median.co | 付费 | 质量好 |

### 步骤 3：上传文件
1. 访问上述任一网站
2. 选择"HTML to APK"或"Website to APK"
3. 上传 `www` 文件夹或直接上传 `index.html`
4. 配置应用名称：**儿童学习进度监督**
5. 配置应用图标：上传 `assets/icon.png`（可选）

### 步骤 4：下载 APK
1. 等待打包完成（约 5-10 分钟）
2. 下载生成的 APK 文件
3. 发送到手机安装

---

## 📱 方案二：使用 Capacitor 打包（需要技术环境）

### 环境要求
- Node.js 14+
- Android Studio
- Java JDK 8+

### 步骤 1：初始化项目
```bash
cd C:\Users\leilei\Desktop\StudyTracker-Mobile
npm init -y
npm install @capacitor/core @capacitor/cli
npx cap init
```

### 步骤 2：配置 Capacitor
编辑 `capacitor.config.json`：
```json
{
  "appId": "com.studytracker.app",
  "appName": "儿童学习进度监督",
  "webDir": "www",
  "bundledWebRuntime": false
}
```

### 步骤 3：添加安卓平台
```bash
npm install @capacitor/android
npx cap add android
npx cap sync
```

### 步骤 4：打开 Android Studio
```bash
npx cap open android
```

### 步骤 5：生成 APK
1. 在 Android Studio 中点击 **Build → Build Bundle(s) / APK(s) → Build APK(s)**
2. 等待编译完成
3. APK 文件位置：`android/app/build/outputs/apk/debug/app-debug.apk`

---

## 📱 方案三：使用 Cordova 打包

### 环境要求
- Node.js 14+
- Java JDK 8+
- Android SDK

### 步骤 1：安装 Cordova
```bash
npm install -g cordova
```

### 步骤 2：创建项目
```bash
cd C:\Users\leilei\Desktop
cordova create StudyTracker-Mobile com.studytracker.app 儿童学习进度监督
cd StudyTracker-Mobile
```

### 步骤 3：配置项目
```bash
# 删除默认文件
rm -rf www/*

# 复制网页文件
cp -r ../StudyTracker-Mobile/www/* www/

# 添加安卓平台
cordova platform add android
```

### 步骤 4：打包 APK
```bash
cordova build android
```

APK 文件位置：`platforms/android/app/build/outputs/apk/debug/app-debug.apk`

---

## 🎨 应用图标制作

### 要求
- 尺寸：512x512 像素
- 格式：PNG
- 背景：透明或纯色

### 在线制作工具
- **Figma**: https://www.figma.com
- **Canva**: https://www.canva.com
- **Icon Kitchen**: https://icon.kitchen

---

## 📋 打包清单

- [ ] `www/index.html` 文件已准备
- [ ] 选择打包方案（在线/Capacitor/Cordova）
- [ ] 准备应用图标（512x512 PNG）
- [ ] 配置应用名称和包名
- [ ] 生成 APK 文件
- [ ] 测试安装和运行

---

## 📞 常见问题

### Q: 在线打包需要多长时间？
A: 通常 5-10 分钟，取决于文件大小。

### Q: APK 文件有多大？
A: 约 2-5MB（在线打包），30-50MB（Capacitor/Cordova）。

### Q: 可以在 iPhone 上使用吗？
A: 需要另外打包 iOS 版本（.ipa 文件）。

### Q: 数据会同步吗？
A: 手机版和网页版数据独立存储，暂不同步。

---

## 📅 版本信息

- 版本：v1.0 Mobile
- 打包日期：2026 年 3 月 10 日
- 目标平台：Android 10+
