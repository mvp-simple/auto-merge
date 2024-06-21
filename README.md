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

| Key          | Explanation                                                       |
|--------------|-------------------------------------------------------------------|
| git.remote   | repository where the result will be stored                        |
| repositories | source repositories, and any nesting can be specified in the keys |

#### Initialization life cycle.

| # | Type  |                    | Explanation                 |
|---|-------|--------------------|-----------------------------|
| 1 | hook  | `_download_before` |                             |
| 2 | logic |                    | loading source repositories |
| 3 | hook  | `_download_after_` |                             |

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

| Key          | Explanation                                                                                                |
|--------------|------------------------------------------------------------------------------------------------------------|
| repositories | repositories sources from which updates will be downloaded, while any nesting can be specified in the keys |

#### Sync lifecycle.

| # | Type  |                         | Explanation                                                        |
|---|-------|-------------------------|--------------------------------------------------------------------|
| 1 | hook  | `_clean_pull_before`    | runs before all changes in the watched repositories are cleaned up |
| 2 | logic |                         | clean up all changes in watched repositories                       |
| 3 | hook  | `_clean_pull_after_`    | runs after clean up all changes in watched repositories            |
| 4 | hook  | `_vendor_folder_before` | runs before make-vendor-folder nested component runs               |
| 5 | logic |                         | run make-vendor-folder nested component                            |
| 6 | hook  | `_vendor_folder_after_` | runs after make-vendor-folder nested component runs                |
| 7 | hook  | `_push_result_before`   | runs before pushing final result                                   |
| 8 | logic |                         | pushing final result                                               |
| 9 | hook  | `_push_result_after_`   | runs after pushing final result                                    |

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

| Key               | Explanation                                               |
|-------------------|-----------------------------------------------------------|
| source_module     | name of the resulting package that will be used in go.mod |
| source_go_version | version of golang that will be used in go.mod             |

#### Dependency collector lifecycle.

| #  | Type  |                          | Explanation                                                         |
|----|-------|--------------------------|---------------------------------------------------------------------|
| 1  | hook  | `_gomod_before_prepare`  | runs before scanning go.mod in all directories of the result folder |
| 2  | logic |                          | scanning go.mod in all directories of the result folder             |
| 3  | hook  | `_gomod_after_prepared`  | runs after scanning go.mod in all directories of the result folder  |
| 4  | hook  | `_gosum_before_prepare`  | runs before scanning go.sum in all directories of the result folder |
| 5  | logic |                          | scanning go.sum in all directories of the result folder             |
| 6  | hook  | `_gosum_after_prepared`  | runs after scanning go.sum in all directories of the result folder  |
| 7  | hook  | `_vendor_before_replace` | runs before moving vendor folders nested in result folder           |
| 8  | logic |                          | moving vendor folders nested in result folder                       |
| 9  | hook  | `_vendor_after_replace_` | runs after moving the vendor folders nested in the result folder    |
| 10 | hook  | `_gomod_before_rename_`  | runs before renaming go.mod in the result subdirectories            |
| 11 | logic |                          | renaming go.mod files in the result subdirectories                  |
| 12 | hook  | `_gomod_after_renamed_`  | runs after renaming go.mod in the result subdirectories             |
| 13 | hook  | `_gosum_before_rename_`  | runs before renaming go.sum in the result subdirectories            |
| 14 | logic |                          | renaming go.sum files in the result subdirectories                  |
| 15 | hook  | `_gosum_after_renamed_`  | runs after renaming go.sum in the result subdirectories             |
| 16 | hook  | `_vendor_before_create`  | runs before creating the vendor directory                           |
| 17 | logic |                          | creating the vendor directory                                       |
| 18 | hook  | `_vendor_after_create_`  | runs after creating the vendor directory                            |

Hooks are searched for in the folder /scripts/hooks/make-vendor-folder.sh/

#### Start command.

```bash
./scripts/make-vendor-folder.sh
```

### Hooks.

#### Storage locations

| # | component                     | storage location                      |
|---|-------------------------------|---------------------------------------|
| 1 | initialization                | /scripts/hooks/init.sh/               |
| 2 | synchronization               | /scripts/hooks/sync.sh/               |
| 3 | creating the vendor directory | /scripts/hooks/make-vendor-folder.sh/ |

#### Forming hook names

Tooling searches for executable files (it itself gives them rights for executing) in storage locations.

These can be shell scripts, binary executable files, etc.

If several hooks are found, they are executed in alphabetical order.

The name of the hook files must begin with the name of the hook

For example, synchronization has a hook _rush_result_before, so in the folder /scripts/hooks/sync.sh/ when the event `_
push_result_before` is called, all files starting with **_push_result_before** will be searched

Example of a hook /scripts/hooks/sync.sh/_push_result_before_hello

```bash
#!/bin/bash
SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
echo "Hello i am a hook _push_result_before"
```