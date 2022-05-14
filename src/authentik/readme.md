### Authentik setup
1. Fill out missing values in `.env` - use the full domain for `AUTHENTIK_DOMAIN` and use `pwgen` with `sudo apt install pwgen` to simplify creating `PG_PASS` and `AUTHENTIK_SECRET_KEY`.
1. Wait a minute or two for `caddy-docker-proxy` to see the Authentik container, issue a cert, and do whatever else it needs to do.
1. Navigate to `https://${AUTHENTIK_DOMAIN}/if/flow/initial-setup` to create the admin account.

### Using Authentik
- Go to `Directory/Users` in the Authentik sidebar to create users.
- Create a provider to integrate with other services. All information you need to integrate should be located within the provider itself; the application is only secondary.