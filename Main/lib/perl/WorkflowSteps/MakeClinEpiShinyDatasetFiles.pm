package ApiCommonWorkflow::Main::WorkflowSteps::MakeClinEpiShinyDatasetFiles;

@ISA = (ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep);

use strict;
use ApiCommonWorkflow::Main::WorkflowSteps::WorkflowStep;
use ApiCommonData::Load::OwlReader;

use Digest::SHA qw(sha1_hex); 

sub run {
  my ($self, $test, $undo) = @_;

  my $outputFileBaseName = $self->getParamValue('outputFileBaseName');

  my $datasetName = $self->getParamValue('datasetName');

  my $owlFile = $self->getParamValue('owlFile');

  my $tblPrefix = "D" . substr(sha1_hex($datasetName), 0, 10);

  my $shinyHouseholdsSql = "select ha.name as household, ha.*
from apidbtuning.${tblPrefix}Households ha
   , apidbtuning.${tblPrefix}Participants pa
   , apidbtuning.${tblPrefix}PANIO io
where ha.PAN_ID = io.INPUT_PAN_ID
and io.OUTPUT_PAN_ID = pa.PAN_ID
union
select ha.name as household, ha2.*
from apidbtuning.${tblPrefix}Households ha
   , apidbtuning.${tblPrefix}Households ha2
   , apidbtuning.${tblPrefix}Participants pa
   , apidbtuning.${tblPrefix}PANIO io
   , apidbtuning.${tblPrefix}PANIO io2
where pa.pan_id = io2.output_pan_id
and io2.input_pan_id = ha.pan_id
and ha.PAN_ID = io.INPUT_PAN_ID
and io.OUTPUT_PAN_ID = ha2.PAN_ID
";

  my $shinyParticipantsSql = "select pa.name as source_id, ha.name as household, pa.*
from apidbtuning.${tblPrefix}Participants pa
   , apidbtuning.${tblPrefix}Households ha
   , apidbtuning.${tblPrefix}PANIO io
where ha.PAN_ID = io.INPUT_PAN_ID
and io.OUTPUT_PAN_ID = pa.PAN_ID
";


  my $shinyObservationsSql = "select pa.name as source_id, ea.*
from apidbtuning.${tblPrefix}Observations ea
   , apidbtuning.${tblPrefix}Participants pa
   , apidbtuning.${tblPrefix}PANIO io
where pa.PAN_ID = io.INPUT_PAN_ID
and io.OUTPUT_PAN_ID = ea.PAN_ID
union
select pa.name as source_id, ea.*
from apidbtuning.${tblPrefix}Observations ea
   , apidbtuning.${tblPrefix}Observations oa
   , apidbtuning.${tblPrefix}Participants pa
   , apidbtuning.${tblPrefix}PANIO io
   , apidbtuning.${tblPrefix}PANIO io2
where pa.pan_id = io2.input_pan_id
and io2.output_pan_id = oa.pan_id
and oa.PAN_ID = io.INPUT_PAN_ID
and io.OUTPUT_PAN_ID = ea.PAN_ID
union
select pa.name as source_id, ea.pan_id, ea.pan_name as name, '' AS description, ea.pan_type_id, ea.pan_type
from apidbtuning.${tblPrefix}PANRecord ea
   , apidbtuning.${tblPrefix}Participants pa
   , apidbtuning.${tblPrefix}PANIO io
where pa.PAN_ID = io.INPUT_PAN_ID
and io.OUTPUT_PAN_ID = ea.PAN_ID
and ea.pan_name not in (select name from apidbtuning.${tblPrefix}Observations)
"; 

  my $shinySamplesSql = "select ea.pan_name as observation_id, sa.*
from apidbtuning.${tblPrefix}PanRecord ea
   , apidbtuning.${tblPrefix}Samples sa
   , apidbtuning.${tblPrefix}PANIO io
where ea.PAN_ID = io.INPUT_PAN_ID
and io.OUTPUT_PAN_ID = sa.PAN_ID
";

  my $shinyLightTrapSql = "select pa.name as source_id, lt.*
from apidbtuning.${tblPrefix}LightTraps lt
   , apidbtuning.${tblPrefix}Households ha
   , apidbtuning.${tblPrefix}Participants pa
   , apidbtuning.${tblPrefix}PANIO io
   , apidbtuning.${tblPrefix}PANIO io2
where lt.PAN_ID = io.OUTPUT_PAN_ID
and io.INPUT_PAN_ID = ha.PAN_ID
and ha.PAN_ID = io2.INPUT_PAN_ID
and io2.OUTPUT_PAN_ID = pa.PAN_ID
";

my $ontologyMetadataSql = "
select distinct o.ontology_term_source_id as iri
      , o.ontology_term_name as label
      , o.type as type
      , o.parent_ontology_term_name as parentLabel
      , m.category as category
      , o.description as definition
      , ms.min as min
      , ms.max as max
      , ms.average as average
      , ms.upper_quartile as upper_quartile
      , ms.lower_quartile as lower_quartile
      , ms.number_distinct_values as number_distinct_values
      , ms.distinct_values as distinct_values
from apidbtuning.${tblPrefix}Ontology o 
left join apidbtuning.${tblPrefix}Metadata m
  on o.ontology_term_source_id = m.property_source_id
left join apidbtuning.${tblPrefix}MetadataSummary ms
  on o.ontology_term_source_id = ms.property_source_id
where o.ontology_term_source_id is not null
";

  my $participantsFile = "$datasetName/${outputFileBaseName}_participants.txt";
  my $householdsFile = "$datasetName/${outputFileBaseName}_households.txt";
  my $observationsFile = "$datasetName/${outputFileBaseName}_observations.txt";
  my $samplesFile = "$datasetName/${outputFileBaseName}_samples.txt";
  my $lightTrapFile = "$datasetName/${outputFileBaseName}_lightTrap.txt";
  my $outFile = "$datasetName/${outputFileBaseName}_masterDataTable.txt";
  my $ontologyMetadataFile = "$datasetName/ontologyMetadata.txt";
  my $ontologyMappingFile = "$datasetName/ontologyMapping.txt";

  my $workflowDataDir = $self->getWorkflowDataDir();

  if ($undo) {
      $self->runCmd(0, "rm -f $workflowDataDir/$outFile");
  } else {
      if ($test) {
	    $self->runCmd(0,"echo test > $workflowDataDir/shiny_masterDataTable.txt");
      }
      $self->runCmd($test,"makeFileWithSql --outFile $workflowDataDir/$participantsFile --sql \"$shinyParticipantsSql\" --verbose --includeHeader --outDelimiter '\\t'");
      $self->runCmd($test,"makeFileWithSql --outFile $workflowDataDir/$householdsFile --sql \"$shinyHouseholdsSql\" --verbose --includeHeader --outDelimiter '\\t'");
      $self->runCmd($test,"makeFileWithSql --outFile $workflowDataDir/$observationsFile --sql \"$shinyObservationsSql\" --verbose --includeHeader --outDelimiter '\\t'");
      $self->runCmd($test,"makeFileWithSql --outFile $workflowDataDir/$samplesFile --sql \"$shinySamplesSql\" --verbose --includeHeader --outDelimiter '\\t'");
      $self->runCmd($test,"makeFileWithSql --outFile $workflowDataDir/$ontologyMetadataFile --sql \"$ontologyMetadataSql\" --verbose --includeHeader --outDelimiter '\\t'");
      $self->runCmd($test,"makeFileWithSql --outFile $workflowDataDir/$lightTrapFile --sql \"$shinyLightTrapSql\" --verbose --includeHeader --outDelimiter '\\t'");

      my $owl = ApiCommonData::Load::OwlReader->new($owlFile);
      my $it = $owl->execute('get_column_sourceID');
      my %terms;
      while (my $row = $it->next) {
        my $iri = $row->{entity}->as_hash()->{iri}|| $row->{entity}->as_hash()->{URI};
        my $sid = $owl->getSourceIdFromIRI($iri);
        my $dataDictColNames = $row->{vars}->as_hash()->{literal};
        if(ref($dataDictColNames) ne 'ARRAY'){
          $dataDictColNames = [ $dataDictColNames ];
        }
        #consolidate sparql rows with same sid to single entry in $terms
        if(defined($terms{$sid})){
          my %allnames;
          for my $n (@$dataDictColNames){
            $allnames{$n} = 1;
          }
          for my $n (@{ $terms{$sid}->{names} } ){
            $allnames{$n} = 1;
          }
          @$dataDictColNames = sort keys %allnames;
        }
        $terms{$sid} = { 'names' =>  $dataDictColNames };
      }
      open (my $fh, '>', "$workflowDataDir/$ontologyMappingFile") or die "Could not open file for writing! $!";
      print $fh "iri\tvariable\n";
      foreach my $sid (sort keys %terms) {
        my $names = join(",", @{$terms{$sid}->{names}});
        print $fh "$sid\t$names\n";
      }
      close $fh;
 
      #merge all outputFileBaseName* files using Rscript and merge two ontology files
       my $cmd = "Rscript $ENV{GUS_HOME}/bin/mergeClinEpiShinyDatasetFiles.R $workflowDataDir/$datasetName $outputFileBaseName"; 
      $self->runCmd($test, $cmd);
      $self->runCmd($test, "rm -f $workflowDataDir/$participantsFile");
      $self->runCmd($test, "rm -f $workflowDataDir/$householdsFile");
      $self->runCmd($test, "rm -f $workflowDataDir/$observationsFile");
      $self->runCmd($test, "rm -f $workflowDataDir/$samplesFile");
      $self->runCmd($test, "rm -f $workflowDataDir/$ontologyMappingFile");
      $self->runCmd($test, "rm -f $workflowDataDir/$lightTrapFile");
  }
}

1;
