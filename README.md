# Twit Web application

 <h3>. приложение</h3> 
Мое приложение - это клон социальных сетей, приложение crud, в котором пользователи создают учетные записи и публикуют, редактируют посты, добавляют изображения к постам и комментарии.
Пользователь может зарегистрироваться на веб-сайте, и он увидит все сообщения от других пользователей, и он может сделать Post (Twit).
он может просмотреть свой пост, отредактировать его или удалить. а также он может прокомментировать любой Post.Пользователь также может видеть комментарии к своему посту, которые пришли от других пользователей,
и он может ответить на этот комментарий. 


![](public/Images/twit1.jpg)
![](public/Images/twit2.jpg)
![](public/Images/twit3.jpg)
![](public/Images/twit4.jpg)
![](public/Images/twit5.jpg)
![](public/Images/twit6.jpg)
![](public/Images/twit7.jpg)
![](public/Images/twit8.jpg)

# Построенный с
1. Php 8
2. Laravel 10
3. ReactJs
4. Mysql
5. Docker & docker compose
6. Prometheus Custom metrics
7. Prometheus Alertmanager
8. Node exporter
9. Blackbox exporte
10. Mysql exporter
11. Nginx

# Github actions
1. я создал .github/workflows/ci.yml для actions
```bash
name: CI/CD Pipeline& telegram notifications
on: [push]
jobs:

  build:
    name: Build Push Docker Image
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master

      - name: send photo message
        uses: ./
        with:
          to: ${{ secrets.TELEGRAM_CHAT_ID }}
          token: ${{ secrets.TELEGRAM_TOKEN }}
          photo: './tests/notify.png'



      # Container Security Scanning
      - name: Install Trivy
        run: |
          wget https://github.com/aquasecurity/trivy/releases/download/v0.21.0/trivy_0.21.0_Linux-64bit.tar.gz
          tar zxvf trivy_0.21.0_Linux-64bit.tar.gz
          sudo mv trivy /usr/local/bin/


      - name: Build and Push Docker Image
        run: |
          docker-compose build
          echo ${{ secrets.DOCKERHUB_ACCESS_TOKEN }} | docker login -u ${{ secrets.DOCKERHUB_USERNAME }} --password-stdin
          docker-compose push
        env:
          DOCKER_BUILDKIT: 1


      - name: Scan Container Image
        run: trivy image ${{ secrets.DOCKERHUB_USERNAME }}/twit:latest\



      # Sending success or failure notifications to Telegram
      - name: Send Notification on Success
        if: success()
        uses: ./
        with:
          to: ${{ secrets.TELEGRAM_CHAT_ID }}
          token: ${{ secrets.TELEGRAM_TOKEN }}
          message: |
            ✅ **Pipeline Completed Successfully!**
            New push on branch: `${{ github.ref }}`
            Commit Message: `${{ github.event.head_commit.message }}`
            *Check out the GitHub repository ` (https://github.com/RaClover/Twit-app) for more details.*

      - name: Send Notification on Failure
        if: failure()
        uses: ./
        with:
          to: ${{ secrets.TELEGRAM_CHAT_ID }}
          token: ${{ secrets.TELEGRAM_TOKEN }}
          message: |
            ❌ **Pipeline Failed!**
            New push on branch: `${{ github.ref }}`
            Commit Message: `${{ github.event.head_commit.message }}`
            *Check out the GitHub repository ` (https://github.com/RaClover/Twit-app) for more details.*








```
## Workflow Overview

Рабочий процесс запускается автоматически всякий раз, 
когда в репозитории обнаруживается новое push-событие. 
Он состоит из следующих основных компонентов:

### Job: Build Push Docker Image

Это задание управляет всем процессом CI/CD 
и состоит из нескольких ключевых этапов:

1. **Code Checkout**: Извлекается код репозитория, гарантирующий, что для последующих действий используется последняя версия.

2. **Trivy Installation**: Trivy, Trivy, надежный сканер уязвимостей для образов контейнеров, установлен в среде выполнения рабочего процесса.

3. **Docker Image Build and Push**: Образ Docker создается и впоследствии отправляется с помощью Docker Compose. Этот процесс включает в себя использование учетных данных Docker Hub, надежно хранящихся в виде секретов GitHub.

4. **Image Vulnerability Scanning**: Созданный образ Docker подвергается сканированию на уязвимости с помощью Trivy. Этот шаг помогает обеспечить сохранность изображения.

5. **Notification on Success**: Если процесс создания и отправки образа Docker завершается успешно, уведомление об успешном завершении отправляется на указанный канал Telegram. Уведомление содержит подробную информацию об успешном завершении CI/CD, новом push-событии и связанном с ним сообщении о фиксации.

6. **Notification on Failure**: В случае сбоя во время сборки образа Docker или push-процесса уведомление о сбое отправляется на тот же Telegram-канал. Уведомление сообщает о статусе сбоя процесса CI/CD вместе с соответствующей информацией о новом push-событии и соответствующем сообщении о фиксации.

## Как это работает

1. Всякий раз, когда в репозитории происходит новое push-событие, автоматически запускается рабочий процесс GitHub Actions.

2. Задание рабочего процесса координирует задачи создания, отправки и сканирования изображений Docker с помощью Docker Compose и Trivy.

3. В зависимости от результатов процесса CI/CD на указанный Telegram-канал отправляется соответствующее уведомление (об успехе или неудаче).

Внедрив этот рабочий процесс, я могу оптимизировать свой конвейер CI / CD,
повысить безопасность образа Docker за счет тщательного сканирования уязвимостей и 
быть в курсе хода моих развертываний с помощью уведомлений Telegram.


2. я создал Dockerfile для github actions

```bash
FROM appleboy/drone-telegram:1.3.9-linux-amd64

COPY --from=php_stage /var/www/html /var/www/html
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /github/workspace

ENTRYPOINT ["/entrypoint.sh"]
```

Этот Dockerfile разработан для использования в GitHub Actions и выполняет следующие действия:

1. **Основной образ**: `appleboy/drone-telegram:1.3.9-linux-amd64`.
2. **Копирование файлов**: Копирует содержимое каталога `/var/www/html` из образа `php_stage` в каталог `/var/www/html` внутри текущего образа.
3. **Копирование `entrypoint.sh`**: Перемещает файл `entrypoint.sh` в корневой каталог образа.
4. **Назначение прав**: Устанавливает исполняемые права на файл `entrypoint.sh`.
5. **Рабочая директория**: Устанавливает рабочую директорию как `/github/workspace`.
6. **Точка входа**: Задает точку входа для образа как `/entrypoint.sh`.

В результате данный Dockerfile настраивает образ для использования в GitHub Actions, осуществляя копирование файлов, настройку прав и определение точки входа для выполнения скрипта `entrypoint.sh`.



3. я создал entrypoint.sh file

```bash
#!/bin/sh
set -eu

export GITHUB="true"

[ -n "$*" ] && export TELEGRAM_MESSAGE="$*"

/bin/drone-telegram

```
Этот скрипт используется как точка входа в Docker-контейнере и предназначен для выполнения определенных действий:

1. **Установка переменных окружения**: Устанавливает переменную окружения `GITHUB` в значение `true`, указывая на выполнение в контексте GitHub.

2. **Условное задание сообщения для Telegram**: Если переданы аргументы командной строки, то значение переданных аргументов устанавливается в переменную окружения `TELEGRAM_MESSAGE`.

3. **Запуск `/bin/drone-telegram`**: Запускает исполняемый файл `/bin/drone-telegram`, выполняя последующие действия.

В итоге этот скрипт настраивает окружение, обрабатывает сообщение для Telegram (если указано), и запускает действия с использованием `/bin/drone-telegram`.

![](public/Images/action-1.jpg)
![](public/Images/action-2.jpg)
![](public/Images/action-3.jpg)
![](public/Images/action-4.jpg)
![](public/Images/action-5.jpg)
![](public/Images/action-6.jpg)
![](public/Images/action-7.jpg)

# Объяснение
<h3>. Prometheus </h3> 
Prometheus является системой мониторинга с открытым исходным кодом, предназначенной для сбора и анализа метрик из различных систем и приложений. Он позволяет получить информацию о производительности и состоянии системы.Прометей следует модели пассивного мониторинга, периодически запрашивая данные метрик из настроенных источников, таких как серверы, контейнеры или сервисы. Эти источники предоставляют метрики в специальном формате (обычно в формате Prometheus экспозиции), который Прометей может интерпретировать.Собранные метрики хранятся Прометеем в базе данных временных рядов и позволяют выполнять запросы и анализ через мощный язык запросов PromQL (Prometheus Query Language). Этот язык позволяет пользователям создавать сложные запросы и выражения для фильтрации, агрегации и манипуляции собранными метриками.

<h3>. Node Exporter </h3> 
 Node Exporter - это инструмент, который позволяет Прометею собирать информацию о системе и ресурсах хоста, таких как процессор, память, дисковое пространство и сетевые интерфейсы. Он предоставляет метрики, связанные с работой самого узла, которые затем можно использовать для мониторинга и анализа.

<h3>. Blackbox Exporter </h3> 
Blackbox Exporter - это компонент Прометея, который позволяет выполнять активное мониторинговые проверки различных сетевых служб и протоколов, таких как HTTP, DNS, TCP и других. Он позволяет проверять доступность сервисов, проверять работу определенных эндпоинтов и возвращать соответствующие метрики, которые затем могут быть использованы для оповещения и анализа состояния сети.

<h3>. Mysql Exporter </h3> 
MySQL Exporter - это экспортер Прометея, который позволяет собирать метрики и статистику производительности из базы данных MySQL. Он предоставляет информацию о запросах, подключениях, потоках, кэше и других аспектах работы MySQL. Эти метрики могут быть использованы для отслеживания производительности базы данных и выявления проблем.

<h3>. Grafana </h3> 
это инструмент визуализации данных и построения графиков, который часто используется в сочетании с Прометеем. Он позволяет создавать красочные и информативные дашборды, настраивать графики и панели инструментов на основе собранных метрик Прометея. Grafana предлагает широкий спектр визуальных возможностей, которые помогают пользователю легко интерпретировать и анализировать данные мониторинга.




# Шаги по настройке мониторинга

<h3>Шаг 1</h3> 
Создайте файл docker-compose.yml с контейнеры (twit, ngix, mysql, promethesu, mysql-exporter , node-exporter, blackbox-exporter)


```bash
version: '3.8'

networks:
    default:
        external: true
        name: twit_default

services:
    twit:
        build:
            context: .
            dockerfile: Dockerfile
        container_name: twit
        volumes:
            - .:/var/www/html
        depends_on:
            - mysql
            - prometheus
            - mailhog

    nginx:
        image: nginx:latest
        container_name: nginx
        ports:
            - '8000:8000'
        volumes:
            - .:/var/www/html
            - ./prometheus/nginx.conf:/etc/nginx/conf.d/default.conf
        depends_on:
            - twit

    mysql:
        image: mysql:8.0
        ports:
            - '3306:3306'
        environment:
            MYSQL_ROOT_PASSWORD: '${DB_PASSWORD}'
            MYSQL_ROOT_HOST: "%"
            MYSQL_DATABASE: '${DB_DATABASE}'
            MYSQL_PASSWORD: '${DB_PASSWORD}'
        volumes:
            - twit_mysql_data:/var/lib/mysql

    prometheus:
        image: prom/prometheus
        container_name: prometheus
        ports:
            - "9090:9090"
        volumes:
            - ./prometheus:/etc/prometheus
            - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
            - ./prometheus/alert_rules.yml:/etc/prometheus/alert_rules.yml
            - ./prometheus/blackbox.yml:/etc/prometheus/blackbox.yml
        command:
            - --config.file=/etc/prometheus/prometheus.yml
        depends_on:
            - node-exporter
            - blackbox-exporter
            - mysql-exporter

    alertmanager:
        image: prom/alertmanager
        container_name: alertmanager
        ports:
            - "9093:9093"
        volumes:
            - ./prometheus/alertmanager.yml:/etc/alertmanager/alertmanager.yml

    node-exporter:
        image: prom/node-exporter
        container_name: node-exporter
        ports:
            - "9100:9100"

    blackbox-exporter:
        image: bitnami/blackbox-exporter
        volumes:
            - ./prometheus/blackbox.yml:/etc/blackbox_exporter/config.yml
        container_name: blackbox-exporter
        ports:
            - "9115:9115"

    mysql-exporter:
        image: prom/mysqld-exporter
        container_name: mysql-exporter
        ports:
            - "9104:9104"
        environment:
            DATA_SOURCE_NAME: "root:mysecretpassword@(mysql:3306)/Twit"
        command:
            - "--config.my-cnf=/etc/my.cnf"
        volumes:
            - ./my.cnf:/etc/my.cnf



    grafana:
        image: grafana/grafana
        container_name: grafana
        ports:
            - "3000:3000"
        depends_on:
            - prometheus

    mailhog:
        image: mailhog/mailhog
        container_name: mailhog
        ports:
            - "1025:1025"
            - "8025:8025"

volumes:
    twit_mysql_data:

```

<h3>Шаг 2</h3> 
созданный файл Dockerfile

```bash
FROM php:8.2.0-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    libpq-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    curl \
    && docker-php-ext-install zip pdo_mysql pdo_pgsql

# Install GD extension
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

# Copy application files
COPY . .

# Set max_execution_time
RUN echo "php_value[max_execution_time] = 120" >> /usr/local/etc/php/conf.d/docker-php-max-execution-time.ini

# Install PHP dependencies
RUN composer install

# Install Node.js dependencies and build assets
RUN npm install


```

<h3>Шаг 3</h3>
создай Prometheus.yml для настройки prometheus с экспортерами

```bash
global:
  scrape_interval: 15s
  scrape_timeout: 10s

rule_files:
  - "/etc/prometheus/alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - alertmanager:9093

scrape_configs:
  - job_name: 'nginx'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['nginx:8000']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'blackbox-exporter'
    params:
      module: ['laravel_app_check', 'laravel_app_requests_check']
    static_configs:
      - targets: ['blackbox-exporter:9115']

  - job_name: 'mysql-exporter'
    static_configs:
      - targets: [ 'mysql-exporter:9104' ]


```
<h3>Шаг 4</h3>
создание файла Nginx конфигурации

```bash
server {
    listen 8000;
    index index.php index.html;
    root /var/www/html/public;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass twit:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}


```

<h3>Шаг 5</h3>
создание  Alertmanager.yml и alert_rules.yml конфигурации

```bash
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 3h
  receiver: 'telegram-webhook'
  routes:
    - match:
        severity: critical
      receiver: telegram-webhook

receivers:
  - name: 'telegram-webhook'
    webhook_configs:
      - url: 'telegram_bot_url?chat_id=telegram_bot_chat_id=High+CPU+usage+detected+in+the+app!+Current+value:+{{ $value }}'


```

```bash
groups:
  - name: example
    rules:
      - alert: HighCpuUsage
        expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% for more than 2 minutes."


```
<h3>Шаг 6</h3>
создайте route /metrics в приложении для Prometheus Endpoint 

```bash
Route::middleware([CountRequestsMiddleware::class])->group(function () {
    Route::get('/metrics',[MetricsController::class, 'getMetrics']);
});

```
<h3>Шаг 7</h3>
Создайте Middleware  для считать запроса (Request metrics )


```bash
class CountRequestsMiddleware
{
    private CollectorRegistry $registry;

    public function __construct(CollectorRegistry $registry)
    {
        $this->registry = $registry;
    }

    /**
     * @throws MetricsRegistrationException
     */
    public function handle(Request $request, Closure $next)
    {
        $startTime = microtime(true);

        $response = $next($request);

        $duration = microtime(true) - $startTime;
        $path = $request->getPathInfo();
        $method = $request->getMethod();
        $statusCode = $response->getStatusCode();
        $content = $response->getContent();

        $requestCounter = $this->registry->getOrRegisterCounter(
            'app',
            'request_count',
            'Total number of requests',
            ['path', 'method', 'status_code']
        );
        $requestCounter->incBy(1, [$path, $method, (string) $statusCode]);

        $requestDuration = $this->registry->getOrRegisterHistogram(
            'app',
            'request_duration_seconds',
            'Request duration in seconds',
            ['path', 'method', 'status_code'],
            [0.01, 0.1, 1, 5] // Adjust the buckets as per your needs
        );
        $requestDuration->observe($duration, [$path, $method, (string) $statusCode]);

        $requestSize = $this->registry->getOrRegisterHistogram(
            'app',
            'request_size_bytes',
            'Request size in bytes',
            ['path', 'method']
        );
        $requestSize->observe(strlen($content), [$path, $method]);

        return $response;
    }
}

```
<h3>Шаг 8</h3>
Создайте контроллер для всех metrics

```bash
class MetricsController extends Controller
{


    public function getMetrics(Request $request)
    {

        DB::connection()->enableQueryLog();
        $collectorRegistry = app(CollectorRegistry::class);

        //memory usage metric
        $memoryUsage = memory_get_usage(true);
        $gauge = $collectorRegistry->getOrRegisterGauge('app', 'memory_usage_bytes', 'Memory usage in bytes');
        $gauge->set($memoryUsage);

        // Count the number of registered users
        $usersRegistered = User::count();
        $gauge = $collectorRegistry->getOrRegisterGauge(
            'app',
            'users_registered_total',
            'Total number of registered users'
        );
        $gauge->set($usersRegistered);

        // Count the number of Twits
        $twitsCount = Twit::count();
        $twitsCounter = $collectorRegistry->getOrRegisterGauge(
            'app',
            'twits_total',
            'Total number of Twits'
        );
        $twitsCounter->set($twitsCount);


        // Count the number of comments posted on Twits
        $commentsCount = Comment::count();
        $commentsCounter = $collectorRegistry->getOrRegisterGauge(
            'app',
            'comments_total',
            'Total number of comments posted on Twits'
        );
        $commentsCounter->set($commentsCount);

        // Count the number of likes
        $likesCount = Like::count();
        $likesCounter = $collectorRegistry->getOrRegisterGauge(
            'app',
            'likes_total',
            'Total number of likes'
        );
        $likesCounter->set($likesCount);


        // Count the number of Twit deletions
        $twitDeletionsCount = Twit::onlyTrashed()->count();
        $twitDeletionsCounter = $collectorRegistry->getOrRegisterGauge(
            'app',
            'twit_deletions_total',
            'Total number of Twit deletions'
        );
        $twitDeletionsCounter->set($twitDeletionsCount);

        // Count the number of Twit updates
        $twitUpdatesCount = Twit::whereNotNull('updated_at')->count();
        $twitUpdatesCounter = $collectorRegistry->getOrRegisterGauge(
            'app',
            'twit_updates_total',
            'Total number of Twit updates'
        );
        $twitUpdatesCounter->set($twitUpdatesCount);

        // Count the number of comment deletions
        $commentDeletionsCount = Comment::onlyTrashed()->count();
        $commentDeletionsCounter = $collectorRegistry->getOrRegisterGauge(
            'app',
            'comment_deletions_total',
            'Total number of comment deletions'
        );
        $commentDeletionsCounter->set($commentDeletionsCount);


        // Count the number of comment replies
        $commentRepliesCount = Comment::whereNotNull('parent_id')->count();
        $commentRepliesCounter = $collectorRegistry->getOrRegisterGauge(
            'app',
            'comment_replies_total',
            'Total number of comment replies'
        );
        $commentRepliesCounter->set($commentRepliesCount);



        // Track cache hits and misses
        $cacheHits = Cache::get('cache_hits', 0);
        $cacheMisses = Cache::get('cache_misses', 0);
        $cacheHitsCounter = $collectorRegistry->getOrRegisterCounter(
            'app',
            'cache_hits_total',
            'Total number of cache hits'
        );
        $cacheHitsCounter->incBy($cacheHits);
        $cacheMissesCounter = $collectorRegistry->getOrRegisterCounter(
            'app',
            'cache_misses_total',
            'Total number of cache misses'
        );
        $cacheMissesCounter->incBy($cacheMisses);




//        $exceptionRate = $this->getExceptionRate();
//        $exceptionRateGauge = $collectorRegistry->getOrRegisterGauge(
//            'app',
//            'exception_rate',
//            'Exception rate per minute'
//        );
//        $exceptionRateGauge->set($exceptionRate);



        $renderer = new RenderTextFormat();
        $result = $renderer->render($collectorRegistry->getMetricFamilySamples());

        return response($result, 200)->header('Content-Type', RenderTextFormat::MIME_TYPE);

    }

}

```



# Полученные результаты


###  Docker
![](public/Images/docker1.jpg)
![](public/Images/docker2.jpg)
![](public/Images/docker3.jpg)


###  metrics в приложении localhost:8000/metrics
![](public/Images/twit9.jpg)

### metrics в prometheus localhost:9090
![](public/Images/prometh1.jpg)
![](public/Images/prometh2.jpg)
![](public/Images/prometh3.jpg)
![](public/Images/prometh4.jpg)
![](public/Images/prometh5.jpg)
![](public/Images/prometh6.jpg)
![](public/Images/prometh7.jpg)
![](public/Images/prometh8.jpg)
![](public/Images/prometh9.jpg)
![](public/Images/prometh10.jpg)
![](public/Images/prometh11.jpg)
![](public/Images/prometh12.jpg)
![](public/Images/prometh13.jpg)
![](public/Images/prometh14.jpg)
![](public/Images/prometh15.jpg)
![](public/Images/prometh16.jpg)

### alertmanager
![](public/Images/alert.jpg)

### 4. metrics в Node Exporter
![](public/Images/node1.jpg)
![](public/Images/node2.jpg)

### 4. metrics в Blackbox Exporter
![](public/Images/blackbox1.jpg)
![](public/Images/blackbox2.jpg)
![](public/Images/blackbox3.jpg)

### 4. metrics в Mysql Exporter
![](public/Images/mysq-exporter1.jpg)
![](public/Images/mysq-exporter2.jpg)
![](public/Images/mysq-exporter3.jpg)

### 4. Grafana
![](public/Images/grafana1.jpg)
![](public/Images/grafana2.jpg)
![](public/Images/grafana3.jpg)
![](public/Images/grafana4.jpg)
![](public/Images/grafana5.jpg)
![](public/Images/grafana6.jpg)
![](public/Images/grafana7.jpg)
![](public/Images/grafana8.jpg)
![](public/Images/grafan9.jpg)
![](public/Images/grafana10.jpg)

