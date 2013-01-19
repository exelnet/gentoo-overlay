## Warning

Use at your own risks

## Installation

### Using layman

#### Install layman
    emerge layman
    echo 'source /var/lib/layman/make.conf' >> /etc/make.conf

#### Add the 'exelnet' overlay
    layman -o https://github.com/exelnet/gentoo-overlay/raw/master/overlay.xml -f -a exelnet

#### Sync overlays
    layman -S

#### Install
    emerge package_name

