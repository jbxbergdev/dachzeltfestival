#!/usr/bin/env bash

find . -name "*.inject.dart" -size 0 |xargs rm --
find . -name "*.inject.summary" |xargs rm --