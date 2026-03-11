package mc

import (
	"testing"
	"time"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/giantswarm/apptest-framework/v3/pkg/state"
	"github.com/giantswarm/apptest-framework/v3/pkg/suite"
	"github.com/giantswarm/clustertest/v3/pkg/logger"
	appsv1 "k8s.io/api/apps/v1"
	"k8s.io/apimachinery/pkg/types"
)

const (
	isUpgrade        = false
	installNamespace = "mimir"
)

func TestMC(t *testing.T) {
	suite.New().
		WithInstallNamespace(installNamespace).
		WithIsUpgrade(isUpgrade).
		WithValuesFile("./values.yaml").
		WithHelmRelease(true).
		WithHelmTargetNamespace(installNamespace).
		AfterClusterReady(func() {
			It("should connect to the management cluster", func() {
				Expect(state.GetFramework().MC().CheckConnection()).To(Succeed())
			})
		}).
		Tests(func() {
			// Write path
			It("should have mimir-ingester statefulset ready on the MC", func() {
				mcClient := state.GetFramework().MC()
				Eventually(func() bool {
					logger.Log("Checking mimir-ingester statefulset")
					var sts appsv1.StatefulSet
					if err := mcClient.Get(state.GetContext(), types.NamespacedName{Namespace: installNamespace, Name: "mimir-ingester"}, &sts); err != nil {
						return false
					}
					return sts.Status.ReadyReplicas == *sts.Spec.Replicas
				}).WithPolling(5 * time.Second).WithTimeout(15 * time.Minute).Should(BeTrue())
			})

			It("should have mimir-distributor deployment ready on the MC", func() {
				mcClient := state.GetFramework().MC()
				Eventually(func() bool {
					logger.Log("Checking mimir-distributor deployment")
					var dep appsv1.Deployment
					if err := mcClient.Get(state.GetContext(), types.NamespacedName{Namespace: installNamespace, Name: "mimir-distributor"}, &dep); err != nil {
						return false
					}
					return dep.Status.ReadyReplicas == *dep.Spec.Replicas
				}).WithPolling(5 * time.Second).WithTimeout(15 * time.Minute).Should(BeTrue())
			})

			// Read path
			It("should have mimir-querier deployment ready on the MC", func() {
				mcClient := state.GetFramework().MC()
				Eventually(func() bool {
					logger.Log("Checking mimir-querier deployment")
					var dep appsv1.Deployment
					if err := mcClient.Get(state.GetContext(), types.NamespacedName{Namespace: installNamespace, Name: "mimir-querier"}, &dep); err != nil {
						return false
					}
					return dep.Status.ReadyReplicas == *dep.Spec.Replicas
				}).WithPolling(5 * time.Second).WithTimeout(15 * time.Minute).Should(BeTrue())
			})

			It("should have mimir-query-frontend deployment ready on the MC", func() {
				mcClient := state.GetFramework().MC()
				Eventually(func() bool {
					logger.Log("Checking mimir-query-frontend deployment")
					var dep appsv1.Deployment
					if err := mcClient.Get(state.GetContext(), types.NamespacedName{Namespace: installNamespace, Name: "mimir-query-frontend"}, &dep); err != nil {
						return false
					}
					return dep.Status.ReadyReplicas == *dep.Spec.Replicas
				}).WithPolling(5 * time.Second).WithTimeout(15 * time.Minute).Should(BeTrue())
			})

			It("should have mimir-query-scheduler deployment ready on the MC", func() {
				mcClient := state.GetFramework().MC()
				Eventually(func() bool {
					logger.Log("Checking mimir-query-scheduler deployment")
					var dep appsv1.Deployment
					if err := mcClient.Get(state.GetContext(), types.NamespacedName{Namespace: installNamespace, Name: "mimir-query-scheduler"}, &dep); err != nil {
						return false
					}
					return dep.Status.ReadyReplicas == *dep.Spec.Replicas
				}).WithPolling(5 * time.Second).WithTimeout(15 * time.Minute).Should(BeTrue())
			})

			// Long-term storage
			It("should have mimir-store-gateway statefulset ready on the MC", func() {
				mcClient := state.GetFramework().MC()
				Eventually(func() bool {
					logger.Log("Checking mimir-store-gateway statefulset")
					var sts appsv1.StatefulSet
					if err := mcClient.Get(state.GetContext(), types.NamespacedName{Namespace: installNamespace, Name: "mimir-store-gateway"}, &sts); err != nil {
						return false
					}
					return sts.Status.ReadyReplicas == *sts.Spec.Replicas
				}).WithPolling(5 * time.Second).WithTimeout(15 * time.Minute).Should(BeTrue())
			})

			It("should have mimir-compactor statefulset ready on the MC", func() {
				mcClient := state.GetFramework().MC()
				Eventually(func() bool {
					logger.Log("Checking mimir-compactor statefulset")
					var sts appsv1.StatefulSet
					if err := mcClient.Get(state.GetContext(), types.NamespacedName{Namespace: installNamespace, Name: "mimir-compactor"}, &sts); err != nil {
						return false
					}
					return sts.Status.ReadyReplicas == *sts.Spec.Replicas
				}).WithPolling(5 * time.Second).WithTimeout(15 * time.Minute).Should(BeTrue())
			})

			// Entry point
			It("should have mimir-gateway deployment ready on the MC", func() {
				mcClient := state.GetFramework().MC()
				Eventually(func() bool {
					logger.Log("Checking mimir-gateway deployment")
					var dep appsv1.Deployment
					if err := mcClient.Get(state.GetContext(), types.NamespacedName{Namespace: installNamespace, Name: "mimir-gateway"}, &dep); err != nil {
						return false
					}
					return dep.Status.ReadyReplicas == *dep.Spec.Replicas
				}).WithPolling(5 * time.Second).WithTimeout(15 * time.Minute).Should(BeTrue())
			})

			// Alerting
			It("should have mimir-ruler deployment ready on the MC", func() {
				mcClient := state.GetFramework().MC()
				Eventually(func() bool {
					logger.Log("Checking mimir-ruler deployment")
					var dep appsv1.Deployment
					if err := mcClient.Get(state.GetContext(), types.NamespacedName{Namespace: installNamespace, Name: "mimir-ruler"}, &dep); err != nil {
						return false
					}
					return dep.Status.ReadyReplicas == *dep.Spec.Replicas
				}).WithPolling(5 * time.Second).WithTimeout(15 * time.Minute).Should(BeTrue())
			})

			It("should have mimir-overrides-exporter deployment ready on the MC", func() {
				mcClient := state.GetFramework().MC()
				Eventually(func() bool {
					logger.Log("Checking mimir-overrides-exporter deployment")
					var dep appsv1.Deployment
					if err := mcClient.Get(state.GetContext(), types.NamespacedName{Namespace: installNamespace, Name: "mimir-overrides-exporter"}, &dep); err != nil {
						return false
					}
					return dep.Status.ReadyReplicas == *dep.Spec.Replicas
				}).WithPolling(5 * time.Second).WithTimeout(15 * time.Minute).Should(BeTrue())
			})
		}).
		Run(t, "Mimir MC test")
}
