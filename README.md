# msys-docker

A Dockerfile that installs the latest version of msys running with mysql, php-fpm and nginx.

## Installation

```bash
$ git clone https://github.com/bthstudent/msys-docker
$ cd msys-docker
$ sudo docker build -t="bthstudent/msys-docker" .
```

## Usage

```bash
$ sudo docker run -p 80:80 --name msys-docker -d bthstudent/msys-docker
```