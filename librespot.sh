## to compile librespot:

cd ~ || exit
curl https://sh.rustup.rs -sSf | sh
source /home/pi/.cargo/env
sudo apt install build-essential libasound2-dev pkg-config git
git clone https://github.com/librespot-org/librespot.git
cd librespot || exit
cargo build --no-default-features --features "alsa-backend" --release


## to update librespot:

cd ~ || exit
cargo update
cd librespot || exit
git pull
cargo build --no-default-features --features "alsa-backend" --release
