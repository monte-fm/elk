#!/bin/bash
service logstash configtest
service logstash start
service elasticsearch start
service kibana start
service nginx start

#Load Kibana Dashboards
cd ~/beats-dashboards-* && ./load.sh

pip install --upgrade pip
pip install -r /opt/elastalert/requirements-dev.txt
pip install -r /opt/elastalert/requirements.txt

echo "
#!/bin/bash
service nginx start
#service ssh start
service postfix start
service logstash start
service elasticsearch start
service kibana start
" > /root/autostart.sh