variable "project" {
  default = "assignment-4-414719"
}
variable "region" {
  default = "us-central1"
}
variable "can_ip_forward" {
  default = false
}
variable "disk_auto_delete" {
  default = false
}
variable "disk_boot" {
  default = false
}
variable "disk_size_gb" {
  default = 100
}
variable "zone" {
  default = "us-central1-a"
}
variable "private_ip_google_access" {
  default = true
}
variable "global_address_name" {
  default = "global-psconnect-ip"
}
variable "address_type" {
  default = "INTERNAL"
}
variable "purpose" {
  default = "VPC_PEERING"
}
variable "prefix_length" {
  default = 24
}
variable "global_forwarding_rule_name" {
  default = "globalrule"
}
variable "global_forwarding_rule_target" {
  default = "all-apis"
}
variable "load_balancing_scheme" {
  default = ""
}

variable "service" {
  default = "servicenetworking.googleapis.com"
}
variable "vpc_name" {
  default = "main"
}
variable "auto_create_subnetworks" {
  default = false
}
variable "delete_default_routes_on_create" {
  default = true
}
variable "webapp_subnet_name" {
  default = "webapp-subnet"
}
variable "db_subnet_name" {
  default = "db-subnet"
}
variable "webapp_subnet_cidr" {
  default = "10.1.0.0/24"
}
variable "db_subnet_cidr" {
  default = "10.2.0.0/24"
}
variable "route_name" {
  default = "webapp-route"
}
variable "route_destination" {
  default = "0.0.0.0/0"
}
variable "gateway_name" {
  default = "default-internet-gateway"
}
variable "sshAllow_priority" {
  default = 900
}
variable "sshDeny_priority" {
  default = 1000
}
variable "routing_mode" {
  default = "REGIONAL"
}
variable "deny_firewall" {
  default = "deny-traffic"
}
variable "allow_firewall" {
  default = "allow-traffic"
}
variable "protocol" {
  default = "tcp"
}
variable "deny_protocol" {
  default = "all"
}
variable "allowedPort" {
  default = ["8080"]
}
variable "source_ranges" {
  default = ["130.211.0.0/22", "35.191.0.0/16"]
}
variable "service_account_id" {
  default = "myserviceaccount"
}
variable "service_account_display_name" {
  default = "myserviceaccount"
}
variable "service_account_description" {
  default = "Service Account for Ops Agent"
}
variable "iam_role_loggingAdmin" {
  default = "roles/logging.admin"
}
variable "iam_role_monitoringMetricWriter" {
  default = "roles/monitoring.metricWriter"
}
variable "new_Instance" {
  default = "new-instance"
}
variable "lb_name" {
  default = "allow-load-balancer-ingress"
}
variable "lb_protocol" {
  default = "tcp"
}
variable "lb_port" {
  default = ["8080", "443"]
}
variable "new_regional_Instance" {
  default = "new-regional-instance"
}
variable "machine_type" {
  default = "e2-medium"
}
variable "allow_stopping_for_update" {
  default = true
}
variable "auto_delete" {
  default = true
}
variable "image" {
  default = "projects/assignment-4-414719/global/images/packer-1712333747"
}
variable "size" {
  default = 100
}
variable "type" {
  default = "pd-balanced"
}
variable "DB_PORT" {
  default = 8080
}
variable "LOG_FILE_PATH" {
  default = "/var/log/webappLog/webapp.log"
}
variable "opsAgent_SA_scope" {
  default = ["cloud-platform"]
}
variable "healthcheckName" {
  default = "http-health-check"
}
variable "healthcheckDescription" {
  default = "Health check via http"
}
variable "timeout_sec" {
  default = 5
}
variable "check_interval_sec" {
  default = 5
}
variable "healthy_threshold" {
  default = 2
}
variable "unhealthy_threshold" {
  default = 10
}
variable "request_path" {
  default = "/healthz"
}
variable "healthcheckPort" {
  default = "8080"
}
variable "autoscalar_name" {
  default = "my-region-autoscaler"
}
variable "autoscalar_region" {
  default = "us-central1"
}
variable "max_replicas" {
  default = 3
}
variable "min_replicas" {
  default = 1
}
variable "cooldown_period" {
  default = 60
}
variable "mode" {
  default = "ON"
}
variable "cpu_utilization_target" {
  default = 0.05
}
variable "webAppIGM_name" {
  default = "webapp-instance-group-manager"
}
variable "base_instance_name" {
  default = "webapp-instance"
}
variable "target_size" {
  default = 1
}
variable "distribution_policy_zones" {
  default = ["us-central1-a"]
}
variable "named_port_name" {
  default = "http"
}
variable "named_port_port" {
  default = 8080
}
variable "initial_delay_sec" {
  default = 300
}
variable "cloudsql_instance_name" {
  default = "cloudsql-instance"
}
variable "database_version" {
  default = "MYSQL_8_0"
}
variable "deletion_protection" {
  default = false
}
variable "tier" {
  default = "db-f1-micro"
}
variable "disk_type" {
  default = "pd-ssd"
}
variable "disk_size" {
  default = 100
}
variable "psc_enabled" {
  default = true
}
variable "allowed_consumer_projects" {
  default = ["allowed-consumer-project-name"]
}
variable "enable_private_path_for_google_cloud_services" {
  default = true
}
variable "ipv4_enabled" {
  default = false
}
variable "enabled" {
  default = true
}
variable "binary_log_enabled" {
  default = true
}
variable "availability_type" {
  default = "REGIONAL"
}
variable "database_name" {
  default = "webapp"
}
variable "database_user" {
  default = "webapp"
}
variable "password_length" {
  default = 16
}
variable "password_special" {
  default = false
}
variable "override_special" {
  default = "_%@"
}
variable "dns_zone_name" {
  default = "vaishc"
}
variable "record_set_name" {
  default = "vaishc.me."
}
variable "record_set_type" {
  default = "A"
}
variable "record_set_ttl" {
  default = 300
}
variable "managed_zone" {
  default = "vaishc-me"
}
variable "generateTokenRole" {
  default = "roles/iam.serviceAccountTokenCreator"
}
variable "invokerRoleCloudFunction" {
  default = "roles/cloudfunctions.invoker"
}
variable "runInvokerRoleCloudFunction" {
  default = "roles/run.invoker"
}
variable "topicName" {
  default = "verify_email"
}
variable "retentionDuration" {
  default = "604800s"
}
variable "subscriptionName" {
  default = "eSub"
}
variable "topicRole" {
  default = "roles/pubsub.editor"
}
variable "subscriptionRole" {
  default = "roles/pubsub.editor"
}
variable "bucketNameForCloudFunction" {
  default = "bucket_new_a4"
}
variable "bucketObjectName" {
  default = "newBucketObj"
}
variable "cloudfunctionName" {
  default = "webappcloudfunction"
}
variable "apiKey" {
  default = "ee3fde8ac17500a9827972c88f1f0eeb-309b0ef4-7d6118b1"
}
variable "domain" {
  default = "email.vaishc.me"
}
variable "runtime" {
  default = "nodejs20"
}
variable "entry_point" {
  default = "helloPubSub"
}
variable "max_instance_count" {
  default = 1
}
variable "max_instance_request_concurrency" {
  default = 1
}
variable "available_memory" {
  default = "256Mi"
}
variable "timeout_seconds" {
  default = 540
}
variable "available_cpu" {
  default = "1"
}
variable "vpc_connector_egress_settings" {
  default = "PRIVATE_RANGES_ONLY"
}
variable "all_traffic_on_latest_revision" {
  default = true
}
variable "cloudFunctionEventType" {
  default = "google.cloud.pubsub.topic.v1.messagePublished"
}
variable "retry_policy" {
  default = "RETRY_POLICY_RETRY"
}
variable "vpcConnectorName" {
  default = "vpc-connector"
}
variable "vpc_cidr_range" {
  default = "10.8.0.0/28"
}