# EKS mocking vs real emulation

## Step 1: mocking EKS APIs

Start up LocalStack with:
```
$ PROVIDER_OVERRIDE_EKS=mock DEBUG=1 localstack start
```

Deploy the TF stack:
```
$ tflocal apply
```

Get the cluster information:
```
$ awslocal eks list-clusters
$ awslocal eks describe-cluster --name cluster1
```

## Step 2: running app in actual Kubernetes cluster

Restart LocalStack with default settings:
```
$ PROVIDER_OVERRIDE_EKS=mock DEBUG=1 localstack start
```

Redeploy the TF stack (creates a local kube cluster):
```
$ tflocal apply
```

Deploy the Kube application (nginx server)
```
$ (cd kube_app; tflocal apply)
```

Query the nginx endpoint via:
```
$ curl localhost:8081/app1
```
