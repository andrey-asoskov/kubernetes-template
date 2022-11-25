#!/usr/bin/env bash

kind create cluster --config ./Single.yaml 
kind delete cluster
