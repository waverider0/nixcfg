# service control
sudo systemctl start monero.service
sudo systemctl stop monero.service
sudo systemctl restart monero.service
sudo systemctl enable monero.service   # start at boot
sudo systemctl disable monero.service  # skip at boot
sudo systemctl status monero.service

sudo systemctl start tor.service
sudo systemctl stop tor.service
sudo systemctl restart tor.service
sudo systemctl status tor.service

# live logs
sudo journalctl -u monero.service -f
sudo journalctl -u tor.service -f
sudo journalctl -u monero.service --since "2 hours ago"

# full log export
sudo journalctl -u monero.service > monerod.log

# socket and port inspection
ss -tulpn | grep -E '1808[0-9]|9050'
lsof -i -P -n | grep monerod

# bandwidth view (per process)
sudo nethogs

# onion address used by peers and wallets
sudo cat /var/lib/tor/monerod/hostname

# blockchain data location
du -sh /var/lib/monero
