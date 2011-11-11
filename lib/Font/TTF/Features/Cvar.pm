package Font::TTF::Features::Cvar;

=head1 NAME

Font::TTF::Features::Size - Class for Character Variants Feature Parameters

=head1 DESCRIPTION

Handles the Feature Parameters valus forCharacter Variants features

=head1 INSTANCE VARIABLES

=over 4

=item INFILE

The read file handle

=item OFFSET

Location of the file in the input file

=item Format

Table format - set to 0

=item UINameID

The 'name' table name ID that specifies a string (or strings, for multiple 
languages) for a user-interface label for this feature

=item TooltipNameID

The 'name' table name ID for tooltip text for the feature

=item SampleTextNameID

The 'name' table name ID for sample text to illustrate the feature

=item NumNamedParms

The number of named parameters

=item FirstNamedParmID

The 'name' table name ID for the first named parameter

=item CharCount

The count of characters for which the feature provides glyph variants

=item Characters

An array holding the unicode values of the characters for which the feature 
provides glyph variants

=back

=head1 METHODS

=cut

use Font::TTF::Utils;
use strict;

=head2 $t->read

Reads the Feature Params

=cut

sub read
{
  my ($self) = @_;
  my ($fh) = $self->{' INFILE'};
  my ($off) = $self->{' OFFSET'};
  my ($dat, $i);
	$fh->seek($off, 0); 
  $fh->read($dat, 14);
  ( $self->{'Format'}
		,$self->{'UINameID'}
		,$self->{'TooltipNameID'}
		,$self->{'SampleTextNameID'}
		,$self->{'NumNamedParm'}
		,$self->{'FirstNamedParmID'}
		,$self->{'CharCount'} ) = TTF_Unpack("S*", $dat);

# Now read the list of characters.  Since these are 24bit insigned integers, need to 
# read add a zero value byte to the front then treat as a 32bit integer

		foreach $i (0 .. $self->{'CharCount'}-1)
		{
			$fh->read($dat,3);
			$dat = pack("C","0") . $dat;
			$self->{'Characters'}->[$i] = TTF_Unpack("L",$dat);
		}
		
    return $self;
}

=head2 $t->out($fh)

Writes the FeatureParams table to the output

=cut



sub out
{
  my ($self, $fh) = @_;
  my $chars = $self->{'Characters'};
  my $numchars = scalar @{$chars};
  my ($dat, $i);
  
  $fh->print(TTF_Pack("S*" 
 		,$self->{'Format'}
		,$self->{'UINameID'}
		,$self->{'TooltipNameID'}
		,$self->{'SampleTextNameID'}
		,$self->{'NumNamedParm'}
		,$self->{'FirstNamedParmID'}
		,$self->{'CharCount'} ));
	
	foreach $i ( 0 .. $numchars-1)
	{
		$dat = substr ( TTF_Pack("L",$chars->[$i]) ,1,3); # Pack as long then remove first byte to get UINT22
		$fh->print($dat);
	}
	
  $self;
}

=head2 Font::TTF::Features::Sset->new()

Creates a new FeatureParams object.
Values for INFILE and OFFSET canbe passed as parameters

=cut

sub new
{
    my ($class,%parms) = @_;
    my ($self) = {};
    my ($p);
    foreach $p (keys %parms)
    { $self->{" $p"} = $parms{$p}; }
    bless $self, $class;
}


=head1 AUTHOR

David Raymond David_Raymond@sil.org. See L<Font::TTF::Font> for copyright and
licensing.

=cut

1;