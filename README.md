## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation 

Clone/git pull the repo into any local directory

```
$ git clone https://github.com/oliverwilms/iriscontest2020
```

Open the terminal in this directory and run:

```
cd iriscontest2020/
$ docker-compose build
```

Run the IRIS container with your project:

```
$ docker-compose up -d
```

## How to Test it

Open IRIS terminal:

```
$ docker-compose exec iris iris session iris
USER>zn "IRISAPP"
IRISAPP>set ^UnitTestRoot=""
IRISAPP>do ##class(DMLSS.TestProduction).Run()
```
