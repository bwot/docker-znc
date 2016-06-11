# Minimal ZNC Docker image
[Dockerfile](https://github.com/bwot/docker-znc)

Image size: <12 MB.


### How to run
As with any Docker image, you can run it in a number of ways, some of these are shown below.

Note that you have to bind port 6667 on the container to a port on your host (3030 in the examples) to be able to connect your IRC client to ZNC and to be able to access the web interface.

Default **webadmin** username / password is admin / admin. Don't forget to change this before you expose the container to the world.


#### Examples:
All examples will assume that your container is named 'znc'.


##### Run the container straight up, this will create an unnamed data volume:
```bash
docker run -d --restart=unless-stopped --name znc -p 3030:6667 towb/znc
```

##### Create a named data volume and mount it to the container:
```bash
docker volume create --name zncdata
docker run -d --restart=unless-stopped --name znc -p 3030:6667 -v zncdata:/znc-data towb/znc
```

##### Mount a directory from your host to the container:
```bash
docker run -d --restart=unless-stopped --name znc -p 3030:6667 -v ~/.znc:/znc-data towb/znc
```



### How to install modules
ZNC comes with a bunch of useful modules by default. There are a few ways you can add more modules if you need extra functionality.


This is what the [ZNC wiki](http://wiki.znc.in/Modules) says about modules:
> ZNC modules are written in C++ natively. There are also a couple of modules that embed an interpreter to allow you to load Perl, Python, or Tcl modules.


[List of available ZNC modules you may want to install](http://wiki.znc.in/Category:Modules)


##### Modules from `znc-extra`
Alpine Linux has a package called `znc-extra` that currently (2016-06-11) contains these mods
> imapauth send_raw log shell notify_connect ctcoflood block_motd autovoice listsockets flooddetach clearbufferonmsg


All you have to do to install these mods is to execute the following on your main ZNC container:
```bash
docker exec znc sh -c "apk add --update znc-extra"
```


##### Install C++ modules:
To install and compile a C++ module a bunch of dependencies are needed. To avoid making the main ZNC container grow a lot in size we can compile the modules from a temporary container, like this:
```bash
# spin up a temporary container and mount it to your ZNC data volume
docker run --rm -it --volumes-from znc towb/znc sh
# install necessary dependencies
apk add --update znc-dev g++ openssl-dev wget
mkdir -p $ZNCMOD && cd &ZNCMOD
# now find a module you want to install and use wget to download it
wget https://raw.githubusercontent.com/FruitieX/znc-backlog/master/backlog.cpp
# ... and compile it
znc-buildmod backlog.cpp
# done! remove the source file if you care...
rm backlog.cpp
exit
```
The temporary container with many megabytes of dependencies are automatically removed, while the compiled module still exists on your main data volume. Use `/znc loadmod` or the webadmin to load your newly installed module.


##### Perl, Python and TCL modules
If you want to use any of these kinds of modules you have to install modperl, modpython or modtcl to your main znc container.
```bash
docker exec znc sh -c "apk add --update znc-modperl znc-modpython znc-modtcl"
```
Download the source code for your Perl, Python or TCL modules to your $ZNCMOD (/znc-data/modules) folder and use `/znc loadmod` or the webadmin to load the mod.



### Backup
To create a backup run this:
```bash
docker run --rm --volumes-from znc -v $(pwd):/backup towb/znc tar zcvf /backup/backup.tar.gz /znc-data
```
To restore from a previous backup run this:
```bash
docker run --rm --volumes-from znc -v $(pwd):/backup towb/znc sh -c "apk add --update tar && tar zxvf /backup/backup.tar.gz -C /znc-data --strip-components=1"
```
