# Devcontainer

## Automatic Jekyll startup

Jekyll is started automatically when the container opens via `postStartCommand`.

## Manual start

```bash
bash .devcontainer/start-jekyll.sh
```

Check logs:

```bash
tail -f /tmp/jekyll.log
```

Stop Jekyll:

```bash
kill $(cat /tmp/jekyll.pid 2>/dev/null || true)
```
