# Build infrastructure tasks

<p align="center">
  <img src="https://media.giphy.com/media/l3vR6aasfs0Ae3qdG/giphy.gif" alt=""/>
</p>

## Repository content

We collect here [Tasks and pipelines](https://mottainaici.github.io/docs/usage/tasksandpipelines/) used by the build infrastructure.

### Automation

In this repository are also stored Plans, that automate execution of specific tasks.

[Plans](https://mottainaici.github.io/docs/usage/plans/) are special types of tasks marked by an extra field ( *planned* ) which is indicating in a cron-style syntax *when* a task is recurring.

They are triggered automatically from the build infrastructure, used typically to start nightly build pipelines for releasing ISOs, repository/package build, Docker images, Vagrant box generation, etc..

This repository is parsed by [Replicant](https://github.com/MottainaiCI/replicant) which deploys the master branch to the main Sabayon Build Infrastructure automatically.

### Tasks from Makefile

```bash
$# make help
=====================================================================
 Sabayon Infra Tasks
=====================================================================
docker-mottainai      Create tasks for build Mottainai Docker images.
validate              Run replicant validation.
deploy                Run replicant ensure.
webhooks              Update Mottainai WebHooks.
kernel-tracker        Create task for Kernel bumps.
tasks                 Create all tasks YAML files (from templates).
mottainai-ebuild-tag  Create Mottainai ebuild tags from develop.
bump-atom             Bump atom to our overlay. Default sabayon-distro.
tag-server            TBD
repo-remove-pkgs      Create task for remove packages from a specific
                      repository. (Only ARM for now).
repo-create-pkgs      Create task for force compilation of the packages
                      related to a specific stage and repo.
                      (Only ARM for now).
scr-tasks             Create all tasks YAML files (from templates) for 
                      SCR repos.
repo-compare-pkgs     Compare pkgs of repository with build files definition.
repo-compare-bins     Compare pkgs under binhost directory with build files
                      definition.
```

#### Compare a specific repository with target build mission

```bash

$# REPOSITORY=core make repo-compare-pkgs
...
```

#### Compare a specific repository with binhost files not available as targets

```bash

$# REPOSITORY=core make repo-compare-bins
...
```

#### Drop packages from a repository

```bash

$# REPOSITORY=base PKGS="dev-lang/spidermonkey-52.9.1_pre1" make repo-remove-pkgs 
Removing pkgs dev-lang/spidermonkey-52.9.1_pre1 from repo base (arm)...
wrote 3220 bytes
-------------------------
Task 2667161879618085149 has been created
-------------------------
Live log:  mottainai-cli task attach 2667161879618085149
Information:  mottainai-cli task show 2667161879618085149
URL:  https://mottainai.sabayon.org/tasks/display/2667161879618085149
Build Log:  https://mottainai.sabayon.org/artefact/2667161879618085149/build_2667161879618085149.log
-------------------------
```
| Env Variable | Default | Description |
|--------------|---------|-------------|
| TASK_LXD | 1 | Run task inside LXD executor |
| TASK_QUEUE | - | Override default Task Queue. For example for run task to a specific node. |
| FILTER_BINHOST_ARTEFACTS | - | Clean repository binhost directory and remove packages filtered. By default only report is created. |
| REPO_ARCH | arm | Choice architecture of the task. |

### Force compilation of a list of packages for a repository

```bash
$# REPOSITORY=core PKGS=sys-devel/gcc STAGING_PHASE=staging1 make repo-create-pkgs
Force compilation of pkgs sys-devel/gcc to repo core (arm-staging1)...
wrote 2123 bytes
```

There are additional options available:

| Env Variable | Default | Description |
|--------------|---------|-------------|
| TASK_LXD | 1 | Run task inside LXD executor |
| TASK_QUEUE | - | Override default Task Queue. For example for run task to a specific node. |
| OVERRIDE_BUILDER_JOBS | - | Permit to override sark `jobs` option. For task where compilation is very long you need override default value to 1 to disable quiet mode. |
| STAGING_PHASE | - | Choice target staging namespace. |

### How to start tasks/pipelines

To run any task inside of this repository, [refer to the documentation](https://mottainaici.github.io/docs/usage/tasksandpipelines/), but it boils down to:

#### Tasks

To run a task defined in this repository, is sufficient to:

      mottainai-cli task create --yaml <task.yaml>

or, alternatively, if the task is defined in json, you can:

      mottainai-cli task create --json <task.json>

#### Pipelines

To run a pipeline defined in this repository, is sufficient to:

      mottainai-cli pipeline create --yaml <pipeline.yaml>

or, alternatively, if the task is defined in json, you can:

      mottainai-cli pipeline create --json <pipeline.json>

#### Plans

Usually you don't need to load the plans manually, use replicant for this:

      git clone https://github.com/Sabayon/sbi-tasks tasks
      replicant environment deploy -e tasks
