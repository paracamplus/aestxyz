#! /bin/bash
# Only required for boot2docker on MacOSX

work () {
    # port forward via VirtualBox to containers:
    # NOTA: we must use controlvm since the boot2docker-vm is already running.
    Vboxmanage controlvm "boot2docker-vm" natpf1 delete "vmp-http"
    Vboxmanage controlvm "boot2docker-vm" \
               natpf1 "vmp-http,tcp,,${HOSTPORT},,${HOSTPORT}"
    Vboxmanage controlvm "boot2docker-vm" natpf1 delete "vmp-ssh"
    Vboxmanage controlvm "boot2docker-vm" \
               natpf1 "vmp-ssh,tcp,,${HOSTSSHPORT},,${HOSTSSHPORT}"
}

if which boot2docker >/dev/null
then
    # We suppose the Docker daemon to be run through boot2docker
    # This is the case for MacOSX.
    export USING_BOOT2DOCKER=true
    echo "Coping with boot2docker..."
    work
fi

# end of install-90-vbox.sh
