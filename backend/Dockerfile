# Multi-stage build için Python base image
FROM python:3.11-slim as builder

# Sistem bağımlılıklarını yükle
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Python bağımlılıklarını yükle
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Production stage
FROM python:3.11-slim

# Güvenlik için non-root user oluştur
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Sistem bağımlılıklarını yükle (sadece runtime)
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Python bağımlılıklarını builder stage'den kopyala
COPY --from=builder /root/.local /home/appuser/.local

# Uygulama dizinini oluştur
WORKDIR /app

# Uygulama kodunu kopyala
COPY . .

# Logs dizinini oluştur
RUN mkdir -p /app/logs && chown -R appuser:appuser /app

# PATH'e local bin'i ekle
ENV PATH=/home/appuser/.local/bin:$PATH

# Environment variables
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
ENV ENVIRONMENT=production
ENV LOG_LEVEL=INFO
ENV LOG_FILE=/app/logs/app.log

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Port'u expose et
EXPOSE 8000

# User'ı değiştir
USER appuser

# Uygulamayı başlat
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"] 