# Build infrastructure tasks

![](https://media.giphy.com/media/l3vR6aasfs0Ae3qdG/giphy.gif)

*Plans* are special types of [tasks](https://mottainaici.github.io/docs/usage/tasksandpipelines/#tasks) marked by an extra field ( *planned* ) which is indicating in a cron-style syntax *when* a task is recurring.

*Plans* are triggered automatically from the build infrastructure, used typically to start nightly build pipelines for releasing ISOs, repository/package build, Docker images, Vagrant box generation, etc..

This repository is parsed by [Replicant](https://github.com/MottainaiCI/replicant) which deploys the master branch to the main Sabayon Build Infrastructure automatically.
