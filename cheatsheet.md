# Hints and tips to tune Mimir

Work in progress - most interesting tips should eventually land in README.

## Update user-config

- retrieve current user-config
```
k get cm -n giantswarm mimir-user-values -oyaml | yq '.data."mimir-user-values-gauss.yaml"' > mimir-user-values-gauss.yaml
```

- Apply new user-config
```
kubectl delete configmap mimir-user-values -n giantswarm 
kubectl create configmap mimir-user-values -n giantswarm --from-file=mimir-user-values-gauss.yaml
```

- Trigger redeploy
```
k -n giantswarm edit app mimir
# add an annotation
```

## fix store-gateways

Currently, store-gateways don't start because they try to write on read-only root directory.

Here are 2 possible workarounds. Proper fixes are not determined yet, we have to write an issue upstream.

### Option 1: add workdir volume

- `k edit sts -n mimir mimir-store-gateway-zone-a`
- set `workingDir: /data`

### Option 2: fix security policies

- `k edit sts -n mimir mimir-store-gateway-zone-a`
- set `readOnlyRootFilesystem: true` in container securitycontext
- remove `runAsGroup` and `runAsUser` from spec securitycontext

## Remotewrite

We provided a sample remotewrite that sends all data from all prometheis to Mimir.

`k apply -f sample_configs/mimir-remotewrite.yaml`

## Errors

Here are a few errors we observed during the tuning of Mimir.

### Rate-limiting:

`k logs -n gauss-prometheus prometheus-gauss-0  -f`

```
ts=2023-04-14T07:58:25.235Z caller=dedupe.go:112 component=remote level=error remote_name=mimir url=http://mimir-gateway.mimir.svc/api/v1/push msg="non-recoverable error" count=393 exemplarCount=0 err="server returned HTTP status 400 Bad Request: failed pushing to ingester: user=anonymous: per-user series limit of 150000 exceeded (err-mimir-max-series-per-user). To adjust the related per-tenant limit, configure -ingester.max-global-series-per-user, or contact your service administrator."
```

### Max labels:

`k logs -n gauss-prometheus prometheus-gauss-0  -f`

```
ts=2023-04-14T17:27:13.517Z caller=dedupe.go:112 component=remote level=error remote_name=mimir url=http://mimir-gateway.mimir.svc/api/v1/push msg="non-recoverable error" count=1000 exemplarCount=0 err="server returned HTTP status 400 Bad Request: received a series whose number of labels exceeds the limit (actual: 32, limit: 30) series: 'kyverno_policy_results_total{cluster_id=\"gauss\", cluster_type=\"management_cluster\", container=\"kyverno\", customer=\"giantswarm\",
endpoint=\"metrics-port\", installation=\"gauss\", instance=\"100.64.0.24:800' (err-mimir-max-label-names-per-series). To adjust the related per-tenant limit, configure -validation.max-label-names-per-series, or contact your service administrator.""}'"
```

## Debug

Mimir provides a status web interface that can be very convenient to spot which component is failing or to fix a broken ring.

Port-forward a querier:
```
k port-forward -n mimir mimir-querier-c9fc4c7f6-mnn5p 8080
```

on `localhost:8080` you can access:
- services status
- ring status - if ingesters changed name, `forget` the old ones
- memberlists - nice view of all components

## Config customizations

These are the config customizations that we did for our management clusters

### zoneAwareReplication

As we have 1 zone on our MCs, let's disable zoneAwareReplication:
- for `.mimir.ingester`
- for `.mimir.store_gateway`

    ```
    zoneAwareReplication:
      enabled: false
    ```

### Rate-limiting

Default `ingester.max-global-series-per-user=150000` results in rate-limiting.
We have to drasticaly increase it.

Default `max-label-names-per-series=30` is a bit too short.
- `distributor.ingestion-rate-limit` defaults to 10000 items/s
- `distributor.ingestion-burst-size` defaults to 200000

In `.mimir.ingester`:
```
extraArgs:
  ingester.max-global-series-per-user: 1500000
```

In `.mimir.distributor`:
```
extraArgs:
  validation.max-label-names-per-series: 40
  distributor.ingestion-rate-limit: 20000
  distributor.ingestion-burst-size: 400000
```
