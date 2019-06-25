resource "google_compute_firewall" "default" {
    name    = "allow-all-traffic"
    network = "default"

    source_ranges = ["0.0.0.0/0"]

    allow {
        protocol = "tcp"
        ports    = ["0-65534"]
    }
}