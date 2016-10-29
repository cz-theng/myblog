#!/usr/bin/env bash
rm -rf _config.yml node_modules package.json db.json  scaffolds
hexo init
git checkout -- _config.yml
rm -rf source/_posts/hello-world.md
