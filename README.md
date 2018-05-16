# About

Install PostgreSQL, Tomcat, Nginx, and DHIS 2.29 on CentOS 7.

# Using

Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](https://www.vagrantup.com/downloads.html) for your platform. Then, in a terminal, navigate to this directory and run `vagrant up`. After provisioning is complete, DHIS2 will be accessible at [http://localhost:8888](http://localhost:8888).

## tl;dr

```bash
git clone https://github.com/baosystems/dhis2-centos.git
cd dhis2-centos
vagrant up
```

Wait a while... then, you can browse http://127.0.0.1:8888/


## Maintenance

It is required to SSH into the Virtual Machine by running:

```bash
vagrant ssh
```

### Clear out DHIS2 database

```bash
sudo -i
systemctl stop tomcat
dropdb -U dhis dhis2
createdb -U postgres -O dhis dhis2
logout
```

### Load your own DHIS2 database

Put your SQL file into the repository where you cloned it (on your host machine).
Clear out database as described above.
Shared files are in the `/vagrant` folder within the guest VM.

```bash
psql -U dhis -d dhis2 -f /vagrant/file.sql
```

### Check DHIS2 logs

```bash
tail -f /opt/dhis2/logs/dhis.log
```

### Load different DHIS2 version

```bash
sudo -i
systemctl stop tomcat
cd /var/lib/tomcat/webapps
rm -f ROOT.war
rm -rf ROOT/
wget -O ROOT.war https://url/to/DHIS2.war
systemctl start tomcat
```

## Troubleshooting

```
ansible local provisioner:
* The following settings shouldn't exist: become
```

If you get an error about settings, make sure you have the latest versions of both Vagrant (2.0 or higher) and VirtualBox (5.2 or higher) installed.
