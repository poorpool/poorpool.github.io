#!/bin/bash
hexo clean && hexo g && hexo d
git add .
git commit -m "ddd"
git push origin master:hexo
