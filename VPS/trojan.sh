#!/bin/bash

IMAGE_MYSQL="mariadb:10.2"
IMAGE_TROJAN="jrohy/trojan"
DATA_PATH="/home/Mysql/Data"
DEFAULT_PASSWD="w#GqE76MXwEp!VEb"

sql_name="mariadb-10"
trojan_name="trojan"

# 依赖安装
if ! hash wget > /dev/null; then
    apt-get install wget -y || (echo "wget 安装失败" && exit 1)
fi


install_docker() {
    if hash docker > /dev/null; then
        return 
    fi

    local file_path="/tmp/install_docker.sh"
    local docker_url="https://get.docker.com"
    
    wget -q "$docker_url" -O "$file_path" > /dev/null
    [ -e "$file_path" ] && bash "$file_path" && return
    echo -e "安装docker 失败! 检查url地址是否失效!\n\t $docker_url" && exit 1
}

install_tcp() {
    local file_tcp="/tmp/install_tcp.sh"
    local tcp_url="https://github.000060000.xyz/tcp.sh"
    
    [ -e "$file_tcp" ] || wget -q "$tcp_url" -O "$file_tcp" > /dev/null
    [ -e "$file_tcp" ] && bash "$file_tcp" && return

    echo -e "安装tcp加速脚本失败！检查脚本下载地址是否失效！\n\t $tcp_url" && exit 1
}

run_mysql(){
    docker start "$sql_name" > /dev/null

    [ $? -eq 0 ] && echo "启动$sql_name 完成！" && return

    docker run --name "$sql_name" \
        --restart=always -p 3306:3306 \
        -v "${DATA_PATH}":/var/lib/mysql \
        -e MYSQL_ROOT_PASSWORD=${DEFAULT_PASSWD} \
        -e MYSQL_ROOT_HOST=% \
        -e MYSQL_DATABASE=trojan \
        -d ${IMAGE_MYSQL} ;

    [ $? -ne 0 ] && echo "启动${sql_name}数据库出错！" && exit 1;
}

run_trojan(){
    docker start "$trojan_name" > /dev/null

    [ $? -eq 0 ] && echo "启动$trojan_name 完成！" && return

    docker run -it -d --name $trojan_name \
        --net=host --restart=always \
        --privileged ${IMAGE_TROJAN} init ;

    [ $? -ne 0 ] && echo "启动${trojan_name}出错！" && exit 1;
}

link_trojan(){
    docker exec -it $trojan_name bash
}

main() {
    install_docker

    select optin in "run tcp" "run mysql" "run trojan" "trojan bash" "exit"
    do
        case "$optin" in
            "run tcp") install_tcp ;;
            "run mysql") run_mysql ;;
            "run trojan") run_trojan ;;
            "trojan bash") link_trojan ;;
            *) exit 0 ;;
        esac

    done
    
}

main
