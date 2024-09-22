# Вибираємо базовий образ на основі Python
FROM python:3.9-slim

# Встановлюємо залежності системи
RUN apt-get update && apt-get install -y \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Встановлюємо робочу директорію всередині контейнера
WORKDIR /app

# Копіюємо файли аплікації до контейнера
COPY . /app

# Встановлюємо Python-залежності з requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Робимо bash скрипт виконуваним
RUN chmod +x script.sh

# Відкриваємо порт 5000 для Flask
EXPOSE 5000

# Команда для запуску додатку
CMD ["python", "app.py"]

