FROM php:8.2-cli

WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_sqlite bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create user to run artisan commands (optional but good practice)
# For simplicity in this dev environment, we'll run as root or default.

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
