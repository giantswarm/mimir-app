import logging
from typing import List, Tuple

import pytest
import pykube
from pytest_helm_charts.clusters import Cluster
from pytest_helm_charts.k8s.deployment import wait_for_deployments_to_run
from pytest_helm_charts.k8s.stateful_set import wait_for_stateful_sets_to_run


logger = logging.getLogger(__name__)

namespace_name = "mimir"

# -- Mimir statefulsets
ingester_statefulset_name = "mimir-ingester"
store_gateway_statefulset_name = "mimir-store-gateway"
compactor_statefulset_name = "mimir-compactor"
chunks_cache_statefulset_name = "mimir-chunks-cache"

# -- Mimir deployments
distributor_deployment_name = "mimir-distributor"
gateway_deployment_name = "mimir-gateway"
querier_deployment_name = "mimir-querier"
query_frontend_deployment_name = "mimir-query-frontend"
query_scheduler_deployment_name = "mimir-query-scheduler"
ruler_deployment_name = "mimir-ruler"
overrides_exporter_deployment_name = "mimir-overrides-exporter"

timeout: int = 900

@pytest.mark.smoke
def test_api_working(kube_cluster: Cluster) -> None:
    """Very minimalistic example of using the [kube_cluster](pytest_helm_charts.fixtures.kube_cluster)
    fixture to get an instance of [Cluster](pytest_helm_charts.clusters.Cluster) under test
    and access its [kube_client](pytest_helm_charts.clusters.Cluster.kube_client) property
    to get access to Kubernetes API of cluster under test.
    Please refer to [pykube](https://pykube.readthedocs.io/en/latest/api/pykube.html) to get docs
    for [HTTPClient](https://pykube.readthedocs.io/en/latest/api/pykube.html#pykube.http.HTTPClient).
    """
    assert kube_cluster.kube_client is not None
    assert len(pykube.Node.objects(kube_cluster.kube_client)) >= 1

# scope "module" means this is run only once, for the first test case requesting! It might be tricky
# if you want to assert this multiple times
# -- Checking that mimir's deployments and statefulsets are present on the cluster
@pytest.fixture(scope="module")
def components(kube_cluster: Cluster) -> Tuple[List[pykube.Deployment], List[pykube.StatefulSet]]:
    logger.info("Waiting for mimir components to be deployed..")

    components_ready = wait_for_components(kube_cluster)

    logger.info("mimir components are deployed..")

    return components_ready

def wait_for_components(kube_cluster: Cluster) -> Tuple[List[pykube.Deployment], List[pykube.StatefulSet]]:
    deployments = wait_for_deployments_to_run(
        kube_cluster.kube_client,
        [distributor_deployment_name, gateway_deployment_name, querier_deployment_name, query_frontend_deployment_name, query_scheduler_deployment_name, ruler_deployment_name, overrides_exporter_deployment_name],
        namespace_name,
        timeout,
    )
    statefulsets = wait_for_stateful_sets_to_run(
        kube_cluster.kube_client,
        [ingester_statefulset_name, store_gateway_statefulset_name, compactor_statefulset_name, chunks_cache_statefulset_name],
        namespace_name,
        timeout,
    )
    return (deployments, statefulsets)

@pytest.fixture(scope="module")
def pods(kube_cluster: Cluster) -> List[pykube.Pod]:
    pods = pykube.Pod.objects(kube_cluster.kube_client)

    pods = pods.filter(namespace=namespace_name, selector={
                       'app.kubernetes.io/name': 'mimir', 'app.kubernetes.io/instance': 'mimir'})

    return pods

# when we start the tests on circleci, we have to wait for pods to be available, hence
# this additional delay and retries
# -- Checking that all pods from mimir's deployments and statefulsets are available (i.e in "Ready" state)
@pytest.mark.smoke
@pytest.mark.upgrade
@pytest.mark.flaky(reruns=5, reruns_delay=10)
def test_pods_available(components: Tuple[List[pykube.Deployment], List[pykube.StatefulSet]]):
    # loop over the list of deployments
    for d in components[0]:
        assert int(d.obj["status"]["readyReplicas"]) == int(d.obj["spec"]["replicas"])

    # loop over the list of statefulsets
    for s in components[1]:
        assert int(s.obj["status"]["readyReplicas"]) == int(s.obj["spec"]["replicas"])
