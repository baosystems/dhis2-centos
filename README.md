# About

Install PostgreSQL, Tomcat, Nginx, and DHIS 2.30 on CentOS 7.

# _WARNING_

**Do not use this configuration in any production workloads!** Configurations are intended for local development environments _only!_

# Using

Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](https://www.vagrantup.com/downloads.html) for your platform. Then, in a terminal, navigate to this directory and run `vagrant up`. After provisioning is complete, DHIS2 will be accessible at [http://localhost:8080](http://localhost:8080).

## tl;dr

```bash
git clone https://github.com/baosystems/dhis2-centos.git
cd dhis2-centos
vagrant up
```

Wait a while... then, you can browse http://127.0.0.1:8080

## Maintenance

It is required to SSH into the Virtual Machine by running:

```bash
vagrant ssh
sudo -i
```

### Clear out DHIS2 database

```bash
service tomcat stop
psql -U dhis -d dhis2 -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
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
service tomcat stop
cd /var/lib/tomcat/webapps
rm -f ROOT.war
rm -rf ROOT/
wget -O ROOT.war "https://s3-eu-west-1.amazonaws.com/releases.dhis2.org/2.29/dhis.war"
service tomcat start
```

alternatively, edit `main.yml` to e.g. `dhis2_version: 2.29`
and run `vagrant --provision` to re-setup.

## Troubleshooting

```
ansible local provisioner:
* The following settings shouldn't exist: become
```

If you get an error about settings, make sure you have the latest versions of both Vagrant (2.0 or higher) and VirtualBox (5.2 or higher) installed.

# Change DHIS2 Version

If you do not wish to use the version of DHIS2 installed, open `Vagrantfile`, edit the line containing `ansible.extra_vars`, specify the version you want, save the file, and then proceed with provisioning.
