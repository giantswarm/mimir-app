# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Add `ScaledObjects` resources templates for the `querier`, the `distributor` and the `gateway`.

## [0.17.0] - 2025-04-14

### Changed

- Upgrade chart to version [5.7.0](https://github.com/grafana/mimir/blob/main/operations/helm/charts/mimir-distributed/CHANGELOG.md#570)
- Upgrade mimir to [2.16.0](https://github.com/grafana/mimir/blob/main/CHANGELOG.md#2160)

## [0.16.0] - 2025-01-16

### Changed

- Upgrade chart to version 5.6.0
  - Add the possibility to create a dedicated serviceAccount for the alertmanager component by setting alertmanager.serviceAcount.create to true in the values.
  - Add support for setting type and internal traffic policy for Kubernetes service. Set internalTrafficPolicy=Cluster by default in all services with type ClusterIP.
  - more at https://github.com/grafana/mimir/blob/mimir-distributed-5.6.0/operations/helm/charts/mimir-distributed/CHANGELOG.md#560
- Upgrade mimir to 2.15.0
  - Ingester: Change -initial-delay for circuit breakers to begin when the first request is received, rather than at breaker activation.
  - Query-frontend: apply query pruning before query sharding instead of after.
  - Ingester: Replace cortex_discarded_samples_total label from sample-out-of-bounds to sample-timestamp-too-old.
  - Querier: The `.` pattern in regular expressions in PromQL matches newline characters. With this change regular expressions like `.*` match strings that include `\n`. To maintain the old behaviour, you will have to change regular expressions by replacing all `.` patterns with `[^\n]`, e.g. `foo[^\n]*`. This upgrades PromQL compatibility from Prometheus 2.0 to 3.0. #9844
  - Ingester: improve performance of reading the WAL.
  - Querier: improve performance and memory consumption of queries that select many series.
  - more at https://github.com/grafana/mimir/blob/main/CHANGELOG.md#2150

## [0.15.1] - 2025-01-14

### Removed

- Remove mimir datasource as it is now managed by the observability operator.

## [0.15.0] - 2024-12-10

### Added

- Add "manual e2e" testing procedure.

### Changed

- Add configuration for alertmanager component to be HA.

## [0.14.0] - 2024-10-14

### Changed

- Upgrade chart to version `5.5.0` and mimir 2.14.0.
  -  Memcached: Update to Memcached 1.6.31-alpine and memcached-exporter 0.14.4.
  -  Ingester: set GOMAXPROCS to help with Go scheduling overhead when running on machines with lots of CPU cores.
  -  Add missing container security context to run `continuous-test` under the restricted security policy.

## [0.13.1] - 2024-10-09

### Fixed

- Fix circleci config.

## [0.13.0] - 2024-09-04

### Added

- Add helm chart templating test in ci pipeline.
- Add tests with ats in ci pipeline.

## [0.12.0] - 2024-08-19

### Added

- Add vpa resource template for the chunks cache.

## [0.11.1] - 2024-08-07

### Fixed

- Fix indentation of jsonData in datasource.

## [0.11.0] - 2024-07-25

### Added

- Add vpa resource template for the ingester.

### Changed

- Bump mimir version from datasource.

## [0.10.1] - 2024-07-22

### Fixed

- fix grafana/mimir datasource

## [0.10.0] - 2024-07-18

### Added

- Add datasource configmap template.

## [0.9.0] - 2024-07-16

### Changed

- Upgraded the chart to 5.4.0 and mimir to 2.13.0

## [0.8.1] - 2024-07-11

### Fixed

- Deploy `PriorityClass` manifest only if `mimir` is enabled.

## [0.8.0] - 2024-07-10

### Added

- Add `priorityClass` template for the ingester.

## [0.7.0] - 2024-07-08

### Changed

- Push mimir to onprem collections.
- Add PVC retention policy for `compactor` and `store-gateway`.

## [0.6.3] - 2024-06-25

### Fixed

- fix schema for `mimir.ingester.resources.requests.cpu` property.

## [0.6.2] - 2024-06-25

### Fixed

- fix querier HPA by removing `scaleTargetRef.metrics` property.

### Changed

- Push to `capz-app-collection`

## [0.6.1] - 2024-06-06

### Changed

- Raise ingester resources requests.

## [0.6.0] - 2024-05-13

### Changed

- Add resources requests for the gateway.
- Add hpa resource and enable it by default for the querier and the distributor.
- Enable hpa for the gateway.

## [0.5.0] - 2024-04-17

### Changed

- Upgrade mimir chart to 5.3.0 and mimir to 2.12.0

## [0.4.3] - 2024-02-28

### Changed

- Added a default scrape interval value of 30s for service monitors (if they're used).

## [0.4.2] - 2024-02-13

### Changed

- Upgrade to latest weekly build to be able to use our upstream fixes (custom service account for the ruler, psp fix).
- Remove customized rbac and use upstream one.

## [0.4.1] - 2024-01-25

### Changed

- Change registry from `docker.io` to `gsoci.azurecr.io`
- Add condition for additional rbac.

## [0.4.0] - 2024-01-24

### Added

- Add an additional template for capi related rbac authorizations.

### Changed

- Upgrade mimir chart to 5.2.1

## [0.3.1] - 2024-01-16

### Fixed

- Removed unnecessary dns service as it is now in the upstream chart.

## [0.3.0] - 2024-01-15

### Changed

- Upgraded mimir to 2.11.0

### Added

- Add `mimir.enabled` condition for chart dependency.

## [0.2.0] - 2023-06-02

### Added

- Add `ruler.extraArgs` to the values to allow setting arguments to the ruler component.

## [0.1.1] - 2023-06-01

### Changed

- Upgraded the chart to 4.5.0 and mimir to 2.8.0
- Customized chart values.

### Added

- Circleci jobs to push `mimir` to all app collections.
- Values schema in helm chart.
- Sample config values.
- kube-dns svc pointing towards coredns for mimir-gateway

## [0.1.0] - 2023-04-06

### Changed

- changed: `app.giantswarm.io` label group was changed to `application.giantswarm.io`
- First release

[Unreleased]: https://github.com/giantswarm/mimir-app/compare/v0.17.0...HEAD
[0.17.0]: https://github.com/giantswarm/mimir-app/compare/v0.16.0...v0.17.0
[0.16.0]: https://github.com/giantswarm/mimir-app/compare/v0.15.1...v0.16.0
[0.15.1]: https://github.com/giantswarm/mimir-app/compare/v0.15.0...v0.15.1
[0.15.0]: https://github.com/giantswarm/mimir-app/compare/v0.14.0...v0.15.0
[0.14.0]: https://github.com/giantswarm/mimir-app/compare/v0.13.1...v0.14.0
[0.13.1]: https://github.com/giantswarm/mimir-app/compare/v0.13.0...v0.13.1
[0.13.0]: https://github.com/giantswarm/mimir-app/compare/v0.12.0...v0.13.0
[0.12.0]: https://github.com/giantswarm/mimir-app/compare/v0.11.1...v0.12.0
[0.11.1]: https://github.com/giantswarm/mimir-app/compare/v0.11.0...v0.11.1
[0.11.0]: https://github.com/giantswarm/mimir-app/compare/v0.10.1...v0.11.0
[0.10.1]: https://github.com/giantswarm/mimir-app/compare/v0.10.0...v0.10.1
[0.10.0]: https://github.com/giantswarm/mimir-app/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.com/giantswarm/mimir-app/compare/v0.8.1...v0.9.0
[0.8.1]: https://github.com/giantswarm/mimir-app/compare/v0.8.0...v0.8.1
[0.8.0]: https://github.com/giantswarm/mimir-app/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/giantswarm/mimir-app/compare/v0.6.3...v0.7.0
[0.6.3]: https://github.com/giantswarm/mimir-app/compare/v0.6.2...v0.6.3
[0.6.2]: https://github.com/giantswarm/mimir-app/compare/v0.6.1...v0.6.2
[0.6.1]: https://github.com/giantswarm/mimir-app/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/giantswarm/mimir-app/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/giantswarm/mimir-app/compare/v0.4.3...v0.5.0
[0.4.3]: https://github.com/giantswarm/mimir-app/compare/v0.4.2...v0.4.3
[0.4.2]: https://github.com/giantswarm/mimir-app/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/giantswarm/mimir-app/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/giantswarm/mimir-app/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/giantswarm/mimir-app/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/giantswarm/mimir-app/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/giantswarm/mimir-app/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/giantswarm/mimir-app/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/giantswarm/mimir-app/releases/tag/v0.1.0
