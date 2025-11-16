FROM httpd:2.4-alpine

COPY docker/apache/conf/httpd.conf /usr/local/apache2/conf/httpd.conf

RUN mkdir -p /usr/local/apache2/conf/sites-available

COPY docker/apache/conf/opencart.conf /usr/local/apache2/conf/sites-available/opencart.conf

# Copy the upload directory content to the image
COPY upload /var/www/upload

# Create the directory structure that Apache expects and set permissions
RUN chown -R www-data:www-data /var/www

EXPOSE 80
