# BEGIN LICENSE BLOCK
# 
#  Copyright (c) 2002 Jesse Vincent <jesse@bestpractical.com>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of version 2 of the GNU General Public License 
#  as published by the Free Software Foundation.
# 
#  A copy of that license should have arrived with this
#  software, but in any event can be snarfed from www.gnu.org.
# 
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
# END LICENSE BLOCK

# Autogenerated by DBIx::SearchBuilder factory (by <jesse@bestpractical.com>)
# WARNING: THIS FILE IS AUTOGENERATED. ALL CHANGES TO THIS FILE WILL BE LOST.  
# 
# !! DO NOT EDIT THIS FILE !!
#


=head1 NAME

  RT::FM::ClassCollection -- Class Description
 
=head1 SYNOPSIS

  use RT::FM::ClassCollection

=head1 DESCRIPTION


=head1 METHODS

=cut

package RT::FM::ClassCollection;

use RT::FM::SearchBuilder;
use RT::FM::Class;

use base qw(RT::FM::SearchBuilder);


sub _Init {
    my $self = shift;
    $self->{'table'} = 'FM_Classes';
    $self->{'primary_key'} = 'id';



  # By default, order by name
  $self->OrderBy( ALIAS => 'main',
                  FIELD => 'SortOrder',
                  ORDER => 'ASC');

    return ( $self->SUPER::_Init(@_) );
}


=item NewItem

Returns an empty new RT::FM::Class item

=cut

sub NewItem {
    my $self = shift;
    return(RT::FM::Class->new($self->CurrentUser));
}

        eval "require RT::FM::ClassCollection_Overlay";
        if ($@ && $@ !~ /^Can't locate/) {
            die $@;
        };

        eval "require RT::FM::ClassCollection_Local";
        if ($@ && $@ !~ /^Can't locate/) {
            die $@;
        };




=head1 SEE ALSO

This class allows "overlay" methods to be placed
into the following files _Overlay is for a System overlay by the original author,
while _Local is for site-local customizations.  

These overlay files can contain new subs or subs to replace existing subs in this module.

If you'll be working with perl 5.6.0 or greater, each of these files should begin with the line 

   no warnings qw(redefine);

so that perl does not kick and scream when you redefine a subroutine or variable in your overlay.

RT::FM::ClassCollection_Overlay, RT::FM::ClassCollection_Local

=cut


1;