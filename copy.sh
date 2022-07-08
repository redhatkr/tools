#!/bin/bash
INPUT=$1
FROM="docker://ocp-registry-quay-quay.apps.ocp-vm.poc.cloud/admin"
TO="docker://vm-bastion.ocp-vm.poc.cloud:8443/admin"
SRC_CREDS="admin:r3dh4t1!"
DESC_CREDS="ocpadmin:ocpadmin"

#skopeo copy -a --src-creds=admin:r3dh4t1! --src-tls-verify=false --dest-creds=ocpadmin:ocpadmin --dest-tls-verify=false docker://ocp-registry-quay-quay.apps.ocp-vm.poc.cloud/admin/perl docker://vm-bastion.ocp-vm.poc.cloud:8443/admin/perl

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
      echo "skopeo copy --src-creds=$SRC_CREDS --src-tls-verify=false --dest-creds=$DESC_CREDS --dest-tls-verify=false $FROM/$IMAGE:$TAG $TO/$IMAGE:$TAG"
      skopeo copy --src-creds=$SRC_CREDS --src-tls-verify=false --dest-creds=$DESC_CREDS --dest-tls-verify=false $FROM/$IMAGE:$TAG $TO/$IMAGE:$TAG
  done

done < "$INPUT"
