# Kubernetes & cloud native tech workshop

Estimated presentation time: 4x2 hours

## What is Kubernetes?

Docs: https://kubernetes.io/docs/home/  
Components: https://kubernetes.io/docs/concepts/overview/components/  
Video: https://www.youtube.com/watch?v=WxuvwSPSgXA

Cloud native landscape: https://landscape.cncf.io/  
OperatorHub (for research): https://operatorhub.io/


## Google Cloud

SO survey 2022: https://survey.stackoverflow.co/2022/#most-popular-technologies-platform

Google Cloud: https://cloud.google.com/  
Free tier limits: https://cloud.google.com/free/docs/gcp-free-tier/#free-tier-usage-limits

Create bew GCP project: https://console.cloud.google.com/cloud-resource-manager  
APIs to enable: 
- Compute: https://console.cloud.google.com/apis/library/compute.googleapis.com
- GKE: https://console.cloud.google.com/marketplace/product/google/container.googleapis.com

**gcloud** CLI: https://cloud.google.com/sdk/docs/install  
Manjaro/Arch: **google-cloud-sdk**

```bash
gcloud init
gcloud auth application-default login
```


## Terraform

Docs: https://registry.terraform.io/browse/providers

Google Cloud: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster  
Proxmox: https://github.com/Telmate/terraform-provider-proxmox (https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)  
VMware: https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs  
Spotify :D https://registry.terraform.io/providers/conradludgate/spotify/latest/docs/resources/playlist

Manjaro/Arch: **tfenv** (version manager, provides terraform)

```bash
sudo tfenv install 1.2.2
sudo tfenv use 1.2.2
terraform version

terraform init
terraform workspace new prod
terraform workspace select prod
```

Git ignore state: https://gitignore.io  
GitLab state management: https://docs.gitlab.com/ee/user/infrastructure/iac/terraform_state.html  
Cloud state: https://cloud.google.com/docs/terraform/resource-management/store-state

Reverse terraform: https://github.com/GoogleCloudPlatform/terraformer

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
#terraform destroy
```

Language reference: https://www.terraform.io/language/values/variables


## Low-level debug

```bash
gcloud compute instances list
gcloud compute ssh GMAIL_USERNAME@gke-k8s-cluster-k8s-node-pool-prod-c8103ef3-bwfs --tunnel-through-iap
> sudo docker ps -a
```

Elements of the stack: https://iximiuz.com/en/posts/implementing-container-runtime-shim/  
**kubectl** vs **crictl** vs **ctr** vs **nerdctl**: https://iximiuz.com/en/posts/containerd-command-line-clients/  
Relevant XKCD: https://xkcd.com/2347/

```bash
# still in the SSH session

> sudo crictl ps -a
> sudo crictl exec -it 55aa48add8b6c /bin/sh

> sudo ctr ns ls
> sudo ctr --namespace k8s.io c ls
> sudo ctr --namespace k8s.io t exec -t --exec-id asdasd 55aa48add8b6c0ff8cdc8d70d890f64d5972cddff245f4ea8bcacfaab8841cb9 /bin/sh
```

**nerdctl** repo: https://github.com/containerd/nerdctl

```bash
# still in the SSH session

> wget -O nerdctl.tar.gz https://github.com/containerd/nerdctl/releases/download/v0.21.0/nerdctl-0.21.0-linux-amd64.tar.gz
> sudo tar Cxzvvf /usr/local/bin nerdctl.tar.gz
> sudo nerdctl --namespace k8s.io ps -a
> sudo nerdctl --namespace k8s.io exec -it 55aa48add8b6c /bin/sh
```


## Dashboard

Repo: https://github.com/kubernetes/dashboard

```bash
gcloud container clusters get-credentials k8s-cluster-prod --zone europe-west1-b
kubectl get no
kubectl config get-contexts

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.0/aio/deploy/recommended.yaml
kubectl apply -f k8s-dashboard-user.yaml
kubectl -n kubernetes-dashboard describe secret admin-user-token-89t4z  # the random ID at the end can change
kubectl -n kubernetes-dashboard port-forward service/kubernetes-dashboard 9001:443
```

Login with the token at https://127.0.0.1:9001

Manjaro/Arch: **k9s**


## kubectx, kubens

Repo: https://github.com/ahmetb/kubectx

Manjaro/Arch: **kubectx** (also provides kubens)

```bash
kubectx
kubectx prod

kubens
kubens kubernetes-dashboard
```


## Ingress

Nginx docs: https://kubernetes.github.io/ingress-nginx/

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.2.0/deploy/static/provider/cloud/deploy.yaml
kubectl get svc --all-namespaces
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

Check the LoadBalancer IP (globally unique)  
Observe the 404 at http://35.187.75.57/  
Add the IP to `/etc/hosts` with a/some custom domain name(s):

```
35.187.75.57  k8sws.gke dashboard.k8sws.gke kuard.k8sws.gke
```

http://k8sws.gke/  
http://dashboard.k8sws.gke/  
http://kuard.k8sws.gke/

```bash
kubectl apply -f k8s-dashboard-ingress.yaml
#kubectl -n kubernetes-dashboard describe secret admin-user-token-89t4z  # the random ID at the end can change
```

Check the dashboard at: https://dashboard.k8sws.gke/ (self-signed fake cert)

Krew (kubectl plugin manager) repo: https://github.com/kubernetes-sigs/krew  
Manjaro/Arch: **krew-bin**

```bash
kubectl krew update
kubectl krew upgrade
kubectl krew install ingress-nginx

kubectl ingress-nginx conf -n ingress-nginx --host dashboard.k8sws.gke

kubectl scale --replicas 3 -n ingress-nginx deployment/ingress-nginx-controller
kubectl get deployment -n ingress-nginx
kubectl get svc --all-namespaces
kubectl describe svc -n ingress-nginx ingress-nginx-controller
```


## Kubernetes up and running demo (kuard)

Repo: https://github.com/kubernetes-up-and-running/kuard  
Basic auth: https://kubernetes.github.io/ingress-nginx/examples/auth/basic/

```bash
kubectl apply -f kuard.yaml
```

http://kuard.k8sws.gke/ (k8s / workshop)


## Storage (PV, PVC)

Similar to Docker volumes and mounts: https://docs.docker.com/storage/  
Volumes: https://kubernetes.io/docs/concepts/storage/volumes/
- Epehemeral
- Persistent
- Projected

Access modes: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes

The baked-in Google driver is deprecated, use the CSI plugin: https://github.com/kubernetes-sigs/gcp-compute-persistent-disk-csi-driver  
Automatically enabled with GKE: https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/gce-pd-csi-driver

Google storage types: https://cloud.google.com/kubernetes-engine/docs/concepts/storage-overview  
Storage choice help: https://cloud.google.com/products/storage  
Default Cloud Storage StorageClass guide with examples: https://cloud.google.com/kubernetes-engine/docs/concepts/persistent-volumes

NFS as self-hosted storage option: https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner

```bash
kubectl get sc
kubectl get sc -o yaml
kubectl get pv,pvc --all-namespaces
```

Meaning of SC versions: https://cloud.google.com/compute/docs/disks/#disk-types

```bash
kubectl apply -f kuard-with-storage.yaml
kubectl get -n kuard pv,pvc
kubectl exec -n kuard -it deployment/kuard -- sh
```
```bash
# inside the pod

ls -la storage1
ls -la storage2
ls -la cache
ls -la secret
cat secret/auth

date > storage1/a.txt
date > storage2/b.txt
date > cache/c.txt
#rm cache/c.txt
date > cache/c.txt
date > secret/auth
whoami

exit
```

Root access in any pod (hack): https://github.com/ssup2/kpexec

```bash
kubectl krew install pexec
kubectl get po -n kuard
kubectl pexec -n kuard -it kuard-7896b669bb-gjmtq -- sh
# repeat the above steps

# delete the pod (the pod, not the deployment!)
kubectl exec -n kuard -it deployment/kuard -- sh
# check the volume contents
```


## Helm

**jq** for JSON manipulation: https://stedolan.github.io/jq/ (https://jqplay.org/)  
**yq** for YAML manipulation: https://mikefarah.gitbook.io/yq/ (https://github.com/mikefarah/yq)

**kustomize** for YAML overlays (template-free patching): https://kustomize.io/  
How it works demo: https://speakerdeck.com/spesnova/introduction-to-kustomize  
Another tutorial: https://www.densify.com/kubernetes-tools/kustomize

```bash
kubectl apply -h
```

**helm** (v3) for YAML templating: https://helm.sh/  
Artifacthub for chart discovery: https://artifacthub.io/

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add harbor https://helm.goharbor.io
helm repo list
helm repo update

helm search hub mysql
helm search hub mysql --max-col-width 100
helm search hub mysql -o yaml  # get the repo URL here
helm search repo mysql
helm search repo mysql -o yaml
```

Create your own chart:

```bash
helm create kuard
cd kuard
```

Don't create a namespace even though it's tempting!

Add dependency charts in `Chart.yaml`:

```yaml
dependencies:
- name: redis
  version: "16.9.10"
  repository: "https://charts.bitnami.com/bitnami"
  condition: redis.enabled
```

```bash
helm dependency build
helm template .
helm template --release-name kuard .

helm lint .
helm package .

helm registry login
helm push . URL

helm pull bitnami/wordpress
```

Install existing charts:

```bash
helm show values .
helm install kuard .

helm show values bitnami/wordpress
helm template wordpress bitnami/wordpress -f some-my-values.yaml
helm template wordpress bitnami/wordpress --set some.value=asd
helm install wordpress bitnami/wordpress -f some-my-values.yaml
helm install wordpress bitnami/wordpress --set some.value=asd

helm list -n kuard
helm uninstall kuard
```

Fun fact: Nginx ingress controller install through helm: https://github.com/nginxinc/kubernetes-ingress/tree/main/deployments/helm-chart  
Inception/mind-blown: Ingress controller operator: https://github.com/nginxinc/nginx-ingress-helm-operator


## Cert manager

Nginx SSL management: https://kubernetes.github.io/ingress-nginx/user-guide/tls/  
Cert Manager guide with Let's Encrypt: https://cert-manager.io/docs/tutorials/acme/nginx-ingress/
