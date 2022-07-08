#!/bin/bash
BASEDIR="tar"
FROM="docker-archive:."
TO="docker://vm-bastion.ocp-vm.poc.cloud:8443/admin"
SRC_CREDS="admin:r3dh4t1!"
DESC_CREDS="ocpadmin:ocpadmin"
SAVED_FILE="tar-saved-file.txt"
LOADED_FILE="tar-loaded-file.txt"

INPUT=$1

rm $LOADED_FILE

# to tar
#skopeo copy --src-creds=admin:r3dh4t1! --src-tls-verify=false docker://ocp-registry-quay-quay.apps.ocp-vm.poc.cloud/admin/poc-app:latest docker-archive:./poc-app:latest.tar
# from tar
#skopeo copy --dest-creds=ocpadmin:ocpadmin --dest-tls-verify=false docker-archive:poc-app:latest.tar docker://vm-bastion.ocp-vm.poc.cloud:8443/admin/poc-app:latest


while IFS= read -r TAR
do
  TAR=$(echo $TAR | tr -d ' ')
  echo ""
  echo "$TAR"
  echo "---"

  IMAGE=$(echo $TAR | awk -F"#" '{ printf $1 }')
  TAG=$(echo $TAR | awk -F"#" '{ printf $2 }')
  echo "image=$IMAGE, tag=$TAG"
  TAG=${TAG%\.tar}
  echo "image=$IMAGE, tag=$TAG"
  
  echo ""
  echo ">>>>>>>> COPY for $IMAGE:$TAG"
  echo "skopeo copy --dest-creds=ocpadmin:ocpadmin --dest-tls-verify=false $FROM/$BASEDIR/$IMAGE#$TAG.tar $TO/$IMAGE:$TAG"
  skopeo copy --dest-creds=ocpadmin:ocpadmin --dest-tls-verify=false $FROM/$BASEDIR/$IMAGE#$TAG.tar $TO/$IMAGE:$TAG

  # add tar file to list
  echo -e $IMAGE#$TAG.tar >> $LOADED_FILE
      

done < "$INPUT"
