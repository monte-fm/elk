# Create container
```
docker run -i -t -d --name=elk -h=elk -p 5001:80 -p 5044:5044 cristo/elk /bin/bash
```

# SSH
```
ssh -p5002 root@localhost
password: root
```

# NGINX server config file for communicate with docker
```
server {
        listen *:80;
        server_name localhost;
        proxy_set_header Host localhost;
        client_max_body_size 100M;

                location / {
                                proxy_set_header Host $host;
                                proxy_set_header X-Real-IP $remote_addr;
                                proxy_cache off;
                                proxy_pass http://localhost:5001;
                        }
}
```

# Nginx kibana user creation
Use htpasswd to create an 'admin' user with password 'admin', (you should use another name), that can access the Kibana web interface:
```
sudo htpasswd -c -b /etc/nginx/htpasswd.users admin admin
```
Remember this login, as you will need it to access the Kibana web interface.

# etcKeeper 
Added etcKeeper - autocommit on exit to /etc git local repository

# You need to configure filebeat
[Filebeat] (https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elk-stack-on-ubuntu-14-04)


# Origin
[Docker Hub] (https://registry.hub.docker.com/u/cristo/symfony2/)

[Git Hub] (https://github.com/monte-fm/symfony2)
