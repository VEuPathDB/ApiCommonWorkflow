package ApiCommonWorkflow::Main::WorkflowSteps::MakeDotsAssemblyDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $outputFile = $self->getParamValue('outputFile');
  my $ncbiTaxonId = $self->getParamValue('ncbiTaxonId');
  my $descripFile->getParamValue('descripFile');
  my $descripString->getParamValue('descripString');

  my $apiSiteFilesDir = $self->getSharedConfig('apiSiteFilesDir');

  my $sql = "
      SELECT  a.source_id
                ||' | organism='||
          replace(tn.name, ' ', '_')
                ||' | number of sequences='||
          a.number_of_contained_sequences
                ||' | length='||
          a.length as defline,
          a.sequence
       FROM dots.assembly a,
            sres.taxonname tn,
            sres.taxon t
      WHERE t.ncbi_tax_id = $ncbiTaxonId
        AND t.taxon_id = tn.taxon_id
        AND tn.name_class = 'scientific name'
        AND t.taxon_id = a.taxon_id";

  my $cmd = " gusExtractSequences --outputFile $apiSiteFilesDir/$outputFile  --idSQL \"$sql\"";
  my $cmdDec = "writeDownloadFileDecripWithDescripString --descripString '$descripString' --outputFile $apiSiteFilesDir/$descripFile";

  if($undo){
    $self->runCmd(0, "rm -f $apiSiteFilesDir/$outputFile");
    $self->runCmd(0, "rm -f $apiSiteFilesDir/$descripFile");
  }else{
      if ($test) {
	  $self->runCmd(0, "echo test > $apiSiteFilesDir/$outputFile");
      }else{
	  $self->runCmd($test, $cmd);
	  $self->runCmd($test, $cmdDec);
      }
  }

}

sub getParamsDeclaration {
  return (
          'outputFile',
          'ncbiTaxonId',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}

