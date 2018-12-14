package ApiCommonWorkflow::Main::WorkflowSteps::ClinEpiMirrorRsync

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use warnings;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use XML::Simple; 

#TODO make generalizable so Mbio can use also

sub run{
    my ($self, $test, $undo) = @_;

    my $clinEpiModelXml = $ENV{PROJECT_HOME} . "/ClinEpiModel/Model/lib/wdk/clinEpiModel.xml";
    my $clinEpiModel = XMLin($clinEpiModelXml, keyattr=>[], ForceArray => 1);
    my $buildNumber;
    foreach(@{$clinEpiModel->{constant}}) {
      if ($_->{name} eq "buildNumber") {
        $buildNumber = $_->{content};
      }
    } 
    my $wfVersion = $self->getWorkflowConfig('version'); 

    #test buildNumber and wfVersion are set ?? TODO

    ## copy from Staging 
    if (-e "/eupath/data/apiSiteFiles/downloadSite/ClinEpiDB/release-$buildNumber/" ) {
      my $downloadSiteCmd = "rm -r /eupath/data/apiSiteFiles/downloadSite/ClinEpiDB/release-$buildNumber/ ; copyDownloadFilesFromStagingToReal.pl --projectName ClinEpiDB --workflowVersion $wfVersion --buildNumber $buildNumber";
    } else {
      my $downloadSiteCmd = "copyDownloadFilesFromStagingToReal.pl --projectName ClinEpiDB --workflowVersion $wfVersion --buildNumber $buildNumber";
    }
    my $webserviceCmd = "copyStagingFiles.pl --configFile $ENV{GUS_HOME}/config/stagingDirPaths.tab  --includeProjects ClinEpiDB --buildNumber $buildNumber"; 
   

    ## sync miror dir
    #webservice penn
    my $cmd = "/usr/local/bin/mrsync  \
  --exclude='.DATACLASS*' --exclude='.lsyncd_ignore' \
  --exclude='lost+found' --exclude='.repo' --exclude='*~'  \
  --delete --ignore-errors -gpvzsoltD \
  --require_mount=/eupath/data/apiSiteFiles \
  --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r  \
  --partial-dir=.rsync_partial \
  --log-format='%i %M %f -> localhost:/eupath/data/EuPathDB/apiSiteFilesMirror %b' \
  --hard-links --rsh='ssh \
  -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -p 22' \
  -r /eupath/data/apiSiteFiles/webServices/ClinEpiDB/ \
  localhost:/eupath/data/EuPathDB/apiSiteFilesMirror/webServices/ClinEpiDB/";

    #download penn
    my $cmd2 = "/usr/local/bin/mrsync  \
  --exclude='.DATACLASS*' --exclude='.lsyncd_ignore' \
  --exclude='lost+found' --exclude='.repo' --exclude='*~'  \
  --delete --ignore-errors -gpvzsoltD \
  --require_mount=/eupath/data/apiSiteFiles \
  --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r  \
  --partial-dir=.rsync_partial \
  --log-format='%i %M %f -> localhost:/eupath/data/EuPathDB/apiSiteFilesMirror %b' \
  --hard-links --rsh='ssh \
  -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -p 22' \
  -r /eupath/data/apiSiteFiles/downloadSite/ClinEpiDB/ \
  localhost:/eupath/data/EuPathDB/apiSiteFilesMirror/downloadSite/ClinEpiDB/";

    #webservice uga
    my $cmd3 = "/usr/local/bin/mrsync  --exclude='.DATACLASS*' --exclude='.lsyncd_ignore' \
  --exclude='lost+found' --exclude='.repo' --exclude='*~'  \
  --delete --ignore-errors -gpvzsoltD \
  --require_mount=/eupath/data/apiSiteFiles -\
  -chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r  \
  --partial-dir=.rsync_partial \
  --log-format='%i %M %f -> luffa:/var/www/Common/apiSiteFilesMirror/ %b' \
  --hard-links --rsh='ssh \
  -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -p 22' \
  -r /eupath/data/apiSiteFiles/webServices/ClinEpiDB/ \
  luffa.gacrc.uga.edu:/var/www/Common/apiSiteFilesMirror/webServices/ClinEpiDB";
  
    #download uga
    my $cmd4 = "/usr/local/bin/mrsync  --exclude='.DATACLASS*' --exclude='.lsyncd_ignore' \
  --exclude='lost+found' --exclude='.repo' --exclude='*~'  \
  --delete --ignore-errors -gpvzsoltD \
  --require_mount=/eupath/data/apiSiteFiles -\
  -chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r  \
  --partial-dir=.rsync_partial \
  --log-format='%i %M %f -> luffa:/var/www/Common/apiSiteFilesMirror/ %b' \
  --hard-links --rsh='ssh \
  -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -p 22' \
  -r /eupath/data/apiSiteFiles/downloadSite/ClinEpiDB/ \
  luffa.gacrc.uga.edu:/var/www/Common/apiSiteFilesMirror/downloadSite/ClinEpiDB/";



    if ($undo){
      #placeholder
    }else{
      $self->runCmd($test, $downloadSiteCmd);
      $self->runCmd($test, $webserviceCmd);
      $self->runCmd($test, $cmd);
      $self->runCmd($test, $cmd2);
      $self->runCmd($test, $cmd3);
      $self->runCmd($test, $cmd4);
    }
}

1;
