@echo off
REM run_tests.bat - Скрипт для запуска тестов на Windows

echo ==========================================
echo 🧪 ЗАПУСК ТЕСТОВ ДЛЯ FACE ACCESS SYSTEM
echo ==========================================
echo.

echo 🔍 Проверка Python...
python --version
if errorlevel 1 (
    echo ❌ Python не найден
    pause
    exit /b 1
)

echo.
echo 📦 Проверка зависимостей...
python -c "import cv2" 2>nul
if errorlevel 1 (
    echo ❌ opencv-python не установлен
    echo    Установка: pip install opencv-python numpy
    pause
    exit /b 1
)

python -c "import numpy" 2>nul
if errorlevel 1 (
    echo ❌ numpy не установлен
    echo    Установка: pip install opencv-python numpy
    pause
    exit /b 1
)

echo.
echo ✅ Все зависимости установлены

echo.
echo 🔥 Запуск smoke-тестов...
python tests\test_smoke.py

echo.
echo ✅ Тестирование завершено!
pause
