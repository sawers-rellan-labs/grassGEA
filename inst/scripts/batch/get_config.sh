#!/usr/bin/env bash
yq ".$1 | envsubst" $GEA_CONFIG