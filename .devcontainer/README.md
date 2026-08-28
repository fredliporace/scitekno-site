# Devcontainer

## Manual jekyll start 

```bash
.devcontainer/post-start.sh
```

```bash
.devcontainer/start-jekyll.sh
```

Check logs:

```bash
tail -f /tmp/jekyll.log
```

Stop Jekyll:

```bash
kill $(cat /tmp/jekyll.pid 2>/dev/null || true)
```
