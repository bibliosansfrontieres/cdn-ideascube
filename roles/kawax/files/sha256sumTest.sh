#!/bin/sh

CHECKSUM_DIR=/home/ideascube/checksum
wget --quiet http://catalog.ideascube.org/kiwix.yml -O kiwix.yml                    

mkdir -p "$CHECKSUM_DIR"

for i in $(locate -ir 'kiwix-'); do
        name=`echo $(basename $i) | sed 's/kiwix-0.9+//' | cut -d "_" -f1-2 | sed 's/_/\\\\./'`
        strip_name=`echo $name | sed 's/\\\//'`
        sha256sum=`cat kiwix.yml| shyaml get-value all."$name".sha256sum`

        echo "$sha256sum  $i" > "$CHECKSUM_DIR"/"$strip_name"

        echo "[+] Testintg $name - $sha256sum"
        sha256sum -c "$CHECKSUM_DIR"/"$strip_name" $i 2>&1 | grep FAILED            
        echo "\n"
done
