#!/bin/bash
service logstash configtest
service php5-fpm start
service nginx start
service ssh start
service supervisor start

#Load Filebeat Index Template in Elasticsearch
cd ~
curl -O https://gist.githubusercontent.com/thisismitch/3429023e8438cc25b86c/raw/d8c479e2a1adcea8b1fe86570e42abab0f10f364/filebeat-index-template.json
curl -XPUT 'http://localhost:9200/_template/filebeat?pretty' -d@filebeat-index-template.json

#Load Kibana Dashboards
cd ~
curl -L -O https://download.elastic.co/beats/dashboards/beats-dashboards-1.1.0.zip
unzip beats-dashboards-*.zip
cd beats-dashboards-* && ./load.sh

pip install --upgrade pip
pip install -r /opt/elastalert/requirements-dev.txt
pip install -r /opt/elastalert/requirements.txt

echo "
#!/bin/bash
service supervisor start
service php5-fpm start
service nginx start
service ssh start
service postfix start
" > /root/autostart.sh
