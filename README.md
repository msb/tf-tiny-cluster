This is a terraform module for the creation of a [GCP](https://cloud.google.com) kubernetes cluster.
The cluster is configured with only a single node and so isn't actually a cluster. However, it is
inexpensive to run and would be useful for:

- running non-mission critical applications
- learning to maintain aspects of a cluster

Some experience with GCP, Docker and Terrform would be useful when using this
resource.

You may already terraform installed but
[`terraform.sh`](https://github.com/msb/tf-tiny-cluster/blob/master/terraform.sh) allows you to use
a containerised version terraform whilst storing terraform init data in a volume, eg.
`terraform.sh $TF_VOLUME init`.

Before you can create a cluster you will need to create
[a GCP project](https://cloud.google.com/storage/docs/projects) to contain it.
[A Terraform repo](https://github.com/msb/tf-gcp-project) has been provided to automate this for
you. Follow the repo's README and when you have finished you should have two outputs
(`default.tf` and `service_account_credentials.json`) - create a another project folder and add
these files (along with `terraform.sh`, if using).

Then to deploy the cluster, add a `main.tf` file to this folder with the following configuration:

```tf
module "tiny_cluster" {
  source = "git::https://github.com/msb/tf-tiny-cluster.git"
}
```

Various parameters can be overridden. For instance, if you wish to give the cluster a name
different to "tiny-cluster":

```tf
module "tiny_cluster" {
  source       = "git::https://github.com/msb/tf-tiny-cluster.git"
  cluster_name = "different-name"
}
```

See the [`variables.tf`](https://github.com/msb/tf-tiny-cluster/blob/master/variables.tf) for the
possible parameters. Then to deploy the run the two standard
[terraform](https://www.terraform.io/docs/index.html) commands `init` and `apply`.

Once the cluster is created (it will take a few minutes) you will need to manage it - deploy
applications, etc. There are various ways to do this but our README only covers the CI `kubectl`.
You can use the
[`create-cluster-volume.sh`](https://github.com/msb/tf-tiny-cluster/blob/master/create-cluster-volume.sh)
script that wraps the TF `output` to create a docker volume with configuration for connecting your
`kubectl` as follows:

```sh
./create-cluster-volume.sh $TF_VOLUME
```

You can then use this volume in conjunction with the standard GCloud container
(which is built with `kubectl`):

```sh
docker run -it --rm -e HISTFILE=/cluster/.bash_history -v $TF_VOLUME-cluster:/cluster \
  google/cloud-sdk bash
```

Once in the container, connect `kubectl` to your cluster using the previously generated script:

```sh
/cluster/init.sh
# note that you will need to re-run this script every time you start the container
```

You should now be able to execute `kubectl` commands:

```sh
kubectl cluster-info
```

When it comes to deleting the cluster, you can do this by running:

```sh
terraform.sh $TF_VOLUME destroy
```
