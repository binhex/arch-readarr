#!/bin/bash

# exit script if return code != 0
set -e

# app name from buildx arg, used in healthcheck to identify app and monitor correct process
APPNAME="${1}"
shift

# release tag name from buildx arg, stripped of build ver using string manipulation
RELEASETAG="${1}"
shift

# target arch from buildx arg
TARGETARCH="${1}"
shift

if [[ -z "${APPNAME}" ]]; then
	echo "[warn] App name from build arg is empty, exiting script..."
	exit 1
fi

if [[ -z "${RELEASETAG}" ]]; then
	echo "[warn] Release tag name from build arg is empty, exiting script..."
	exit 1
fi

if [[ -z "${TARGETARCH}" ]]; then
	echo "[warn] Target architecture name from build arg is empty, exiting script..."
	exit 1
fi

# write APPNAME and RELEASETAG to file to record the app name and release tag used to build the image
echo -e "export APPNAME=${APPNAME}\nexport IMAGE_RELEASE_TAG=${RELEASETAG}\n" >> '/etc/image-build-info'

# ensure we have the latest builds scripts
refresh.sh

# pacman packages
####

# define pacman packages
pacman_packages=""

# install compiled packages using pacman
if [[ -n "${pacman_packages}" ]]; then
	# arm64 currently targetting aor not archive, so we need to update the system first
	if [[ "${TARGETARCH}" == "arm64" ]]; then
		pacman -Syu --noconfirm
	fi
	pacman -S --needed $pacman_packages --noconfirm
fi

# aur packages
####

# define aur packages
aur_packages="readarr-nightly-bin"

# call aur install script (arch user repo)
source aur.sh

# container perms
####

# define comma separated list of paths
install_paths="/usr/lib/readarr,/home/nobody"

# split comma separated string into list for install paths
IFS=',' read -ra install_paths_list <<< "${install_paths}"

# process install paths in the list
for i in "${install_paths_list[@]}"; do

	# confirm path(s) exist, if not then exit
	if [[ ! -d "${i}" ]]; then
		echo "[crit] Path '${i}' does not exist, exiting build process..." ; exit 1
	fi

done

# convert comma separated string of install paths to space separated, required for chmod/chown processing
install_paths=$(echo "${install_paths}" | tr ',' ' ')

# set permissions for container during build - Do NOT double quote variable for install_paths otherwise this will wrap space separated paths as a single string
chmod -R 775 ${install_paths}

# create file with contents of here doc, note EOF is NOT quoted to allow us to expand current variable 'install_paths'
# we use escaping to prevent variable expansion for PUID and PGID, as we want these expanded at runtime of init.sh
cat <<EOF > /tmp/permissions_heredoc

# get previous puid/pgid (if first run then will be empty string)
previous_puid=\$(cat "/root/puid" 2>/dev/null || true)
previous_pgid=\$(cat "/root/pgid" 2>/dev/null || true)

# if first run (no puid or pgid files in /tmp) or the PUID or PGID env vars are different
# from the previous run then re-apply chown with current PUID and PGID values.
if [[ ! -f "/root/puid" || ! -f "/root/pgid" || "\${previous_puid}" != "\${PUID}" || "\${previous_pgid}" != "\${PGID}" ]]; then

	# set permissions inside container - Do NOT double quote variable for install_paths otherwise this will wrap space separated paths as a single string
	chown -R "\${PUID}":"\${PGID}" ${install_paths}

fi

# write out current PUID and PGID to files in /root (used to compare on next run)
echo "\${PUID}" > /root/puid
echo "\${PGID}" > /root/pgid

EOF

# replace permissions placeholder string with contents of file (here doc)
sed -i '/# PERMISSIONS_PLACEHOLDER/{
    s/# PERMISSIONS_PLACEHOLDER//g
    r /tmp/permissions_heredoc
}' /usr/bin/init.sh
rm /tmp/permissions_heredoc

# env vars
####

# cleanup
cleanup.sh
