#!/bin/bash
dnf update -y
dnf install -y --allowerasing curl 
curl -Lo ./kops https://github.com/kubernetes/kops/releases/download/$(curl -s -L https://api.github.com/repos/kubernetes/kops/releases/latest  | jq -r .tag_name)/kops-linux-arm64
chmod +x ./kops
mv ./kops /usr/local/bin/kops
curl -Lo ./kubectl https://dl.k8s.io/release/$(curl -s -L https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
kops create cluster --name=${name} --state=s3://${bucket} --cloud=aws --zones=us-east-1a --dns=none --yes
kops update cluster --name=${name} --state=s3://${bucket} --yes --admin
