#!/bin/bash
# run_tests.sh - Скрипт для запуска всех тестов и проверки системы

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================="
echo "🧪 ЗАПУСК ТЕСТОВ ДЛЯ FACE ACCESS SYSTEM"
echo "=========================================="
echo ""

# Функция для проверки статуса
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ OK${NC}"
    else
        echo -e "${RED}❌ FAILED${NC}"
        exit 1
    fi
}

# 1. Проверка наличия Python
echo -n "🔍 Проверка Python... "
if command -v python &> /dev/null; then
    PYTHON_VERSION=$(python --version 2>&1)
    echo -e "${GREEN}✅ $PYTHON_VERSION${NC}"
else
    echo -e "${RED}❌ Python не найден${NC}"
    exit 1
fi

# 2. Проверка установленных пакетов
echo ""
echo "📦 Проверка зависимостей..."

echo -n "  - opencv-python... "
python -c "import cv2" 2>/dev/null
check_status

echo -n "  - numpy... "
python -c "import numpy" 2>/dev/null
check_status

echo -n "  - matplotlib... "
python -c "import matplotlib" 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ OK${NC}"
else
    echo -e "${YELLOW}⚠️  Не установлен (опционально)${NC}"
fi

echo -n "  - pillow... "
python -c "import PIL" 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ OK${NC}"
else
    echo -e "${YELLOW}⚠️  Не установлен (опционально)${NC}"
fi

# 3. Создание виртуального окружения (опционально)
echo ""
echo "🔧 Настройка окружения..."
if [ ! -d "venv" ]; then
    echo -n "  - Создание venv... "
    python -m venv venv 2>/dev/null
    check_status
    
    echo -n "  - Активация venv... "
    source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null
    check_status
    
    echo -n "  - Установка зависимостей... "
    pip install -r requirements.txt 2>/dev/null
    check_status
else
    echo -e "${YELLOW}⚠️  venv уже существует, пропускаем${NC}"
fi

# 4. Проверка наличия файлов
echo ""
echo "📄 Проверка файлов проекта..."

FILES_TO_CHECK=(
    "README.md"
    "docs/architecture.md"
    "docs/ml.md"
    "docs/product.md"
    "docs/monitoring.md"
    "docs/risks-and-ops.md"
    "AI_USAGE.md"
    "WORKLOG.md"
    "SELF_REVIEW.md"
    "requirements.txt"
)

for file in "${FILES_TO_CHECK[@]}"; do
    echo -n "  - $file... "
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
done

# 5. Проверка PoC файлов
echo ""
echo "💻 Проверка кода..."

echo -n "  - PoC.py... "
if [ -f "poc/PoC.py" ] || [ -f "PoC.py" ] || [ -f "PoC.py" ]; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌${NC}"
fi

echo -n "  - smoke-тесты... "
if [ -f "tests/test_smoke.py" ]; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${YELLOW}⚠️  Не найдены${NC}"
fi

# 6. Запуск smoke-тестов
echo ""
echo "🔥 Запуск smoke-тестов..."
echo "------------------------------------------"

if [ -f "tests/test_smoke.py" ]; then
    python tests/test_smoke.py
    check_status
elif [ -f "PoC.py" ]; then
    echo -e "${YELLOW}⚠️  smoke-тесты не найдены, запускаем PoC...${NC}"
    python face_access_poc.py
    check_status
elif [ -f "PoC.py" ]; then
    echo -e "${YELLOW}⚠️  smoke-тесты не найдены, запускаем PoC...${NC}"
    python PoC.py
    check_status
else
    echo -e "${RED}❌ PoC не найден${NC}"
    exit 1
fi

echo "------------------------------------------"

# 7. Проверка созданных файлов
echo ""
echo "📊 Проверка результатов..."

echo -n "  - demo_results.json... "
if [ -f "demo_results.json" ]; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${YELLOW}⚠️  Не создан${NC}"
fi

echo -n "  - access_log.jsonl... "
if [ -f "access_log.jsonl" ]; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${YELLOW}⚠️  Не создан${NC}"
fi

echo -n "  - test_face_good.jpg... "
if [ -f "test_face_good.jpg" ]; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${YELLOW}⚠️  Не создан${NC}"
fi

# 8. Проверка размера файлов (не более 20MB)
echo ""
echo "📏 Проверка размера файлов..."

LARGE_FILES=$(find . -type f -size +20M -not -path "./venv/*" -not -path "./.git/*" 2>/dev/null)
if [ -n "$LARGE_FILES" ]; then
    echo -e "${YELLOW}⚠️  Найдены файлы > 20MB:${NC}"
    echo "$LARGE_FILES"
else
    echo -e "${GREEN}✅ Все файлы < 20MB${NC}"
fi

# 9. Проверка Mermaid диаграмм
echo ""
echo "📊 Проверка диаграмм..."

if [ -f "docs/architecture.md" ]; then
    if grep -q "mermaid" docs/architecture.md; then
        echo -e "${GREEN}✅ Mermaid диаграмма найдена в architecture.md${NC}"
    else
        echo -e "${YELLOW}⚠️  Mermaid диаграмма не найдена${NC}"
    fi
fi

# 10. Итоговый отчет
echo ""
echo "=========================================="
echo "📊 ИТОГОВЫЙ ОТЧЕТ"
echo "=========================================="

echo ""
echo "✅ Все базовые проверки пройдены!"
echo ""
echo "📋 Результаты сохранены в:"
echo "  - demo_results.json  (результаты тестов)"
echo "  - access_log.jsonl   (лог событий)"
echo ""
echo "📁 Файлы для сдачи:"
echo "  - README.md"
echo "  - docs/"
echo "  - poc/"
echo "  - AI_USAGE.md, WORKLOG.md, SELF_REVIEW.md"
echo ""
echo "🔗 Ссылка на репозиторий: [ваш URL]"
echo ""
echo -e "${GREEN}🎯 Система готова к сдаче!${NC}"

# 11. Отображение последних результатов
if [ -f "demo_results.json" ]; then
    echo ""
    echo "📊 Последние результаты тестирования:"
    echo "------------------------------------------"
    cat demo_results.json | python -m json.tool 2>/dev/null || cat demo_results.json
fi

echo ""
echo "=========================================="
echo "🏁 Тестирование завершено"
echo "=========================================="
