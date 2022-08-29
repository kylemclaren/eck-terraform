# Installing ECK with Terraform on GCP

On this page you will find a how to spin up ECK using terraform. The main idea is to have a Kubernetes cluster and ECK installed by running only 3 commands.

## Demo
https://user-images.githubusercontent.com/16880741/164702566-aa2b0c7b-d92f-43bf-b41a-6929432ce1e3.mp4

## Features
_Every feature will be deployed via terraform_

- Install GKE (Google Kubernetes Enginee) cluster 
- It will contain 1 node pool with 3 nodes (One in each zone) running on region **europe-west1**
- It contains a helm provider that will be responsible to install the ECK operator
- Elasticsearch cluster with 3 nodes
- One Kibana instance with Load Balancer

## Requirements
Before starting you should have the following commands installed:

- [terraform](https://www.terraform.io/downloads)
- [gcloud](https://cloud.google.com/sdk/docs/install)

## Let's play
As you probably know, terraform is an infrastructure as code tool, which means we can describe our infrastructure desire into a file and apply it via terraform.
Here, we are going to spin up a GKE cluster with 3 nodes running on europe-west1 region, the machines we are going to use is **e2-standard-4** which will give us 4vCPU nad 16GB of memory in each node.

> **Note* We are using the Elastic Stack Helm Charts to deploy our Elasticsearch and Kibana resources. [ECK Stack Helm Charts](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-stack-helm-chart.html) are currently being released as an Enterprise licensed feature. When you run `terraform apply`, you will have the option to [start a new Enterprise subscription trial](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-licensing.html#k8s-start-trial) by typing `true`. If you have your own Enterprise license, you need to add it to the to the project root as a `license.json` file. Then, when asked if you'd like to start a trial, type `false`.

First, you have to authenticate into Google Cloud console, to so run the following command,

`gcloud auth application-default login`

Once you are logged it, you should export 2 variables, the Kubernetes config path AND the Google project you are going to use

`export KUBE_CONFIG_PATH=~/.kube/config && export GOOGLE_PROJECT=<YOUR-PROJECT-NAME>`

Now, you can run

`terraform init`

It will load the providers and configuration. Right after that, you should run

`terraform plan`

It will show you everything that will be created by terraform, take a moment to check this output.
Once you are ready, you just need to run:

`terraform apply -parallelism=1`

It will apply your changes in sequence.

Once everything was applied, you will get an output similar to this,

```
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

gke_name = "TO CONNECT TO KUBERNETES: gcloud container clusters get-credentials <KUBERNETES-NAME> --region europe-west1 --project <YOUR-PROJECT-NAME>"
kibana_endpoint = "TO CONNECT TO KIBANA: echo 'https://'$(kubectl get svc --namespace elastic-stack quickstart-kb-http --output jsonpath='{.status.loadBalancer.ingress[0].ip}')':5601'"
kubernetes_name = "fram-gke-eck"
```

## Wrapping up
Now, to clean up everything you just need to run

`terraform destroy`

Happy terraform!
