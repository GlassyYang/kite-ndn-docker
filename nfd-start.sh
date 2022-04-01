
#!/usr/bin/bash

VERSION=`nfd --version`

case "$1" in
  -h)
    echo Usage
    echo $0
    echo "  Start NFD"
    exit 0
    ;;
  -V)
    echo $VERSION
    exit 0
    ;;
  "") ;; # do nothing
  *)
    echo "Unrecognized option $1"
    exit 1
    ;;
esac

hasProcess() {
  local processName=$1

  if pgrep -x $processName >/dev/null
  then
    echo $processName
  fi
}

hasNFD=$(hasProcess nfd)

if [[ -n $hasNFD ]]
then
  echo 'NFD is already running...'
  exit 1
fi

if ! ndnsec-get-default &>/dev/null
then
  ndnsec-keygen /localhost/operator | ndnsec-install-cert -
fi

/usr/local/bin/nfd &

if [ -f /usr/local/etc/ndn/nfd-init.sh ]; then
  sleep 2 # post-start is executed just after nfd process starts, but there is no guarantee
  # that all initialization has been finished
  . /usr/local/etc/ndn/nfd-init.sh
fi

if [ -f /usr/local/etc/ndn/autoconfig.conf ]; then
  sleep 2 # post-start is executed just after nfd process starts, but there is no guarantee
  /usr/local/bin/ndn-autoconfig -d -c "/usr/local/etc/ndn/autoconfig.conf" &
fi

read

kill -9 `ps | grep "nfd" | awk '{print $2}'`
