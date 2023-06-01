# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2023-06-01

## [0.1.1] - 2023-06-01

- Upgraded the chart to 4.5.0 and mimir to 2.8.0

### Changed

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

[Unreleased]: https://github.com/giantswarm/mimir-app/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/giantswarm/mimir-app/compare/v0.1.1...v0.1.1
[0.1.1]: https://github.com/giantswarm/mimir-app/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/giantswarm/mimir-app/releases/tag/v0.1.0
