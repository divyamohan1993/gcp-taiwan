On Host:
- ssh root@Guest_IP
- ssh-keygen -t rsa

On Guest:
- sudo nano /etc/ssh/sshd_config
- Change PermitRootLogin and PasswordAuthentication to yes then `sudo systemctl restart sshd`.
- Optional: Change password `sudo passwd root`

On Host:
- `ssh-copy-id root@Guest_IP` and Enter password.
- - Connect from host. ssh root@Guest_IP



