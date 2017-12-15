# Solutudo Laravel Develop

Efetuar a instalação do docker conforme o manual em https://docs.docker.com/installation/ubuntulinux/#installing-docker-on-ubuntu.

Dê permissão para o seu usuário poder usar o Docker:

```bash
sudo usermod -aG docker $USER
```

Clonar este repositório e na pasta do projeto executar:

```bash
docker build -t adrianoluis/laravel .
```

Em seguida configure 1 docker para cada projeto que deseja utilizar:

```bash
docker run -p 8000:80 \
    --link mysql:mysql \
    -v $HOME/Projects/Laravel:/var/www/html \
    -v $HOME/Projects/Laravel/storage/logs:/var/log/nginx \
    --name laravel \
    -d adrianoluis/laravel
```

Ao executar o comando acima, o shell vai ficar travado por conta do script RUN do Docker. Isso só ocorre no momento de criação do Docker. Depois de criado basta iniciá-lo pelo comando: 

```bash
docker start laravel
```
