# Connecting Two Google Cloud Instances: A Simple Guide

This guide will walk you through the steps to connect two Google Cloud instances (referred to as the **Host** and the **Guest**) using SSH (a method for securely connecting to another computer). Don’t worry if you’re unfamiliar with SSH—each step is explained in easy-to-understand language.

## Prerequisites

Before we start, make sure:
- You have access to two Google Cloud instances: one will be the **Host** and the other will be the **Guest**.
- You can log in to both instances (using Google Cloud's SSH button is a simple way to do this).

---

## Step 1: Configure the Guest Instance

### What you'll do:
We need to adjust the settings of the **Guest** instance so that it allows root login and password authentication.

### Steps:
1. Log in to your **Guest** instance.
   - In Google Cloud, go to your **Guest** instance and click the **SSH** button to open a terminal window.
2. Once you are logged in, enter the following command to open the SSH configuration file:
   ```bash
   sudo nano /etc/ssh/sshd_config
   ```
3. Inside the file, look for these two lines:
   - `PermitRootLogin`
   - `PasswordAuthentication`
4. Change both of these to `yes` (if they are not already set to `yes`).
5. After making these changes, save the file and close it (press **CTRL+X**, then **Y**, and hit **Enter** to save).
6. Now restart the SSH service by running this command:
   ```bash
   sudo systemctl restart sshd
   ```

---

## Step 2: Connect from the Host Instance to the Guest Instance

### What you'll do:
Now, we'll connect from the **Host** instance to the **Guest** instance using its IP address.

### Steps:
1. Log in to your **Host** instance.
   - In Google Cloud, go to your **Host** instance and click the **SSH** button.
2. To connect to the **Guest** instance, run the following command, replacing `Guest_IP` with the actual IP address of your **Guest** instance:
   ```bash
   ssh root@Guest_IP
   ```
3. If prompted, enter the **Guest** instance's root password (the default password for root access).

---

## Optional: Setting Up Password-Free Login (for easier future connections)

### What you'll do:
This optional step will allow you to connect to the **Guest** instance from the **Host** without entering a password each time.

### Steps:
1. On the **Host** instance, generate an SSH key by running this command:
   ```bash
   ssh-keygen -t rsa
   ```
   - When prompted to choose a file location, you can just press **Enter** to use the default location.
2. After the key is generated, copy it to the **Guest** instance with this command:
   ```bash
   ssh-copy-id root@Guest_IP
   ```
   - Replace `Guest_IP` with the actual IP address of your **Guest** instance.
   - When prompted, enter the **Guest** root password one last time.

Now, you will be able to connect from the **Host** to the **Guest** without needing to enter a password every time!

---

## Optional: Changing the Root Password on the Guest Instance

### What you'll do:
For security reasons, you might want to change the root password on the **Guest** instance.

### Steps:
1. Log in to your **Guest** instance (either through Google Cloud or using the SSH command).
2. To change the root password, enter the following command:
   ```bash
   sudo passwd root
   ```
3. Follow the prompts to enter a new password and confirm it.

---

## Conclusion

That's it! You’ve successfully set up a connection between two Google Cloud instances using SSH. If you followed the optional steps, you also made it more convenient and secure by setting up password-free login.
