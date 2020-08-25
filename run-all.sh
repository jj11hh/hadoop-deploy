#!/bin/sh

ssh master "cd $HOME/deploy-usth; $1"
ssh slave1 "cd $HOME/deploy-usth; $1"
ssh slave2 "cd $HOME/deploy-usth; $1"
