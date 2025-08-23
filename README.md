# Application

[Readarr](https://github.com/Readarr/Readarr)

## Description

Readarr is an ebook and audiobook collection manager for Usenet and BitTorrent
users. It can monitor multiple RSS feeds for new books from your favorite
authors and will grab, sort and rename them. Note that only one type of a given
book is supported. If you want both an audiobook and ebook of a given book you
will need multiple instances.

## Build notes

Latest stable Readarr release from Arch Linux AUR.

## Usage

```bash
docker run -d \
    -p 8787:8787 \
    --name=<container name> \
    -v <path for media files>:/media \
    -v <path for data files>:/data \
    -v <path for config files>:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e HEALTHCHECK_COMMAND=<command> \
    -e HEALTHCHECK_ACTION=<action> \
    -e HEALTHCHECK_HOSTNAME=<hostname> \
    -e UMASK=<umask for created files> \
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \
    binhex/arch-Readarr
```

Please replace all user variables in the above command defined by <> with the
correct values.

## Access application

`http://<host ip>:8787`

## Example

```bash
docker run -d \
    -p 8787:8787 \
    --name=Readarr \
    -v /media/tv:/media \
    -v /apps/docker/sabnzbd/watched:/data \
    -v /apps/docker/Readarr:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e UMASK=000 \
    -e PUID=0 \
    -e PGID=0 \
    binhex/arch-Readarr
```

## Notes

User ID (PUID) and Group ID (PGID) can be found by issuing the following command
for the user you want to run the container as:-

```bash
id <username>
```

___
If you appreciate my work, then please consider buying me a beer  :D

[![PayPal donation](https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=MM5E27UX6AUU4)

[Documentation](https://github.com/binhex/documentation) | [Support forum](https://forums.unraid.net/topic/116459-support-binhex-readarr/)
