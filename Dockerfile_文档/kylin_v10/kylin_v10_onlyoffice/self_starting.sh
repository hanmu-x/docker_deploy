#!/bin/bash

# 启动 PostgreSQL
service postgresql start

# 启动 RabbitMQ Server
service rabbitmq-server start

# 启动 Supervisor
service supervisor start

# 启动 Nginx
service nginx start
