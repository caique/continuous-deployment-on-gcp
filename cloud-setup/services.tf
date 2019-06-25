resource "google_project_service" "cloudresourcemanager_googleapis_com" {
    service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "compute_googleapis_com" {
    service = "compute.googleapis.com"
    depends_on = [
        "google_project_service.cloudresourcemanager_googleapis_com"
    ]
}

resource "google_project_service" "storagecomponent_googleapis_com" {
    service = "storage-component.googleapis.com"
    depends_on = [
        "google_project_service.cloudresourcemanager_googleapis_com"
    ]
}

resource "google_project_service" "container_googleapis_com" {
    service = "container.googleapis.com"
    depends_on = [
        "google_project_service.cloudresourcemanager_googleapis_com"
    ]
}