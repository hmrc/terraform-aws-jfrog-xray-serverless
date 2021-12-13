locals {
  rabbitmq_uid = "999"
  xray_uid     = "1035"

  bootstrap_script = <<EOT
apk add curl
apk add yq

xray_system_yaml_path="/mnt/xray-persistent-volume/etc/system.yaml"
mkdir -p $(dirname $${xray_system_yaml_path})
yq eval -i '.shared.jfrogUrl = "${var.artifactory_url}"' $${xray_system_yaml_path}
yq eval -i '.shared.security.joinKey = "${var.artifactory_join_key}"' $${xray_system_yaml_path}
yq eval -i '.shared.database.type = "postgresql"' $${xray_system_yaml_path}
yq eval -i '.shared.database.driver = "rg.postgresql.Driver"' $${xray_system_yaml_path}
yq eval -i '.shared.database.url = "postgres://${aws_db_instance.main.endpoint}/jfrogxray?sslmode=disable"' $${xray_system_yaml_path}
yq eval -i '.shared.database.username = "jfrogxray"' $${xray_system_yaml_path}
yq eval -i '.shared.database.password = "password"' $${xray_system_yaml_path}
touch /mnt/xray-persistent-volume/test-permissions

curl -LO https://releases.jfrog.io/artifactory/jfrog-xray/xray-compose/${var.xray_version}/jfrog-xray-${var.xray_version}-compose.tar.gz
tar -zxvf jfrog-xray-${var.xray_version}-compose.tar.gz
mkdir -p /mnt/rabbitmq-persistent-volume/conf.d
cp -a jfrog-xray-${var.xray_version}-compose/third-party/rabbitmq/* /mnt/rabbitmq-persistent-volume
echo "[rabbitmq_management,rabbitmq_prometheus]." > /mnt/rabbitmq-persistent-volume/enabled_plugins

chown -R ${local.xray_uid}:${local.xray_uid} /mnt/xray-persistent-volume
chown -R ${local.rabbitmq_uid}:${local.rabbitmq_uid} /mnt/rabbitmq-persistent-volume
EOT
}

# TODO: Variablise/hide RDS connection details
