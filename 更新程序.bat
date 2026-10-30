@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"

echo ==========================================
echo   一键构建并更新本机已安装的程序
echo ==========================================
echo.

set "EPHEMERAL=windows\flutter\ephemeral"
set "BUILD_DIR=build\windows\x64\runner\Release"
set "EXE_NAME=crop_image.exe"
set "INSTALL_DIR=%LOCALAPPDATA%\Programs\Crop Image"

echo [1/4] 修复构建环境
rem cpp 源文件缺失后 flutter 不会自动补回, 删掉 ephemeral 交给普通构建重新解包
if not exist "%EPHEMERAL%\cpp_client_wrapper\core_implementations.cc" (
    echo     cpp_client_wrapper 不完整, 清理后重建
    if exist "%EPHEMERAL%" rmdir /s /q "%EPHEMERAL%"
)

echo.
echo [2/4] 构建 Release 版本
rem 本机 fvm 构建成功后仍会返回崩溃码, 因此先删旧 exe, 用产物是否存在判断构建结果
if exist "%BUILD_DIR%\%EXE_NAME%" del /q "%BUILD_DIR%\%EXE_NAME%"
fvm flutter build windows --release
if not exist "%BUILD_DIR%\%EXE_NAME%" goto :fail

echo.
echo [3/4] 校验构建产物
if not exist "%BUILD_DIR%\%EXE_NAME%" goto :fail
echo     %BUILD_DIR%\%EXE_NAME%

echo.
echo [4/4] 关闭正在运行的程序并覆盖安装
taskkill /f /im %EXE_NAME% >nul 2>&1
pwsh -NoProfile -Command "Start-Sleep -Milliseconds 800"
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
rem /MIR 镜像同步, 保证旧版本残留文件被清掉; robocopy 退出码小于 8 均为成功
robocopy "%BUILD_DIR%" "%INSTALL_DIR%" /MIR /NFL /NDL /NJH /NJS /R:1 /W:1 >nul
if errorlevel 8 goto :fail

if not exist "%INSTALL_DIR%\%EXE_NAME%" goto :fail

echo.
echo 更新完成: %INSTALL_DIR%\%EXE_NAME%
goto :end

:fail
echo.
echo [失败] 更新未完成, 请查看上方输出.
set "FAILED=1"
goto :end

:end
pause
if defined FAILED exit /b 1
exit /b 0
