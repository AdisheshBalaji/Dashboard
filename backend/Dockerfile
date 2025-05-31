FROM python:3.10-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    POETRY_VERSION=1.8.2 \
    PATH="/root/.local/bin:$PATH" \
    PYTHONPATH="/backend/"

RUN apt-get update \
    && apt-get install -y curl build-essential libpq-dev \
    && curl -sSL https://install.python-poetry.org | python3 - \
    && apt-get clean

WORKDIR /backend

COPY pyproject.toml poetry.lock* requirements.txt /backend/
RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi

RUN pip install --no-cache-dir -r requirements.txt

COPY . /backend/

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
