# About

Install PostgreSQL, Tomcat, Nginx, and DHIS 2.29 on CentOS 7.

# Using

Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](https://www.vagrantup.com/downloads.html) for your platform. Then, in a terminal, navigate to this directory and run `vagrant up`. After provisioning is complete, DHIS2 will be accessible at [http://localhost:8888](http://localhost:8888).

## tl;dr

```bash
git clone https://github.com/baosystems/dhis2-centos.git
cd dhis2-centos
vagrant up
```

Wait a while... then, you can browse http://127.0.0.1:8888/

If you want to load your own db/version of DHIS 2:

```bash
vagrant ssh
```
