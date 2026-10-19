FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y libpq-dev gcc && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Run collectstatic with build secret key
ENV DJANGO_SETTINGS_MODULE=excel_viewer_backend.settings
ENV SECRET_KEY=build_temp_secret_key_12345
RUN python manage.py collectstatic --noinput

ENV PORT=8000
EXPOSE 8000

CMD ["sh", "-c", "python manage.py migrate --noinput && exec gunicorn excel_viewer_backend.wsgi:application --bind 0.0.0.0:${PORT:-8000} --workers 2 --timeout 120"]
