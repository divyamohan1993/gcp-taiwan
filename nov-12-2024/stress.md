### Simulating CPU Stress on VM Instances to Demonstrate Autoscaling

#### Objective:
This guide explains how to install the `stress` tool on VM instances, simulate 60% CPU usage using `nohup` to run in the background, and manage the process to observe autoscaling in action.

---

### Key Concepts:
1. **Stress Tool**:
   - A utility to simulate high CPU, memory, and I/O usage on a system.
2. **Autoscaling Demonstration**:
   - By applying load on instances, observe how the system scales the number of VMs based on the CPU utilization threshold (60%).
3. **Background Execution**:
   - Using `nohup` ensures that the `stress` command runs even if the SSH session is closed.

---

### Steps to Simulate CPU Stress

#### 1. SSH into the Instance
- Use the `gcloud` command to connect to a VM instance:
  ```bash
  gcloud compute ssh <INSTANCE_NAME> --zone=<ZONE>
  ```
  Replace `<INSTANCE_NAME>` with the name of the VM instance and `<ZONE>` with its zone (e.g., `asia-east1-a`).

---

#### 2. Install the Stress Tool
- Update the package list and install the `stress` tool:
  ```bash
  sudo apt update
  sudo apt install -y stress
  ```

---

#### 3. Run Stress with `nohup`
- To simulate 60% CPU usage:
  - Identify the number of CPUs in the instance:
    ```bash
    nproc
    ```
    This returns the number of CPU cores (e.g., 4 for a quad-core instance).
  - Calculate the number of workers needed to generate 60% load:
    - Example: For a quad-core CPU, 60% load ≈ `4 * 0.6 = 2.4` workers.
    - Use `2` workers for simplicity.

- Run the `stress` command in the background using `nohup`:
  ```bash
  nohup stress --cpu 2 --timeout 300 > stress.log 2>&1 &
  ```
  Explanation:
  - `--cpu 2`: Uses 2 CPU workers.
  - `--timeout 300`: Runs for 300 seconds (5 minutes) and stops automatically.
  - `> stress.log`: Redirects output to a log file.
  - `2>&1`: Redirects errors to the same file.
  - `&`: Runs the process in the background.

---

#### 4. Verify Stress is Running
- Check if the `stress` process is running:
  ```bash
  ps aux | grep stress
  ```
  This displays details of the `stress` process.

---

#### 5. Stop the Stress Process (Manual Stop)
- To manually stop the `stress` process:
  1. Identify the process ID (PID):
     ```bash
     ps aux | grep stress
     ```
  2. Kill the process using its PID:
     ```bash
     kill <PID>
     ```
  3. If the process persists, force kill it:
     ```bash
     kill -9 <PID>
     ```

---

### Observing Autoscaling:
1. **After Applying Load**:
   - Monitor the autoscaler in **Google Cloud Console** under `Compute Engine > Instance Groups > apache-group`.
   - Observe the creation of additional instances as CPU utilization exceeds 60%.
2. **After Removing Load**:
   - Allow the `stress` process to stop automatically (via `--timeout`) or manually kill it.
   - Watch the autoscaler reduce the number of instances as CPU utilization drops below the threshold.

---

### Notes:
1. **Best Practices**:
   - Run stress tests one instance at a time to observe incremental scaling.
   - Start with a single instance and gradually add stress to others.
2. **Logging**:
   - Check `stress.log` for output and diagnostics.

---

### Cleanup:
To ensure resources are freed and costs are minimized:
- Manually stop all `stress` processes on all instances:
  ```bash
  pkill stress
  ```
  This stops all running `stress` processes on the instance.

---

### Example Workflow:
1. SSH into **Instance 1**:
   ```bash
   gcloud compute ssh apache-instance-1 --zone=asia-east1-a
   ```
   Install and run:
   ```bash
   sudo apt update
   sudo apt install -y stress
   nohup stress --cpu 2 --timeout 300 > stress.log 2>&1 &
   ```
2. Repeat for **Instance 2** and **Instance 3** (if needed):
   ```bash
   gcloud compute ssh apache-instance-2 --zone=asia-east1-a
   ```
   Run the same commands as above.

3. Observe the scaling behavior in **Google Cloud Console**.

---