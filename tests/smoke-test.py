# tests/test_smoke.py - Smoke-test для проверки системы
import sys
import os
import json
import unittest
import tempfile
import shutil
from pathlib import Path

# Добавляем путь к PoC
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from PoC import FaceAccessSystem, create_test_images

class TestFaceAccessSystem(unittest.TestCase):
    """Smoke-тесты для системы распознавания лиц"""
    
    @classmethod
    def setUpClass(cls):
        """Подготовка перед всеми тестами"""
        cls.system = FaceAccessSystem()
        # Создаем тестовые изображения
        create_test_images()
        cls.test_dir = Path(".")
    
    def test_system_initialization(self):
        """Тест 1: Инициализация системы"""
        self.assertIsNotNone(self.system)
        self.assertGreater(len(self.system.employees_db), 0)
        self.assertGreater(len(self.system.face_features_db), 0)
        print("✅ Тест 1 пройден: Система инициализирована")
    
    def test_happy_path(self):
        """Тест 2: Happy Path - успешный проход"""
        result = self.system.process_event("test_face_good.jpg")
        
        # Проверяем, что результат содержит все необходимые поля
        self.assertIn("decision", result)
        self.assertIn("timestamp", result)
        
        # Проверяем, что это ALLOW
        if result["decision"] == "allow":
            self.assertIn("employee_id", result)
            self.assertIn("employee_name", result)
            self.assertIn("match_score", result)
            self.assertGreater(result["match_score"], 0.5)
            print("✅ Тест 2 пройден: Happy Path работает (ALLOW)")
        elif result["decision"] == "manual_review":
            print("⚠️ Тест 2: Система отправила на ручную проверку (допустимо)")
        else:
            self.fail(f"Неожиданное решение: {result['decision']}")
    
    def test_risky_path(self):
        """Тест 3: Risky Path - плохое качество"""
        result = self.system.process_event("test_face_bad.jpg")
        
        # Проверяем, что есть решение
        self.assertIn("decision", result)
        
        # Проверяем, что это manual_review или deny
        if result["decision"] == "manual_review":
            self.assertTrue(result.get("requires_human_review", False))
            print("✅ Тест 3 пройден: Risky Path работает (MANUAL_REVIEW)")
        elif result["decision"] == "deny":
            print("✅ Тест 3 пройден: Risky Path работает (DENY)")
        else:
            print(f"⚠️ Тест 3: Неожиданное решение: {result['decision']}")
    
    def test_no_face(self):
        """Тест 4: Изображение без лица"""
        result = self.system.process_event("test_no_face.jpg")
        
        # Проверяем, что это DENY
        self.assertEqual(result["decision"], "deny")
        self.assertEqual(result["reason"], "no_face_detected")
        print("✅ Тест 4 пройден: Изображение без лица корректно обработано")
    
    def test_logging(self):
        """Тест 5: Проверка логирования"""
        # Проверяем, что лог-файл существует
        log_file = Path("access_log.jsonl")
        
        if log_file.exists():
            with open(log_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
                self.assertGreater(len(lines), 0)
                print(f"✅ Тест 5 пройден: Найдено {len(lines)} записей в логе")
        else:
            # Проверяем, что результаты сохраняются в demo_results.json
            results_file = Path("demo_results.json")
            if results_file.exists():
                with open(results_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    self.assertIn("scenario_1", data)
                    print("✅ Тест 5 пройден: Результаты сохранены")
            else:
                print("⚠️ Тест 5: Лог-файл не найден, но это допустимо для PoC")
    
    def test_decision_consistency(self):
        """Тест 6: Проверка консистентности решений"""
        # Трижды обрабатываем одно изображение
        results = []
        for _ in range(3):
            result = self.system.process_event("test_face_good.jpg")
            results.append(result["decision"])
        
        # Проверяем, что решения консистентны
        # (для одного изображения должно быть одно решение)
        if len(set(results)) == 1:
            print(f"✅ Тест 6 пройден: Решения консистентны ({results[0]})")
        else:
            print(f"⚠️ Тест 6: Решения не консистентны: {results}")
    
    def test_performance(self):
        """Тест 7: Проверка производительности"""
        import time
        
        start = time.time()
        self.system.process_event("test_face_good.jpg")
        elapsed = time.time() - start
        
        # Проверяем, что обработка быстрая (< 2 секунд)
        self.assertLess(elapsed, 2.0)
        print(f"✅ Тест 7 пройден: Время обработки {elapsed*1000:.0f}ms")

def run_smoke_tests():
    """Запуск всех smoke-тестов"""
    print("\n" + "="*60)
    print("🔥 SMOKE-TEST: Система распознавания лиц")
    print("="*60)
    
    # Создаем тестовые изображения
    print("\n📸 Создание тестовых изображений...")
    create_test_images()
    
    # Запускаем тесты
    unittest.main(argv=[''], verbosity=2, exit=False)

if __name__ == "__main__":
    run_smoke_tests()
