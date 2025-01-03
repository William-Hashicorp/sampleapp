job "hello-world" {
  region      = "region1"
  datacenters = ["dc1"]
  type        = "service"
  namespace   = "default"

  group "app-group" {
    count = 1

    # Ensure it runs only on Windows servers
    constraint {
      attribute = "${attr.kernel.name}"
      operator  = "="
      value     = "windows"
    }

    task "hello-world" {
      driver = "raw_exec"

      # Artifact block corrected to specify only the destination directory
      artifact {
        source      = "https://raw.githubusercontent.com/William-Hashicorp/sampleapp/main/hello-world.ps1"
        destination = "${NOMAD_TASK_DIR}" # Use the task directory as the destination
      }

      config {
        work_dir = "${NOMAD_TASK_DIR}"
        command = "powershell.exe"
        args = [
          "-File",
          "${NOMAD_TASK_DIR}\\hello-world.ps1" # Execute the script from the destination directory
        ]
      }

      # Very small resource allocation
      resources {
        cpu    = 50  # CPU in MHz (very low usage)
        memory = 32  # Memory in MB (minimal allocation)
      }
    }
  }
}
