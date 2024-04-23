# terraform {
#   required_providers {
#     google = {
#       source  = "hashicorp/google"
#       version = "4.51.0"
#     }
#   }
# }

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

//CReate VPC
resource "google_compute_network" "main" {
  name                            = var.vpc_name
  auto_create_subnetworks         = var.auto_create_subnetworks
  delete_default_routes_on_create = var.delete_default_routes_on_create
  routing_mode                    = var.routing_mode
}

// Enable the Service Networking API in your project
resource "google_project_service" "service_networking" {
  project = var.project
  service = var.service
}

//CReate two subnets
resource "google_compute_subnetwork" "webapp" {
  name          = var.webapp_subnet_name
  ip_cidr_range = var.webapp_subnet_cidr
  region        = var.region
  network       = google_compute_network.main.name
}

resource "google_compute_subnetwork" "db" {
  name                     = var.db_subnet_name
  ip_cidr_range            = var.db_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.main.name
  private_ip_google_access = var.private_ip_google_access
}

// Setup private services access in your VPC
resource "google_compute_global_address" "private_ip_address" {
  name          = var.global_address_name
  purpose       = var.purpose
  address_type  = var.address_type
  prefix_length = var.prefix_length
  network       = google_compute_network.main.id
}

// Create a private services connection for your network
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = var.service
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_compute_route" "webapp_route" {
  name             = var.route_name
  dest_range       = var.route_destination
  network          = google_compute_network.main.name
  next_hop_gateway = var.gateway_name
}

# Create Firewall
resource "google_compute_firewall" "deny_firewall" {
  name        = var.deny_firewall
  network     = google_compute_network.main.self_link
  priority    = var.sshDeny_priority
  target_tags = ["deny-firewall"]

  deny {
    protocol = var.deny_protocol
  }

  source_ranges = var.source_ranges
}
resource "google_compute_firewall" "allow_firewall" {
  name        = var.allow_firewall
  network     = google_compute_network.main.self_link
  priority    = var.sshAllow_priority
  target_tags = ["allow-firewall"]

  allow {
    protocol = var.protocol
    ports    = var.allowedPort
  }

  source_ranges = var.source_ranges
}

# Create a regional compute instance template
resource "google_compute_region_instance_template" "webapp_regional_instance_template" {
  provider = google-beta

  name_prefix    = var.new_regional_Instance
  machine_type   = var.machine_type
  region         = var.region
  can_ip_forward = var.can_ip_forward
  depends_on     = [google_kms_crypto_key.crypto_key_vm]
  tags           = ["allow-firewall", "deny-firewall"]

  disk {
    source_image = var.image
    auto_delete  = var.disk_auto_delete
    boot         = var.disk_boot
    disk_size_gb = var.disk_size_gb
    disk_encryption_key {
      kms_key_self_link = google_kms_crypto_key.crypto_key_vm.id
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  network_interface {
    network    = google_compute_network.main.self_link
    subnetwork = google_compute_subnetwork.webapp.self_link
  }
  service_account {
    email  = google_service_account.opsAgent_service_account.email
    scopes = var.opsAgent_SA_scope
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
     sudo echo "DB_USERNAME=${google_sql_user.webapp_user.name}" >> /opt/webappFork/.env
     sudo echo "DB_PASSWORD=${google_sql_user.webapp_user.password}" >> /opt/webappFork/.env
     sudo echo "DB_NAME=${google_sql_user.webapp_user.name}" >> /opt/webappFork/.env
     sudo echo "DB_PORT=${var.DB_PORT}" >> /opt/webappFork/.env
     sudo echo "HOST=${google_sql_database_instance.cloudsql_instance.private_ip_address}" >> /opt/webappFork/.env
     sudo echo "LOG_FILE_PATH=${var.LOG_FILE_PATH}" >> /opt/webappFork/.env
     EOF
}

# Create a compute health check

resource "google_compute_health_check" "http-health-check" {
  name        = var.healthcheckName
  description = var.healthcheckDescription

  timeout_sec         = var.timeout_sec
  check_interval_sec  = var.check_interval_sec
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold

  http_health_check {
    request_path = var.request_path
    port         = var.healthcheckPort
  }
}

resource "google_compute_region_autoscaler" "webapp_regional_autoscalar" {
  name       = var.autoscalar_name
  region     = var.autoscalar_region
  target     = google_compute_region_instance_group_manager.webAppIGM.id
  depends_on = [google_compute_region_instance_group_manager.webAppIGM]

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.cooldown_period
    mode            = var.mode

    cpu_utilization {
      target = var.cpu_utilization_target
    }
  }
}

resource "google_compute_region_instance_group_manager" "webAppIGM" {
  name               = var.webAppIGM_name
  region             = var.region
  base_instance_name = var.base_instance_name
  target_size        = var.target_size

  distribution_policy_zones = var.distribution_policy_zones

  version {
    instance_template = google_compute_region_instance_template.webapp_regional_instance_template.self_link
  }

  named_port {
    name = var.named_port_name
    port = var.named_port_port
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.http-health-check.id
    initial_delay_sec = var.initial_delay_sec
  }
}

// Create CloudSQL Instance
resource "google_sql_database_instance" "cloudsql_instance" {
  provider = google-beta

  name                = var.cloudsql_instance_name
  region              = var.region
  database_version    = var.database_version
  deletion_protection = var.deletion_protection
  encryption_key_name = google_kms_crypto_key.crypto_key_sql.id

  depends_on = [
    google_service_networking_connection.private_vpc_connection,
    google_kms_crypto_key.crypto_key_sql
  ]

  settings {
    tier              = var.tier
    disk_type         = var.disk_type
    disk_size         = var.disk_size
    availability_type = var.availability_type

    ip_configuration {
      ipv4_enabled                                  = var.ipv4_enabled
      private_network                               = google_compute_network.main.id
      enable_private_path_for_google_cloud_services = var.enable_private_path_for_google_cloud_services
    }

    backup_configuration {
      enabled            = var.enabled
      binary_log_enabled = var.binary_log_enabled
    }
  }
}

module "gce-lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 10.0"

  project = var.project
  name    = "group-http-lb"
  # target_tags = ["webapp"]

  ssl                             = true
  managed_ssl_certificate_domains = ["vaishc.me"]
  http_forward                    = false
  create_address                  = true
  network                         = google_compute_network.main.self_link
  backends = {
    default = {
      port_name   = "http"
      protocol    = "HTTP"
      timeout_sec = 10
      enable_cdn  = false

      health_check = {
        request_path = "/healthz"
        port         = 8080
        logging      = true
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group = google_compute_region_instance_group_manager.webAppIGM.instance_group
        },
      ]

      iap_config = {
        enable = false
      }
    }
  }
}

// Create a database in the CloudSQL instance
resource "google_sql_database" "webapp_database" {
  name     = var.database_name
  instance = google_sql_database_instance.cloudsql_instance.name
}

// Create a user in the CloudSQL database with a randomly generated password
resource "google_sql_user" "webapp_user" {
  name     = var.database_user
  instance = google_sql_database_instance.cloudsql_instance.name
  password = random_password.random_password_generated.result
}

// Random password generator
resource "random_password" "random_password_generated" {
  length           = var.password_length
  special          = var.password_special
  override_special = var.override_special
}

// Create Service Account
resource "google_service_account" "opsAgent_service_account" {
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
  description  = var.service_account_description
}

resource "google_project_iam_member" "publisher_role" {
  project = var.project
  role    = "roles/pubsub.publisher" # Specify the role you want to grant

  member = "serviceAccount:${google_service_account.opsAgent_service_account.email}"
}
// Bind IAM Logging Admin Role to the Ops Agent Service Account
resource "google_project_iam_binding" "iam_binding_for_loggingAdmin" {
  project = var.project
  role    = var.iam_role_loggingAdmin

  members = [
    "serviceAccount:${google_service_account.opsAgent_service_account.email}",
  ]
}

// Bind IAM Monitoring Metric Writer Role to the Ops Agent Service Account
resource "google_project_iam_binding" "iam_binding_for_monitoringMetricWriter" {
  project = var.project
  role    = var.iam_role_monitoringMetricWriter

  members = [
    "serviceAccount:${google_service_account.opsAgent_service_account.email}",
  ]
}

// Cloud DNS configuration 
data "google_dns_managed_zone" "dns_zone" {

  name = var.dns_zone_name
}

resource "google_dns_record_set" "dns_record_set_A" {
  name         = data.google_dns_managed_zone.dns_zone.dns_name
  type         = var.record_set_type
  ttl          = var.record_set_ttl
  managed_zone = data.google_dns_managed_zone.dns_zone.name
  rrdatas      = [module.gce-lb-http.external_ip]
}

#######################################################################################################################
resource "random_id" "key_ring_suffix" {
  byte_length = 4
}

//Create Key Ring
resource "google_kms_key_ring" "cmek_key_ring" {
  name     = "key-ring-${random_id.key_ring_suffix.hex}"
  location = var.region
}

// Create a Customer-Managed Encryption Key (CMEK) for Virtual Machines
resource "google_kms_crypto_key" "crypto_key_vm" {
  provider        = google-beta
  name            = "vm-crypto-key"
  key_ring        = google_kms_key_ring.cmek_key_ring.id
  rotation_period = "2592000s"

  lifecycle {
    prevent_destroy = false
  }
}

// Create a Customer-Managed Encryption Key (CMEK) for CloudSQL Instances
resource "google_kms_crypto_key" "crypto_key_sql" {
  provider        = google-beta
  name            = "sql-crypto-key"
  key_ring        = google_kms_key_ring.cmek_key_ring.id
  rotation_period = "2592000s"

  lifecycle {
    prevent_destroy = false
  }
}

// Create a Customer-Managed Encryption Key (CMEK) for Cloud Storage Buckets
resource "google_kms_crypto_key" "crypto_key_bucket" {
  provider        = google-beta
  name            = "cloud-bucket-crypto-key"
  key_ring        = google_kms_key_ring.cmek_key_ring.id
  rotation_period = "2592000s"

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_project_service_identity" "service_identity_cloud_sql" {
  provider = google-beta
  project  = var.project
  service  = "sqladmin.googleapis.com"
}

// IAM Binding for VM
resource "google_kms_crypto_key_iam_binding" "crypto_key_vm_iam" {
  provider      = google-beta
  crypto_key_id = google_kms_crypto_key.crypto_key_vm.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = ["serviceAccount:service-628283172311@compute-system.iam.gserviceaccount.com"]

}

// IAM Binding for SQL
resource "google_kms_crypto_key_iam_binding" "crypto_key_sql_iam" {
  provider      = google-beta
  crypto_key_id = google_kms_crypto_key.crypto_key_sql.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = ["serviceAccount:${google_project_service_identity.service_identity_cloud_sql.email}"]
}

data "google_storage_project_service_account" "storage_account" {}

// IAM Binding for Bucket
resource "google_kms_crypto_key_iam_binding" "crypto_key_bucket_iam" {
  provider      = google-beta
  crypto_key_id = google_kms_crypto_key.crypto_key_bucket.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = ["serviceAccount:${data.google_storage_project_service_account.storage_account.email_address}"]
}

// Secret manager
resource "google_secret_manager_secret" "host_name_database" {
  secret_id = "host-name-for-database"
  labels = {
    label = "host-name-for-database"
  }
  replication {
    auto {

    }
  }
}

resource "google_secret_manager_secret_version" "host_name_database" {
  secret      = google_secret_manager_secret.host_name_database.id
  secret_data = google_sql_database_instance.cloudsql_instance.private_ip_address
}

resource "google_secret_manager_secret" "password_for_database" {
  secret_id = "password-for-database"
  labels = {
    label = "password-for-database"
  }
  replication {
    auto {

    }
  }
}

resource "google_secret_manager_secret_version" "password_for_database" {
  secret      = google_secret_manager_secret.password_for_database.id
  secret_data = google_sql_user.webapp_user.password
}

resource "google_secret_manager_secret" "name_for_database" {
  secret_id = "name-for-database"
  labels = {
    label = "name-for-database"
  }
  replication {
    auto {

    }
  }
}

resource "google_secret_manager_secret_version" "name_for_database" {
  secret      = google_secret_manager_secret.name_for_database.id
  secret_data = "vaish"
}

resource "google_secret_manager_secret" "my_port" {
  secret_id = "port"
  labels = {
    label = "port"
  }
  replication {
    auto {

    }
  }
}

resource "google_secret_manager_secret_version" "my_port" {
  secret      = google_secret_manager_secret.my_port.id
  secret_data = "8080"
}

# resource "google_secret_manager_secret" "env_secret" {
#   secret_id = "ENV"
#   labels = {
#     label = "env"
#   }
#   replication {
#     auto {

#     }
#   }
# }
# resource "google_secret_manager_secret_version" "env_secret" {
#   secret = google_secret_manager_secret.env_secret.id
#   secret_data = "live"
# }

resource "google_secret_manager_secret" "encryption_key" {
  secret_id = "encryption-key"
  labels = {
    label = "encryption-key"
  }
  replication {
    auto {

    }
  }
}

resource "google_secret_manager_secret_version" "encryption_key" {
  secret      = google_secret_manager_secret.encryption_key.id
  secret_data = google_kms_crypto_key.crypto_key_vm.id
}
######################################################################################################################

##Cloud Function
resource "google_project_iam_binding" "generateToken" {
  project = var.project
  role    = var.generateTokenRole

  members = ["serviceAccount:${google_service_account.opsAgent_service_account.email}"]
}

//ROles
resource "google_cloudfunctions2_function_iam_member" "cloudInvoker" {
  cloud_function = google_cloudfunctions2_function.newCloudFunction.name
  role           = var.invokerRoleCloudFunction
  location       = var.region
  member         = "serviceAccount:${google_service_account.opsAgent_service_account.email}"
}

resource "google_cloud_run_service_iam_member" "cloudRunInvoker" {
  service  = google_cloudfunctions2_function.newCloudFunction.name
  role     = var.runInvokerRoleCloudFunction
  location = var.region
  member   = "serviceAccount:${google_service_account.opsAgent_service_account.email}"
}

resource "google_pubsub_topic_iam_binding" "editorPubSubTopic" {
  topic = google_pubsub_topic.nameOfTopic.name
  role  = var.topicRole

  members = ["serviceAccount:${google_service_account.opsAgent_service_account.email}"]
}

# resource "google_pubsub_subscription_iam_binding" "editorPubSubSubscription" {
#   subscription = google_pubsub_subscription.nameOFSubscription.name
#   role         = var.subscriptionRole

#   members = ["serviceAccount:${google_service_account.opsAgent_service_account.email}"]
# }


//Create PubSub Topic
resource "google_pubsub_topic" "nameOfTopic" {
  name                       = var.topicName
  message_retention_duration = var.retentionDuration
}

//Create Subscription

resource "google_pubsub_subscription" "nameOFSubscription" {
  name  = var.subscriptionName
  topic = google_pubsub_topic.nameOfTopic.id

  message_retention_duration = "604800s"
  retain_acked_messages      = true

  enable_exactly_once_delivery = true
}

// Create Bucket
resource "google_storage_bucket" "customBucketForCloudFunction" {
  encryption {
    default_kms_key_name = google_kms_crypto_key.crypto_key_bucket.id
  }
  depends_on = [google_kms_crypto_key_iam_binding.crypto_key_bucket_iam]
  name       = var.bucketNameForCloudFunction
  location   = var.region
}

resource "google_storage_bucket_object" "customBucketObjectForCloudFunction" {
  name   = var.bucketObjectName
  bucket = google_storage_bucket.customBucketForCloudFunction.name
  source = "serverless.zip"
}

//Cloud Function
resource "google_cloudfunctions2_function" "newCloudFunction" {
  name     = var.cloudfunctionName
  location = var.region

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point
    source {
      storage_source {
        bucket = google_storage_bucket.customBucketForCloudFunction.name
        object = google_storage_bucket_object.customBucketObjectForCloudFunction.name
      }
    }
  }

  service_config {
    max_instance_count               = var.max_instance_count
    max_instance_request_concurrency = var.max_instance_request_concurrency
    available_memory                 = var.available_memory
    timeout_seconds                  = var.timeout_seconds
    available_cpu                    = var.available_cpu

    vpc_connector                  = google_vpc_access_connector.vpcCconnector.name
    vpc_connector_egress_settings  = var.vpc_connector_egress_settings
    all_traffic_on_latest_revision = var.all_traffic_on_latest_revision
    service_account_email          = google_service_account.opsAgent_service_account.email
    environment_variables = {
      //PORT        = var.DB_PORT
      API_KEY     = var.apiKey
      DOMAIN      = var.domain
      HOST        = google_sql_database_instance.cloudsql_instance.private_ip_address
      DB_NAME     = var.database_name
      DB_USERNAME = google_sql_user.webapp_user.name
      DB_PASSWORD = google_sql_user.webapp_user.password
    }
  }

  event_trigger {
    trigger_region        = var.region
    event_type            = var.cloudFunctionEventType
    pubsub_topic          = google_pubsub_topic.nameOfTopic.id
    retry_policy          = var.retry_policy
    service_account_email = google_service_account.opsAgent_service_account.email
  }
}

resource "google_vpc_access_connector" "vpcCconnector" {
  name          = var.vpcConnectorName
  ip_cidr_range = var.vpc_cidr_range
  network       = google_compute_network.main.self_link
  region        = var.region
}
