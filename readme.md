A docker-compose configuration for running a phabricator server for development

## Setup
1. Clone this repository
2. Symlink `phabricator` and `arcanist` inside the repo folder
```
$ ln -s ../phabricator phabricator
$ ln -s ../arcanist arcanist
```
3. Start the containers
```
$ docker-compose up
```
4. Navigate to `http://localhost:8080`

