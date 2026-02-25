#!/bin/bash
# This tool is used to automate the uploading of various gitlab images to repoman
set -e
src_image="registry.gitlab.com/gitlab-org/build/cng"
config="</Path/to/image.cfg>"
NEXUS="<nexus url>"
REPO="gitlab-cng/gitlab-org/build/cng"
src_dir="</Path/to/tar/location?"

read -p "Please enter the GitLab tag: " TAG

get_images(){
        while IFS= read -r image; do
        [[ -z "$image" ]] && continue
        [[ "$image" =~ ^[[:space:]]*# ]] && continue
        echo "getting image $image"
        skopeo copy docker://$src_image/${image}:${TAG} docker-archive:${image}_${TAG}.tar:${image}:${TAG}
done < "$config"

}
push_images(){

for tar in $src_dir/*.tar; do
        name="${tar##*/}"
        #echo "name=$name"
        tmp=${name%.tar}
        #echo "tmp=$tmp"
        image="${tmp%_${TAG}}"
        #echo "image=$image"
        echo "pushing $image:$TAG from $tar"
        skopeo copy --all docker-archive:$name docker://$NEXUS/$REPO/$image:$TAG

done
}
get_images
skopeo login $NEXUS
push_images
