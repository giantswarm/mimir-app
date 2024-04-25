# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Add resources requests for the gateway.
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

[Unreleased]: https://github.com/giantswarm/mimir-app/compare/v0.5.0...HEAD
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
