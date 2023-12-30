FROM python:3.11-slim as builder
ENV PYTHONUNBUFFERED=1

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    postgresql-client libpq-dev \
    gcc python3-dev \
    netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /var/www


# Final stage
FROM python:3.11-slim
ENV PYTHONUNBUFFERED=1

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /var/www


# Copy the Python environment from the builder stage
COPY --from=builder /usr/local /usr/local
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt psycopg2-binary Faker

# Copy the application code
COPY ./migrations ./migrations
COPY ./app ./app
COPY ./react-vite/dist ./react-vite/dist

# Copy other necessary files
COPY entrypoint.sh /entrypoint.sh
COPY ./.flaskenv .

RUN chmod +x /entrypoint.sh && \
    useradd -m myuser
USER myuser

ENTRYPOINT ["/entrypoint.sh"]
CMD ["gunicorn", "app:app"]
