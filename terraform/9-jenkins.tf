# Create a Jenkins instance
resource "google_compute_instance" "jenkins" {
  name         = "jenkins"
  machine_type = "e2-medium"
  zone         = "asia-southeast2-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }

    auto_delete = true
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  network_interface {
    network    = google_compute_network.main.self_link
    subnetwork = google_compute_subnetwork.private.self_link

    access_config {
      // Use ephemeral IP address
      nat_ip = google_compute_address.jenkins-static-ip.address
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  tags = ["jenkins-vm-instance"]

  metadata = {
    ssh-keys = "marfreru:${file("~/.ssh/id_rsa.pub")}"
  }

  metadata_startup_script = file("./jenkins-startup-script.sh")
}

resource "google_compute_firewall" "ssh-rule" {
  name    = "jenkins-ssh"
  network = google_compute_network.main.id
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  target_tags = ["jenkins-vm-instance"]
  # source_tags = ["web"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "jenkins-static-ip" {
  provider     = google
  name         = "jenkins-static-ip"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}