#!/bin/bash

# 显示帮助信息
show_help() {
    echo "使用方法: $0 [命令] [参数]"
    echo "命令:"
    echo "  start              启动所有容器（包含构建）"
    echo "  down               停止并移除所有容器"
    echo "  restart            重启所有容器"
    echo "  add-location       添加新的 location 配置块"
    echo "                     用法: $0 add-location <path_prefix> <project_dir>"
    echo "                     例如: $0 add-location /app1 web1"
    echo "  -h                 显示帮助信息"
}

# 清理日志文件
clean_logs() {
    echo "清理日志文件..."
    rm -f ./logs/nginx/*.log
    rm -f ./logs/php/*.log
}

add_location() {
    local path_prefix=$1
    local project_dir=$2
    local config_file="./docker/nginx/conf.d/default.conf"
    
    # 检查参数
    if [ -z "$path_prefix" ] || [ -z "$project_dir" ]; then
        echo "错误: 缺少必要参数"
        echo "用法: $0 add-location <path_prefix> <project_dir>"
        echo "例如: $0 add-location /app1 web1"
        exit 1
    fi

    # 生成配置块
    local location_block="location ${path_prefix} {\n        alias /var/www/html/${project_dir}/;\n        index index.php index.html index.htm;\n        \n        try_files \$uri \$uri/ ${path_prefix}/index.php?\$query_string;\n\n        location ~ \.php$ {\n            fastcgi_pass php:9000;\n            fastcgi_index index.php;\n            fastcgi_param SCRIPT_FILENAME \$request_filename;\n            include fastcgi_params;\n        }\n    }\n\n    # {ADD_LOCATION_HERE}"

    # 检查文件是否存在
    if [ ! -f "$config_file" ]; then
        echo "错误: 配置文件不存在: $config_file"
        exit 1
    fi

   
    # 使用 sed 命令替换 {ADD_LOCATION_THERE} 注释
   sed -i '' "s|# {ADD_LOCATION_HERE}|${location_block}|g" "$config_file"

    if [ $? -eq 0 ]; then
        echo "成功添加 location 配置块: ${path_prefix} -> ${project_dir}"
        echo "请检查配置文件: $config_file"
        echo "如需使配置生效，请重启 Nginx 容器: $0 restart"
    else
        echo "错误: 替换配置块失败"
        exit 1
    fi
}



# 主程序
case "$1" in
    start)
        clean_logs
        echo "启动容器..."
        docker-compose up -d --build
        ;;
    down)
        echo "停止并移除容器..."
        docker-compose down
        ;;
    restart)
        clean_logs
        echo "重启容器..."
        docker-compose restart
        ;;
    add-location)
        add_location "$2" "$3"
        ;;
    -h|--help|"")
        show_help
        ;;
    *)
        echo "错误: 未知的命令 '$1'"
        show_help
        exit 1
        ;;
esac