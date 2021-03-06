#!/bin/bash -v
set -x

HOSTNAME=`curl -s http://169.254.169.254/computeMetadata/v1beta1/instance/hostname`

SUMO_CONF_FILE="/etc/sumo.conf"
SUMO_CONF_TEMPLATE="/etc/sumo.conf.company"

if [ -f ${SUMO_CONF_TEMPLATE} ] ; then
	sed -i 's/ //g' ${SUMO_CONF_TEMPLATE}
	mv ${SUMO_CONF_TEMPLATE} ${SUMO_CONF_FILE}
fi

sed -i "s|@@INSTANCE_ID@@|${HOSTNAME}|g" /opt/SumoCollector/config/sumologic_sources.json

/etc/init.d/collector start

. env/bin/activate
python --version
cd app
export app_folder=$1
echo app_folder = $app_folder
gunicorn --access-logfile /opt/company/cto/$app_folder/log/${app_folder}_access.log --error-logfile /opt/company/cto/$app_folder/log/${app_folder}_error.log --log-file /opt/company/cto/$app_folder/log/${app_folder}.log -b :$PORT wsgi
