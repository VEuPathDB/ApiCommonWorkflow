package ApiCommonWorkflow::Main::GetProjects;

use strict;

# get all the projects required by for the api common backend

# NOTE: this should be driven off of build.xml.   this file is a stopgap till we get a chance to do that.

sub getProjects {
  return ('ApiCommonData:apidb', 'ApiCommonModel:apidb', 'ApiCommonWorkflow:apidb', 'CBIL:gus', 'DoTS:apidb', 'FgpUtil:gus', 'GGTools:apidb', 'GusAppFramework:gus', 'GusSchema:gus', 'TuningManager:gus', 'install:gus', 'ReFlow:gus', 'WDK:gus', 'WSF:gus');
}

sub getClusterProjects {
  return ('CBIL:gus', 'GGTools:apidb', 'install:gus', 'DJob:gus');
}

1;
