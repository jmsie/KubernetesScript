# https://github.com/GoogleCloudPlatform/k8s-multicluster-ingress/tree/master/examples/zone-printer
git clone https://github.com/GoogleCloudPlatform/k8s-multicluster-ingress.git
ln -s ./k8s-multicluster-ingress/examples/zone-printer/ ./zone-printer

PROJECT="CMU-WEB"
cd ~
wget https://storage.googleapis.com/kubemci-release/release/latest/bin/linux/amd64/kubemci
chmod +x ./kubemci
mkdir bin
mv ./kubemci ~/bin/kubemci
export PATH=$PATH:~/bin/

# Step 1: Create Kubernetes Clusters
# Create a cluster in us-east and get its credentials
KUBECONFIG=clusters.yaml gcloud container clusters create \
    --cluster-version=1.10 \
    --zone=us-east4-a \
    cluster-1


# Create a cluster in eu-west and get its credentials
KUBECONFIG=clusters.yaml gcloud container clusters create \
    --cluster-version=1.10 \
    --zone=us-east1-b \
    cluster-2

# List all clusters
kubectl --kubeconfig=clusters.yaml config get-contexts -o name

# Step 2: Deploy the sample application
for ctx in $(kubectl config get-contexts -o=name --kubeconfig clusters.yaml); do
  kubectl --kubeconfig clusters.yaml --context="${ctx}" create -f ./zone-printer/manifests/
done

# Step 3: Reserve a static IP address
ZP_KUBEMCI_IP="zp-kubemci-ip"
gcloud compute addresses create --global "${ZP_KUBEMCI_IP}"

# Step 4: Use the static IP on Ingress manifest
sed -i -e "s/\$ZP_KUBEMCI_IP/${ZP_KUBEMCI_IP}/" ./zone-printer/ingress/ingress.yaml

# Step 5: Deploy the multi-cluster Ingress with kubemci
kubemci create zone-printer \
    --ingress=./zone-printer/ingress/ingress.yaml \
    --kubeconfig=clusters.yaml

# Step 6: View multi-cluster Ingress status
kubemci get-status zone-printer 

# list ingress 
kubemci list

#kubectl create -f ingress.yaml
#kubectl get ing
#kubectl get clusters
#kubectl del clusters [name]
