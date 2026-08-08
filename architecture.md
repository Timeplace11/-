```markdown
# Архитектура системы распознавания лиц

## Обзор
Система построена по гибридной edge-cloud архитектуре с акцентом на низкую задержку и безопасность биометрических данных.

## Диаграмма архитектуры (Mermaid)

```mermaid
graph TB
    subgraph "Проходная (Edge)"
        Camera[Камера]
        EdgeNode[Edge Node GPU]
        subgraph "Edge Services"
            FaceDetector[Детектор лиц]
            QualityChecker[Оценка качества]
            LivenessCheck[Liveness Detection]
            EmbeddingExtractor[Извлечение эмбеддинга]
            ANNIndex[ANN Index<br>локальный кеш]
            DecisionEngine[Decision Engine]
        end
        Turnstile[Турникет]
        GuardUI[UI Охраны]
    end

    subgraph "Центральный сервис (Cloud/Center)"
        CentralDB[(База сотрудников)]
        EmbeddingDB[(Хранилище эмбеддингов)]
        AuditDB[(Audit Log)]
        ModelRegistry[(Реестр моделей)]
        SyncService[Sync Service]
        Monitoring[Мониторинг]
    end

    Camera --> EdgeNode
    EdgeNode --> FaceDetector
    FaceDetector --> QualityChecker
    QualityChecker --> LivenessCheck
    LivenessCheck --> EmbeddingExtractor
    EmbeddingExtractor --> ANNIndex
    
    ANNIndex --> DecisionEngine
    DecisionEngine --> Turnstile
    DecisionEngine --> GuardUI
    DecisionEngine --> AuditDB
    
    SyncService --> CentralDB
    SyncService --> EmbeddingDB
    SyncService --> ANNIndex
    
    ModelRegistry --> EdgeNode
    Monitoring --> EdgeNode
    Monitoring --> CentralDB
