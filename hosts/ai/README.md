# service control
sudo systemctl start open-webui.service
sudo systemctl stop open-webui.service
sudo systemctl restart open-webui.service
sudo systemctl enable open-webui.service    # start at boot
sudo systemctl disable open-webui.service   # skip at boot
sudo systemctl status open-webui.service

# live logs
sudo journalctl -u open-webui.service -f
sudo journalctl -u open-webui.service --since "2 hours ago"

# export full logs
sudo journalctl -u open-webui.service > open-webui.log

# inspect active sockets and binding
ss -tulpn | grep 8080

# test if port is up (should reply with HTTP headers)
curl -I http://127.0.0.1:8080

# check config files (if customized in flake or module)
sudo cat /var/lib/open-webui/config.json
sudo ls -l /var/lib/open-webui/

# model backend (Ollama) must also be reachable
curl http://127.0.0.1:11434/api/tags

# get memory, CPU, GPU usage for the AI process
ps aux | grep '[o]pen-webui'
top -p $(pgrep -f open-webui)
nvidia-smi                         # if using CUDA

# verify the service is listening and responding
xdg-open http://127.0.0.1:8080

# persistent data directory
du -sh /var/lib/open-webui
