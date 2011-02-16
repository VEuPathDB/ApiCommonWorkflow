package ApiCommonWorkflow::Main::WorkflowSteps::MakeESTDownloadFile;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);
use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;

sub run {
  my ($self, $test, $undo) = @_;

  # get parameters
  my $outputFile = $self->getParamValue('outputFile');
  my $parentNcbiTaxonId = $self->getParamValue('parentNcbiTaxonId');
  my $descripFile= $self->getParamValue('descripFile');
  my $descripString= $self->getParamValue('descripString');
  my $useTaxonHierarchy = $self->getParamValue('useTaxonHierarchy');

  my $taxonId = $self->getTaxonIdFromNcbiTaxId($test,$parentNcbiTaxonId);
  my $taxonIdList = $self->getTaxonIdList($test, $taxonId, $useTaxonHierarchy);

  my $sql = <<"EOF";
    SELECT x.source_id
           ||' | organism='||
           replace(tn.name, ' ', '_')
           ||' | length='||
           x.length as defline,
           x.sequence
           FROM dots.externalnasequence x,
                sres.taxonname tn,
                sres.taxon t,
                sres.sequenceontology so
           WHERE t.taxon_id in ($taxonIdList)
            AND t.taxon_id = tn.taxon_id
            AND tn.name_class = 'scientific name'
            AND t.taxon_id = x.taxon_id
            AND x.sequence_ontology_id = so.sequence_ontology_id
            AND so.term_name = 'EST'
EOF

  my $cmd = "gusExtractSequences --outputFile $outputFile  --idSQL \"$sql\"";
  my $cmdDec = "writeDownloadFileDecripWithDescripString --descripString '$descripString' --outputFile $descripFile";

  if($undo){
    #$self->runCmd(0, "rm -f $outputFile");
    #$self->runCmd(0, "rm -f $descripFile");
  }else{  
      if ($test) {
	  $self->runCmd(0, "echo test > $outputFile");
      }else {
	  $self->runCmd($test, $cmd);
	  $self->runCmd($test, $cmdDec);
      }
  }
}

sub getParamsDeclaration {
  return (
          'outputFile',
          'parentNcbiTaxonId',
          'useTaxonHierarchy',
         );
}

sub getConfigDeclaration {
  return (
         # [name, default, description]
         # ['', '', ''],
         );
}

