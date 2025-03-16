# Usa a imagem Python slim como base
FROM python:3.12-slim AS base

# Configura variáveis de ambiente
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_VERSION=1.8.3 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

# Adiciona o Poetry e o ambiente virtual ao PATH
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Instala dependências do sistema
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        build-essential \
        libpq-dev \
        gcc \
    && rm -rf /var/lib/apt/lists/*

# Instala o Poetry
RUN pip install poetry

# Define o diretório de trabalho para a instalação de dependências
WORKDIR $PYSETUP_PATH

# Copia os arquivos do Poetry (para cache eficiente)
COPY poetry.lock pyproject.toml ./

# Instala as dependências sem o ambiente de desenvolvimento e sem instalar o projeto atual
RUN poetry install --no-root

# Define o diretório da aplicação
WORKDIR /app

# Copia o código-fonte do projeto
COPY . /app/

# Expõe a porta padrão do Django
EXPOSE 8000

# Comando para iniciar o servidor
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]