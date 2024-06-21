## Synchrophasotron golang 0.0.1

[![MIT license](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://opensource.org/licenses/MIT)

### Problems.

When developing code by multiple teams in one subject area, non-linear development occurs in its various
parts.

This phasing between different parts of the code leads to compatibility problems, which is the main pain
of technical support, bug engineering, and the DevOps team.

### Introduction.

Basically, code storage and versioning systems work based on git under the hood.

This tooling also uses git under the hood and provides automation of the creation and development of a monorepository.

### Components.

1. Initialization.
2. Synchronization

### Storage locations.

1. Configuration files ./scripts/config
2. Hooks ./scripts/hooks
3. Tooling ./scripts/tools

### Initialization.

#### Configuration is provided in ./scripts/config/init.sh.json

```json
{
    "git": {
    "remote": "git@github.com:mvp-simple/auto-merge-result.git"
    },
    "repositories": {
        "dauni-ml": "https://github.com/rinatusmanov/dauni-ml.git",
        "gg/dauni-ml": "https://github.com/rinatusmanov/dauni-ml.git",
        "jsonrpc20": "https://github.com/rinatusmanov/evgeniya.git"
    }
}
```

| Key | Explanation |
|--------------|---------------------------------------------------------------------------------|
| git.remote | repository where the result will be stored |
| repositories | source repositories, and any nesting can be specified in the keys |

#### Initialization life cycle.

| # | Type | | Explanation |
|---|--------|-----------------|--------------------------------|
| 1 | hook | download_before | |
| 2 | logic | | loading source repositories |
| 3 | hook | download_after | |

Hooks are searched for in the /scripts/hooks/init.sh/ folder

#### Launch command.

```bash
./scripts/init.sh
```

### Synchronization.

#### Configuration is provided in ./scripts/config/sync.sh.json

```json
{
    "repositories": [
    "dauni-ml",
    "gg/dauni-ml",
    "jsonrpc20"
    ]
}
```

| Key | Explanation |
|--------------|---------------------------------------------------------------------------------------------------------|
| repositories | repositories sources from which updates will be downloaded, while any nesting can be specified in the keys |

#### Sync lifecycle.

| # | Type | | Explanation |
|---|---------|-----------------------|---------------------------------------------------------------------|
| 1 | hook | _clean_pull_before | runs before all changes in the watched repositories are cleaned up |
| 2 | logic | | clean up all changes in watched repositories |
| 3 | hook | _clean_pull_after | runs after clean up all changes in watched repositories |
| 4 | hook | _vendor_folder_before | runs before make-vendor-folder nested component runs |
| 5 | logic | | run make-vendor-folder nested component |
| 6 | hook | _vendor_folder_after | runs after make-vendor-folder nested component runs |
| 7 | hook | _rush_result_before | runs before pushing final result |
| 8 | logic | | pushing final result |
| 9 | hook | _rush_result_after | runs after pushing final result |

Hooks are searched in the folder /scripts/hooks/sync.sh/

#### Launch command.

```bash
./scripts/sync.sh
```

### Dependency collector component.

#### Configuration is provided in ./scripts/config/make-vendor-folder.sh.json

```json
{
    "source_module": "github.com/rinatusmanov",
    "source_go_version": "1.18"
}
```

| Key | Explanation |
|-------------------|-------------------------------------------------------|
| source_module | name of the resulting package that will be used in go.mod |
| source_go_version | golang version that will be used in go.mod |

#### Dependency collector life cycle.

| # | Type | | Explanation |
|----|--------|------------------------|-------------------------------------------------------------------------|
| 1 | hook | _gomod_before_prepare | runs before scanning go.mod in all directories of the result folder |
| 2 | logic | | scanning go.mod in all directories of the folder