@echo off
chcp 65001 >nul
cd /d "%~dp0"
title SwanQ 资源管理

:MENU
cls
echo.
echo SwanQ Creative Hub 资源管理
echo =====================================
echo.
echo [1] 设置或修改本地密码
echo [2] 编辑 TXT 资源并自动上传
echo [3] 生成 TXT 资源模板
echo [4] 仅生成加密文件
echo [5] 仅上传已生成文件
echo [6] 查看当前 Git 状态
echo [0] 退出
echo.
set /p CHOICE=请输入序号：

if "%CHOICE%"=="1" goto SET_PASSWORD
if "%CHOICE%"=="2" goto EDIT_AND_UPLOAD
if "%CHOICE%"=="3" goto MAKE_TEMPLATE
if "%CHOICE%"=="4" goto BUILD_MENU
if "%CHOICE%"=="5" goto UPLOAD_MENU
if "%CHOICE%"=="6" goto STATUS_MENU
if "%CHOICE%"=="0" exit /b 0

goto MENU

:SET_PASSWORD
cls
echo.
echo 设置或修改本地密码
echo =====================================
echo 密码只保存在你电脑本地的 .swanq-password 文件里。
echo 这个文件已被 .gitignore 排除，不会提交到仓库。
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=Read-Host '输入新密码'; $c=Read-Host '再次输入密码'; if($p.Length -lt 10){Write-Host '密码至少 10 位'; exit 1}; if($p -ne $c){Write-Host '两次密码不一致'; exit 1}; Set-Content -Path '.swanq-password' -Value $p -Encoding UTF8; attrib +h .swanq-password 2>$null; Write-Host '已保存本地密码'"
echo.
pause
goto MENU

:EDIT_AND_UPLOAD
cls
echo.
echo 编辑 TXT 资源并自动上传
echo =====================================
if not exist resources.private.txt (
  echo 未找到 resources.private.txt，正在生成模板。
  call :CREATE_TEMPLATE_FILE
  if errorlevel 1 goto MENU
)
echo.
echo 关闭记事本后会自动加密并上传。
echo.
notepad resources.private.txt
call :BUILD_ONLY
if errorlevel 1 goto MENU
call :UPLOAD_ONLY
echo.
pause
goto MENU

:MAKE_TEMPLATE
cls
echo.
echo 生成 TXT 资源模板
echo =====================================
call :CREATE_TEMPLATE_FILE
echo.
pause
goto MENU

:BUILD_MENU
cls
echo.
echo 仅生成加密文件
echo =====================================
call :BUILD_ONLY
echo.
pause
goto MENU

:UPLOAD_MENU
cls
echo.
echo 仅上传已生成文件
echo =====================================
call :UPLOAD_ONLY
echo.
pause
goto MENU

:STATUS_MENU
cls
echo.
echo 当前 Git 状态
echo =====================================
git status --short
echo.
pause
goto MENU

:CREATE_TEMPLATE_FILE
if exist resources.private.txt (
  echo resources.private.txt 已存在。
  set /p OVERWRITE=输入 Y 覆盖，其他键取消：
  if /I not "%OVERWRITE%"=="Y" exit /b 1
)
(
  echo # SwanQ 私有资源清单
  echo # 写法：标题一行，链接一行，空行分隔
  echo # 分组可写成 [PS]、[工具]、[教程]
  echo # 这个文件含真实链接，只保存在本地，不要提交到 GitHub
  echo.
  echo [PS]
  echo win Photoshop CC 2018 x64
  echo https://example.com/resource-1
  echo.
  echo win Photoshop CC 2019 x64
  echo https://example.com/resource-2
  echo.
  echo [工具]
  echo 常用工具导航
  echo https://example.com/tools
) > resources.private.txt
echo 已生成 resources.private.txt
exit /b 0

:BUILD_ONLY
where node >nul 2>nul
if errorlevel 1 (
  echo 未检测到 Node.js。请先安装 Node.js。
  exit /b 1
)

echo.
echo 正在生成 resources.locked.js 和 resources.txt...
node build-resources.mjs
if errorlevel 1 (
  echo.
  echo 生成失败。请检查密码和 resources.private.txt 格式。
  exit /b 1
)

echo.
echo 生成完成。
exit /b 0

:UPLOAD_ONLY
where git >nul 2>nul
if errorlevel 1 (
  echo 未检测到 Git。请先安装 Git，并确认已经登录 GitHub。
  exit /b 1
)

git add resources.locked.js resources.txt

git diff --cached --quiet
if not errorlevel 1 (
  echo 没有需要上传的资源变化。
  exit /b 0
)

echo.
echo 正在提交资源更新...
git commit -m "Update encrypted resources"
if errorlevel 1 (
  echo 提交失败。
  exit /b 1
)

echo.
echo 正在推送到 GitHub...
git push
if errorlevel 1 (
  echo 推送失败。请检查网络、GitHub 登录状态或分支权限。
  exit /b 1
)

echo.
echo 已上传到 GitHub。等待 GitHub Pages 自动刷新即可。
exit /b 0
