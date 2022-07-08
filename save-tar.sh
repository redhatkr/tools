#!/bin/bash
INPUT=$1
FROM="docker://ocp-registry-quay-quay.apps.ocp-vm.poc.cloud/admin"
TO="docker-archive:."
SRC_CREDS="admin:r3dh4t1!"
DESC_CREDS="ocpadmin:ocpadmin"
SAVED_FILE="tar-saved-file.txt"

rm $SAVED_FILE


# to tar
#skopeo copy --src-creds=admin:r3dh4t1! --src-tls-verify=false docker://ocp-registry-quay-quay.apps.ocp-vm.poc.cloud/admin/poc-app:latest docker-archive:./poc-app:latest.tar
# from tar
#skopeo copy --dest-creds=ocpadmin:ocpadmin --dest-tls-verify=false docker-archive:poc-app:latest.tar docker://vm-bastion.ocp-vm.poc.cloud:8443/admin/poc-app:latest


while IFS= read -r IMAGE
do
  IMAGE=$(echo $IMAGE | tr -d ' ')
  echo ""
  echo "$IMAGE"
  echo "---"
  RESULT=$(skopeo list-tags --creds=$SRC_CREDS --tls-verify=false $FROM/$IMAGE)

#  echo $RESULT

  TAG_STRING=$(echo $RESULT | awk '{ for(i=6; i<NF-1; i++) printf "%s",$i }')
  echo "TAG = [$TAG_STRING]"
  

  IFS=',' read -r -a TAGS <<< $TAG_STRING
  for TAG in "${TAGS[@]}"
  do
      TAG=$(echo $TAG | tr -d '\"')
      echo ""
      echo ">>>>>>>> COPY for $IMAGE:$TAG"
      echo "skopeo copy --remove-signatures --src-creds=$SRC_CREDS --src-tls-verify=false $FROM/$IMAGE:$TAG $TO/$IMAGE#$TAG.tar"
      skopeo copy --remove-signatures --src-creds=$SRC_CREDS --src-tls-verify=false $FROM/$IMAGE:$TAG $TO/$IMAGE#$TAG.tar

      # add tar file to list
      echo -e $IMAGE#$TAG.tar >> $SAVED_FILE
      
  done

done < "$INPUT"
