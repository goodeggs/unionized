# Changelog
All notable changes to this project will be documented in this file.
This project follows [SemVer 2.0.0](http://www.semver.org).


## 6.0.0

### Breaking
- dropped support for Node 4 and Node 6

## 5.0.0

### Breaking
- factories now generate negative numbers and integers

### Added
- Added support for JSON schema exclusive maximum

## 2.7.0

### Added
- Optionally define and instantiate factories synchronously with `.json()`
- Allow inheriting from multiple ancestors (not just parent)

## 2.6.0

### Added
- Ability to define factories that create objects with arrays. These arrays can
  be overridden in various ways (i.e., you can decide how long the array will be
  without specifying individual array items; you can override individual array
  indices or even subpaths within individual array indices). Optionally, the
  arrays can consist of other embedded factories.
- Independent from outside modules! Unionized no longer requires `lodash` or
  `dot-component`. This means that now you can browserify this module if you'd
  like.

### Deprecated
- Nothing.

### Removed
- Nothing.

### Fixed
- Now you can override an entire embedded factory!
