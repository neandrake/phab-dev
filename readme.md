A docker-compose configuration for running a phabricator server for development

## Setup
1. Clone this repository
2. Modify the `.env` file to set desired variables
  - The `INSTALLDIR` variable should generally not be changed, it's the location within the container where phabricator/arcanist will be installed to.
  - The `HOST` variable is the hostname for phabricator to be hosted on. Phabricator requires something with a `.` so this cannot be `localhost`. Pro-tip: do not use `something.dev` as the `.dev` TLD is a valid domain and browsers will likely force loading using HTTPS instead of HTTP.
  - The `PORT` variable is the port to be exposed on the host, in case other services are running or you don't want to use the default port 80.
3. Modify the `conf/local.json` file to configure for your setup
  - Items above the blank line should generally not need configured. JSON does not support comments otherwise this would be indicated directly in the file.
  - Update `phabricator.timezone` to match your current/local timezone. The value for this should be a valid PHP time zone.
3. Symlink `phabricator` and `arcanist` inside the repo folder
```
$ ln -s ../phabricator phabricator
$ ln -s ../arcanist arcanist
```
4. Start the containers. The first time this runs the container image will be built.
```
$ docker-compose up
```
5. Modify local `/etc/hosts` and add `127.0.0.1 phabricator.test`
6. Navigate to `http://phabricator.test`
7. Address outstanding setup issues such as configuring an Auth Provider
  - These setup issues can be ignored since this is only intended for local development:
    - Alternate File Domain Not Configured
    - Mailers Not Configured
8. You will probably want to register a new account while remaining logged in as the initial admin. The initial admin account does not have a password. The only way to set a password for this admin account requires sending email, which this development environment does not have configured.
  - Pro tip: You can lower the minimum password length by changing `account.minimum-password-length` setting.

If you need to modify the `.env` file after the first time running `docker-compose up` you will need to re-build using `docker-compose build --no-cache`.
