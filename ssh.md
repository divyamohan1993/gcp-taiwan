On Host:
1. ssh root@Guest_IP
2. ssh-keygen -t rsa

On Guest:
3. sudo nano /etc/ssh/sshd_config
Change PermitRootLogin and PasswordAuthentication to yes then `sudo systemctl restart sshd`.
Optional: Change password `sudo passwd root`

On Host:
4. `ssh-copy-id root@Guest_IP` and Enter password.
5. Connect from host. ssh root@Guest_IP



