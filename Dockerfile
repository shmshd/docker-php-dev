FROM php:8.0-apache

RUN apt update; \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -; \
    apt install -y --no-install-recommends  \
    zip unzip libzip-dev \
    libsodium-dev \
    libonig-dev \
    zlib1g-dev \
    libicu-dev \
    libpng-dev  \
    libcurl4-openssl-dev \
    openssl \
    vim \
    cron \
    nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install \
    bcmath \
    -j$(nproc) intl \
    mbstring \
    pdo_mysql \
    opcache \
    sodium \
    zip \
    && docker-php-ext-configure \
    zip \
    && pecl install \
    apcu \
    xdebug \
    && docker-php-ext-enable \
    apcu \
    opcache \
    xdebug

RUN mv "${PHP_INI_DIR}/php.ini-development" "${PHP_INI_DIR}/php.ini"

COPY ./000-default.conf "${APACHE_CONFDIR}/sites-available/000-default.conf"

RUN a2enmod rewrite

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

ARG UNAME
ARG UID
ARG GID
RUN groupadd -g $GID $UNAME; \
    useradd -m -u $UID -g $GID -s /bin/bash $UNAME; \
    usermod -a -G www-data $UNAME
USER $UNAME

CMD ["apache2-foreground"]
