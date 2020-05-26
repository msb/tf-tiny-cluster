This is a terraform repo for the creation of a [GCP](https://cloud.google.com) kubernetes cluster.
The cluster is configured with only a single node and so isn't actually a cluster. However, it is
inexpensive to run and would be useful for:

- running non-mission critical applications
- learning to maintain aspects of a cluster

Some experience with GCP, Docker, Terrform, and Kubernetes would be useful when using this
resource.

You may already terraform installed but `tf-gcp-cluster.sh` allows you to use a containerised
version terraform whilst storing terraform init data in a volume, eg.
`tf-gcp-cluster.sh $TF_VOLUME init`.

Before you can create a cluster you will need to create
[a GCP project](https://cloud.google.com/storage/docs/projects) to contain it.
[A Terraform repo](https://github.com/msb/tf-gcp-project) has been provided to automate this for
you. Follow the repo's README and when you have finished you should have two outputs
(`default.tf` and `service_account_credentials.json`) that should be copied to this repo.

Then to create the cluster:

- Copy locals.tf.in -> locals.tf (it should work fine without overriding any defaults).
- Run the two standard [terraform](https://www.terraform.io/docs/index.html) commands `init` and
  `apply`.

Once the cluster is created (it will take a few minutes) you will need to manage it - deploy
applications, etc. There are various ways to do this but our README only covers the CI `kubectl`.
You can use the `tf-gcp-cluster.kube.sh` script that wraps the TF `output` to create a docker
volume with configuration for connecting your `kubectl` as follows:

```sh
./tf-gcp-cluster.kube.sh $TF_VOLUME
```

You can then use this volume in conjunction with the standard GCloud container
(which is built with `kubectl`):

```sh
docker run -it --rm -e HISTFILE=/root/.kube/.bash_history -v $TF_VOLUME-kube:/root/.kube \
  google/cloud-sdk bash
```

Once in the container, connect `kubectl` to your cluster using the previously generated script:

```sh
/root/.kube/kube.sh
# note that you will need to re-run this script periodically as your connection times out
```

You should now be able to execute `kubectl` commands:

```sh
kubectl cluster-info
```

When it comes to deleting the cluster, you can do this by running:

```sh
tf-gcp-cluster.sh $TF_VOLUME destroy
```
