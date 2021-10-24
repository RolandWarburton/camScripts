sudo cp ./compress.timer /etc/systemd/system;
sudo cp ./compress.service /etc/systemd/system;
sudo cp ./recordBatch.service /etc/systemd/system;

sudo systemctl enable compress.service;
sudo systemctl enable --now compress.timer;
sudo systemctl enable --now recordBatch.service;
