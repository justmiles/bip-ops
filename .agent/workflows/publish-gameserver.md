---
description: Publish BipOps container image
---

1. Tag the build image to the registry image
// turbo
```bash
podman tag localhost/bip-ops:latest docker.io/justmiles/bip-ops:latest
```

2. Push the image to the registry
// turbo
```bash
podman push docker.io/justmiles/bip-ops:latest
```