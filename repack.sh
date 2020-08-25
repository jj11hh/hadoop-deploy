#!/bin/bash

cd ..
find ./deploy-usth -name '*.sh' -o -name '*.txt' | tar -czf deploy-usth.tar.gz -T -

