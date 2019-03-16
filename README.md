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

### How to start tasks/pipelines

To run any task inside of this repository, [refer to the documentation](https://mottainaici.github.io/docs/usage/tasksandpipelines/), but it boils down to:

#### Tasks

To run a task defined in this repository, is sufficient to:

      mottainai-cli task create --yaml <task.yaml>

or, alternatively, if the task is defined in json, you can:

      mottainai-cli task create --json <task.json>

#### Pipelines

To run a task defined in this repository, is sufficient to:

      mottainai-cli pipeline create --yaml <pipeline.yaml>

or, alternatively, if the task is defined in json, you can:

      mottainai-cli pipeline create --json <pipeline.json>

#### Plans

Usually you don't need to load the plans manually, use replicant for this:

      git clone https://github.com/Sabayon/sbi-tasks tasks
      replicant environment deploy -e tasks
