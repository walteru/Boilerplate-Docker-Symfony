FROM php:8.2-apache
ARG UID

# Create user with same permissions as host and some useful stuff
RUN adduser -u ${UID} --disabled-password --gecos "" appuser
RUN mkdir /home/appuser/.ssh
RUN chown -R appuser:appuser /home/appuser/
RUN echo "StrictHostKeyChecking no" >> /home/appuser/.ssh/config
RUN echo "alias sf=/var/www/html/bin/console" >> /home/appuser/.bashrc
RUN echo "alias cls=clear" >> /home/appuser/.bashrc
RUN echo "alias dsv='sf doctrine:schema:validate'" >> /home/appuser/.bashrc
RUN echo "alias dsc='sf doctrine:schema:create'" >> /home/appuser/.bashrc
RUN echo "alias dms='sf doctrine:migration:status'" >> /home/appuser/.bashrc
RUN echo "alias dmm='sf doctrine:migration:migrate'" >> /home/appuser/.bashrc
RUN echo "alias dsu='sf doctrine:schema:update --dump-sql'" >> /home/appuser/.bashrc
RUN echo "alias cc='sf cache:clear'" >> /home/appuser/.bashrc

# Install packages and PHP extensions
RUN apt update \
    # common libraries and extensions
    && apt install -y git acl openssl openssh-client wget zip \
    && apt install -y libpng-dev zlib1g-dev libzip-dev libxml2-dev libicu-dev \
    && docker-php-ext-install intl pdo gd zip \
    # for MySQL
    && docker-php-ext-install pdo_mysql \
    # XDEBUG and APCu
    && pecl install xdebug apcu \
    # enable Docker extensions
    && docker-php-ext-enable --ini-name 05-opcache.ini opcache xdebug apcu \
    # Install Python and pip
    && apt install -y python3 python3-pip \
    # Clean up
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install and update composer
RUN curl https://getcomposer.org/composer.phar -o /usr/bin/composer && chmod +x /usr/bin/composer
RUN composer self-update

# Instalar Node.js y Yarn
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install --global yarn

## Install Symfony binary
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash
RUN apt install symfony-cli

RUN mkdir -p /var/www/html

# Config XDEBUG
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Update Apache config
COPY ./default.conf /etc/apache2/sites-available/default.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && a2enmod rewrite \
    && a2dissite 000-default \
    && a2ensite default \
    && service apache2 restart

# Modify upload file size
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY ./php.ini "$PHP_INI_DIR/conf.d/"

WORKDIR /var/www/html