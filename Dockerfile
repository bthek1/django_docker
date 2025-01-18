# Pull base image
FROM python:3.12.2-slim-bookworm

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install necessary tools
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
    sudo \
    curl \
    git \
    vim \
    python3-pip \
    python3-dev \
    build-essential \
    direnv \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set ARG for password (to be passed during build)
ARG USER_PASSWORD

# Create a non-root user with sudo privileges
RUN useradd -ms /bin/bash devuser && \
    echo "devuser:3719" | chpasswd && \
    usermod -aG sudo devuser

# Set the default user to devuser
USER devuser

# Set the working directory
WORKDIR /home/devuser/django_docker

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Add Poetry to PATH
ENV PATH="/home/devuser/.local/bin:$PATH"

# Copy the application code
COPY . /home/devuser/django_docker

# # Install dependencies with Poetry
# RUN poetry config virtualenvs.create true && \
#     poetry install --no-interaction --no-ansi


# Enable direnv by adding configuration to .bashrc
RUN echo 'eval "$(direnv hook bash)"' >> ~/.bashrc


# Expose port 8002
EXPOSE 8002

# Default command
CMD ["bash"]


# # Switch to the default user
# CMD ["python", "/code/manage.py", "runserver", "0.0.0.0:8002"]
