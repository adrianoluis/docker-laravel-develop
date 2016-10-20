# Solutudo Laravel Develop

Efetuar a instalação do docker conforme o manual em https://docs.docker.com/installation/ubuntulinux/#installing-docker-on-ubuntu.

Dê permissão para o seu usuário poder usar o Docker:

```bash
sudo usermod -aG docker $USER
```

Clonar este repositório e na pasta do projeto executar:

```bash
docker build -t adrianoluis/docker-laravel-develop .
```

Em seguida configure 1 docker para cada projeto que deseja utilizar:

```bash
docker run -p 8000:80 \
    --link mysql:mysql \
    --link redis:redis \
    -v /Users/adriano/Projects/Liuv/Laravel_Liuv:/var/www/html \
    -v /Users/adriano/Projects/Liuv/Laravel_Liuv/storage/logs:/var/log/nginx \
    --name apiliuv \
    adrianoluis/docker-laravel-develop &
```

Ao executar o comando acima, o shell vai ficar travado por conta do script RUN do Docker. Isso só ocorre no momento de criação do Docker. Depois de criado basta iniciá-lo pelo comando: 

```bash
docker start laravel
```
