job "hello-world" {
  region      = "global" # Use 'global' to allow cross-region scheduling
  datacenters = ["dc1", "dc2"] # List both datacenters

  type        = "service"
  namespace   = "default"

  group "app-group" {
    count = 1

    # Affinity to prefer placement in 'dc1'
    affinity {
      attribute = "${node.datacenter}"
      operator  = "="
      value     = "dc1"
      weight    = 100
    }

    # Constraint to ensure the job runs only in 'dc1' or 'dc2'
    constraint {
      attribute = "${node.datacenter}"
      operator  = "one_of"
      value     = ["dc1", "dc2"]
    }

    # Ensure it runs only on Windows servers
    constraint {
      attribute = "${attr.kernel.name}"
      operator  = "="
      value     = "windows"
    }

    task "hello-world" {
      driver = "raw_exec"

      artifact {
        source      = "https://raw.githubusercontent.com/William-Hashicorp/sampleapp/main/hello-world.ps1"
        destination = "${NOMAD_TASK_DIR}"
      }

      config {
        work_dir = "${NOMAD_TASK_DIR}"
        command  = "powershell.exe"
        args     = [
          "-File",
          "${NOMAD_TASK_DIR}\\hello-world.ps1"
        ]
      }

      resources {
        cpu    = 50  # CPU in MHz
        memory = 32  # Memory in MB
      }
    }
  }
}
