# Solutudo Laravel Develop

Efetuar a instalação do docker conforme o manual em https://docs.docker.com/installation/ubuntulinux/#installing-docker-on-ubuntu.

Dê permissão para o seu usuário poder usar o Docker:

    sudo usermod -aG docker $USER

Clonar este repositório e na pasta do projeto executar:

    docker build -t solutudo/laravel-develop .

Em seguida configure 1 docker para cada projeto que deseja utilizar:

    docker run -p 8070:80 \
        -v $HOME/Projects/Solutudo/solutudo-site:/var/www/html \
        -v $HOME/Projects/Solutudo/tracker/tmp/logs:/var/log/nginx \
        --name solutudo-site \
        solutudo/laravel-develop &

Ao executar o comando acima, o shell vai ficar travado por conta do script RUN do Docker. Isso só ocorre no momento de criação do Docker. Depois de criado basta iniciá-lo pelo comando: 

    docker start tracker