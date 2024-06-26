# Changelog

All notable changes to [Dredd](https://github.com/Prakti/dredd) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.2] - 2024-04-20

### Changed

- Extend tests
- Upgrade library dependencies
- Narrow compatibility tests to Elixir versions 1.15 and 1.16 and OTP versions 24, 25 and 26

## [2.0.1] - 2023-01-01

### Fixed

- Fix exception when using map-validator with structs

## [2.0.0] - 2022-12-28

### Breaking Changes

This is a complete rewrite from the structure inherited by Justify. There are two reasons for the overhaul:
- I have a need for more deeply nested datastructures and needed the more verbose errors to keep output manageable.
- I wanted to improve the composability of validators. As it were, the architecture looked a bit lopsided.

