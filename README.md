# BuildYourOwnSinatra.com

The source for [https://buildYourOwnSinatra.com](https://buildYourOwnSinatra.com)

## Running

Rename .env_example to .env and then run:

```sh
$ bundle install
```

## Deploying

*Note*: Do not deploy this with the same design. Change the assets and the css.

You'll need three things;

1. Server with dokku-alt or Heroku
2. Redis
3. MongoDB

Before doing anything make sure rename .env_example to .env and edit the values to match your own.

### With Heroku

Run:

```sh
$ bundle exec mina heroku:setup
```

The mina script will setup redis, mongodb, and push the env vars.

Then push it:

```sh
$ git push heroku master
```

### Locally With Vagrant

First boot a vm with the vagrant file:

```sh
$ vagrant up
```

Once things have ran grab vagrant's ssh-config with `$ vagrant ssh-config` and place it into ~/.ssh/config.

Now edit nginx.conf to use your own vhost:

```nginx
server_name buildYourOwnSinatra.com;
```

Then setup things:

```sh
$ SERVER_USER=vagrant SERVER_DOMAIN=default bundle exec mina dokku:setup --port 2222
```

Finally add the remote and push it:

```sh
$ git remote add vagrant vagrant@default:build-your-own-sinatra
$ git push vagrant master
```

### With dokku-alt on Digital Ocean

First edit nginx.conf to use your own vhost:

```nginx
server_name buildYourOwnSinatra.com;
```

Set the SERVER_URL in .env and then run:

```sh
$ bundle exec mina
```

The script will setup the app, create database, push environment vars etc.

Now all you have to do is push:

```sh
$ git remote add dokku dokku@dokku-alt.com:build-your-own-sinatra
$ git push dokku master
```
