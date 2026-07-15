# SSH Config — Personal Cloud
# /etc/ssh/sshd_config.d/99-hardening.conf
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
MaxAuthTries 3
LoginGraceTime 30
X11Forwarding no
AllowTcpForwarding no
