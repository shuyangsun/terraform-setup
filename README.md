# [new.startup](https://new.startup)

Creates everything you need for your exciting new startup, no coding experience
required.

## Getting Started

```bash
NEW_STARTUP_DIR="${HOME}/code/${USER}-new-startup" \
  && mkdir -p ${NEW_STARTUP_DIR} \
  && git clone https://github.com/shuyangsun/new-startup.git ${NEW_STARTUP_DIR} \
  && cd ${NEW_STARTUP_DIR} \
  && ./scripts/start.sh
```

## Contribution Guide

### Install Dependencies

```bash
git clone git@github.com:shuyangsun/new-startup.git \
  && cd ./new-startup \
  && ./scripts/internal/development/setup_dev.sh
```
