# GIST - Government Interrogation Spending Tool

## Introduction

Visualisation tool for viewing government spending data.

## Requirements

* Ruby 1.9.3
* SASS
* Jekyll

## Running the application

To setup first clone the repo and run bunder to get the required gems:
> bundle install

Run the script to setup the GOV.UK styles taken from submodules:
> ./copy_govuk_styles.sh

Run a process script to generate template files from the raw csv data
files:
> ./process_test_data.sh
Or use files stored in _processor/data
> ./process_data.sh

Run Jekyll to generate the static html for the site:
> jekyll build
