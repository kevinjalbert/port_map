# PortMap

[![Gem Version](https://badge.fury.io/rb/port_map.svg)](https://badge.fury.io/rb/port_map)
[![Build Status](https://travis-ci.org/kevinjalbert/port_map.svg?branch=master)](https://travis-ci.org/kevinjalbert/port_map)
[![Code Climate](https://codeclimate.com/github/kevinjalbert/port_map/badges/gpa.svg)](https://codeclimate.com/github/kevinjalbert/port_map)
[![Test Coverage](https://codeclimate.com/github/kevinjalbert/port_map/badges/coverage.svg)](https://codeclimate.com/github/kevinjalbert/port_map/coverage)


During web development you are constantly running/starting/stoping local web servers. This isn't a huge problem when dealing with a single web server. As you run more web servers at the same time (i.e., microservices) the complexity jumps as you have to manually account for the ports each will be running on. This gem aims at simplifying the managment of web servers as well as exposing named domains for each web server. In addition, it takes advantage of nginx as the underlying web server.

## Example Scenario

### The Setup
You are developing a service that uses multiple web servers. You have two rails applications and one ember application.

| Application | Directory | Command | Local URL |
|-------------|-----------|---------|-----------|
Rails API | `/api/` | `rails server` | http://localhost:3000
Rails Background Jobs | ``/jobs/`` | `rails server --port 3001` | http://localhost:3001
Ember Application | `/ember/` | `ember server` | http://localhost:4200

### The Problem
In each of these applications there is some configuration work required to ensure that they communicate on the correct ports. There are two issues here:

- As we add more web servers we have to avoid clashing on existing ports.
- You have to make sure that you correctly start each server with the right port number.

### `port_map` to the Rescue!
We're going to transform this unwieldly scenario into an organized and easy to manage one using `port_map`.

| Application | Directory | Command | Local URL |
|-------------|-----------|---------|-----------|
Rails API | `/api/` | `port_map rails server` | http://api.dev
Rails Background Jobs | ``/jobs/`` | `port_map rails server` | http://jobs.dev
Ember Application | `/ember/` | `port_map ember server` | http://ember.dev

The domain names can be configured with environment variables, but by default they are based on the directory's name.

You can close and restart each web server multiple times and they will continue to use the same domain names. `port_map` provides an easy way to logically name each web server, as well as remove the need of specifying ports.

## Assumptions and Dependencies

1. You have the nginx web server installed
2. You are able to run nginx with sudo (this is required as we're listening on the protected port 80)
3. You have `include servers/*;` within your `nginx.conf` within the `http` block
4. (optional) Allow nginx command to be ran without password prompt (add command to sudoers via `visudo`)

## Installation

```
gem install port_map
```

## Commands
Installing this gem provides four executable commands:

### `create_port_map`
- `create_port_map 3000`
  - _Add proxy mapping http://127.0.0.1:3000/ to http://directory_name.dev_
  1. A generated nginx configuration is created under nginx's servers directory (`/usr/local/etc/nginx/servers/directory_name.port_map.conf`).
  2. Update `/etc/hosts` with new entry `127.0.0.1 directory_name.dev #port_map`.
  3. Reloads nginx -- `sudo nginx -s reload`.
- `create_port_map 3000 <specified_name>`
  - _Add proxy mapping http://127.0.0.1:3000/ to http://specified_name.dev_
  1. A generated nginx configuration is created under nginx's servers directory (`/usr/local/etc/nginx/servers/specified_name.port_map.conf`).
  2. Update `/etc/hosts` with new entry `127.0.0.1 specified_name.dev #port_map`.
  3. Reloads nginx -- `sudo nginx -s reload`.

### `list_port_maps`
- `list_port_maps`
  - List a parsable JSON payload of the current port maps that are managed.
```
[
  {
    "name": "api",
    "nginx_conf": "/usr/local/etc/nginx/servers/api.port_map.conf",
    "server_name": "api.dev",
    "locations": [
      {
        "name": "/",
        "proxy_pass": "http://127.0.0.1:3000"
      }
    ]
  }
]
```

### `remove_port_map`
- `remove_port_map <specified_name>`
  - _Removed proxy mapping of specified_name.dev/ to http://127.0.0.1:3000_
  1. Removes the nginx config generated from `create_port_map`.
  2. Removes the hosts entry generated from `create_port_map`.
  3. Reloads nginx -- `sudo nginx -s reload`.

### `port_map`
- `port_map <command>`
  1. Adjusts/Adds a dynamic port number on command (assuming command takes `-p <number>` or `--port <number>`).
  2. Executes `create_port_map <dynamic_port_number>`, which goes through the following in order until a name can be determined).
    1. Uses a `.port_map.conf` nginx server configuration (which has a server name and `$PORT` placeholder present), this then becomes the nginx configuration.
    2. Using a name specified in the `PORT_MAP_NAME` environment variable, this name is then used to generate a nginx configuration.
    3. Using a name specified from the current directory, this name is then used to generate a nginx configuration.
  3. Updates `/etc/hosts` with new entry `127.0.0.1 determined_name.dev #port_map`.
  4. Reloads nginx -- `sudo nginx -s reload`.
  5. Executes `<command>`.
  6. Executes `remove_port_map <determined_name>`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kevinjalbert/port_map. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
