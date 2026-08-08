## Диаграмма архитектуры

```mermaid
graph TB
    subgraph "Проходная (Edge)"
        Camera[Камера]
        EdgeNode[Edge Node GPU]
        subgraph "Edge Services"
            FaceDetector[Детектор лиц<br/>OpenCV Haarcascade]
            QualityChecker[Оценка качества<br/>Resolution, Sharpness, Contrast]
            LivenessCheck[Liveness Detection<br/>Проверка глаз]
            EmbeddingExtractor[Извлечение эмбеддинга<br/>Гистограмма + нормализация]
            ANNIndex[ANN Index<br/>Сравнение эмбеддингов]
            DecisionEngine[Decision Engine<br/>Правила принятия решений]
        end
        Turnstile[Турникет]
        GuardUI[UI Охраны<br/>manual_review]
    end

    subgraph "Центральный сервис"
        CentralDB[(База сотрудников<br/>PostgreSQL)]
        EmbeddingDB[(Хранилище эмбеддингов<br/>pgvector)]
        AuditDB[(Audit Log<br/>ClickHouse)]
        SyncService[Sync Service<br/>Обновление кеша]
        Monitoring[Мониторинг<br/>Grafana + Prometheus]
    end

    Camera --> EdgeNode
    EdgeNode --> FaceDetector
    FaceDetector --> QualityChecker
    QualityChecker --> LivenessCheck
    LivenessCheck --> EmbeddingExtractor
    EmbeddingExtractor --> ANNIndex
    ANNIndex --> DecisionEngine
    
    DecisionEngine -->|allow| Turnstile
    DecisionEngine -->|manual_review| GuardUI
    DecisionEngine --> AuditDB
    
    SyncService --> CentralDB
    SyncService --> EmbeddingDB
    SyncService --> ANNIndex
    
    Monitoring --> EdgeNode
    Monitoring --> CentralDB
    Monitoring --> AuditDB
    
    classDef edge fill:#e1f5fe,stroke:#01579b
    classDef center fill:#f3e5f5,stroke:#4a148c
    classDef data fill:#e8f5e9,stroke:#1b5e20
    
    class Camera,EdgeNode,FaceDetector,QualityChecker,LivenessCheck,EmbeddingExtractor,ANNIndex,DecisionEngine,Turnstile,GuardUI edge
    class CentralDB,EmbeddingDB,AuditDB,SyncService,Monitoring center
