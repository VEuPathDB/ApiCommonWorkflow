package ApiCommonWorkflow::Main::WorkflowSteps::MakeIsolateDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my @isolateExtDbSpecList = split(/,/,$self->getParamValue('isolateExtDbRlsSpec'));
  my $outputFile = $self->getParamValue('outputFile');

  my (@extDbRlsVers,@extDbNames);

  foreach ( @isolateExtDbSpecList ){
      my ($extDbName,$extDbRlsVer)=$self->getExtDbInfo($test,$_);
      push (@extDbNames,$extDbName);
      push (@extDbRlsVers,$extDbRlsVer);

  }

  my $extDbNameList = join(",", map{"'$_'"} @extDbNames);
  my $extDbRlsVerList = join(",",map{"'$_'"} @extDbRlsVers);

  my $sql = "SELECT
        enas.source_id
        ||' | organism='|| 
        replace(tn.name, ' ', '_')
        ||' | description='||
        decode (enas.description,null,$extDbNameList,enas.description)
        ||' | length='||
        enas.length
        as defline,
        enas.sequence
        From dots.ExternalNASequence enas,
             sres.taxonname tn,
             sres.externaldatabase ed,
             sres.externaldatabaserelease edr,
             dots.isolatesource i
        Where enas.taxon_id = tn.taxon_id
            AND tn.name_class = 'scientific name'
            AND enas.external_database_release_id = edr.external_database_release_id
            AND edr.external_database_id = ed.external_database_id
            AND ed.name in ($extDbNameList) AND edr.version in ($extDbRlsVerList)
            AND enas.na_sequence_id = i.na_sequence_id";

  my $cmd = " gusExtractSequences --outputFile $outputFile  --idSQL \"$sql\"";


  
  if ($undo) {
    #$self->runCmd(0, "rm -f $outputFile");
  }else{
      if ($test) {
	  $self->runCmd(0, "echo test > $outputFile");
      }else{
	  $self->runCmd($test, $cmd);
      }
  }

}

sub getParamsDeclaration {
  return (
          'outputFile',
          'isolateExtDbRlsSpec',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}
