no warnings qw/redefine/;

use RT::FM::System;
use RT::FM::CustomFieldCollection;
use RT::ACL;

# {{{ This object provides ACLs

use vars qw/$RIGHTS/;
$RIGHTS = {

    SeeClass            => 'See that this class exists', #loc_pair
    CreateArticle       => 'Create articles in this class', #loc_pair
    ShowArticle       => 'See articles in this class', #loc_pair
    ModifyArticle       => 'Modify or delete articles in this class', #loc_pair
    AdminClass          => 'Modify metadata and custom fields for this class', #loc_pair
    ShowACL             => 'Display Access Control List',             # loc_pair
    ModifyACL           => 'Modify Access Control List',              # loc_pair
};

# TODO: This should be refactored out into an RT::ACLedObject or something
# stuff the rights into a hash of rights that can exist.

# Tell RT::ACE that this sort of object can get acls granted
$RT::ACE::OBJECT_TYPES{'RT::FM::Class'} = 1;
 

foreach my $right ( keys %{$RIGHTS} ) {
    $RT::ACE::LOWERCASERIGHTNAMES{ lc $right } = $right;
}


=head2 AvailableRights

Returns a hash of available rights for this object. The keys are the right names and the values are a description of what t
he rights do

=cut

sub AvailableRights {
    my $self = shift;
    return($RIGHTS);
}

# }}}

# {{{ Create

=item Create PARAMHASH

Create takes a hash of values and creates a row in the database:

  varchar(255) 'Name'.
  varchar(255) 'Description'.
  int(11) 'SortOrder'.

=begin testing

use_ok(RT::FM::Class);

my $root = RT::CurrentUser->new('root');
ok ($root->Id, "Loaded root");
my $cl = RT::FM::Class->new($root);
ok (UNIVERSAL::isa($cl, 'RT::FM::Class'), "the new class is a class");

my ($id, $msg) = $cl->Create(Name => 'Test', Description => 'A test class');

ok ($id, $msg);

# no duplicate class names should be allowed
($id, $msg) = $cl->Create(Name => 'Test', Description => 'A test class');

ok (!$id, $msg);

#class name should be required

($id, $msg) = $cl->Create(Name => '', Description => 'A test class');

ok (!$id, $msg);



$cl->Load('Test');
ok($cl->id, "Loaded the class we want");



# Create a new user. make sure they can't create a class

my $u= RT::User->new($RT::SystemUser);
$u->Create(Name => "RTFMTest".time, Privileged => 1);
ok ($u->Id, "Created a new user");

# Make sure you can't create a group with no acls
my $cl = RT::FM::Class->new($u);
ok (UNIVERSAL::isa($cl, 'RT::FM::Class'), "the new class is a class");

my ($id, $msg) = $cl->Create(Name => 'Test-nobody', Description => 'A test class');

ok (!$id, $msg. "- Can not create classes as a random new user");

$u->PrincipalObj->GrantRight(Right =>'AdminClass', Object => $RT::FM::System);
my ($id, $msg) = $cl->Create(Name => 'Test-nobody', Description => 'A test class');

ok ($id, $msg. "- Can create classes as a random new user after ACL grant");


=end testing


=cut


sub Create {
    my $self = shift;
    my %args = ( 
                Name => '',
                Description => '',
                SortOrder => '',
    @_);

    unless ($self->CurrentUser->HasRight(Right => 'AdminClass', Object => $RT::FM::System) ) {
        return(0, $self->loc('Permission Denied'));
    }

    $self->SUPER::Create(
                         Name => $args{'Name'},
                         Description => $args{'Description'},
                         SortOrder => $args{'SortOrder'},
    );

}

sub ValidateName {
    my $self = shift;
    my $newval = shift;

    return undef unless ($newval);
    my $obj = RT::FM::Class->new($RT::SystemUser);
    $obj->Load($newval);
    return undef if ($obj->Id);
    return 1;     

}
# }}}

# {{{ CustomFields

=head2 CustomFields

Returns a CustomFieldCollection of all custom fields related to this article

=begin testing

my ($id,$msg);

my $class = RT::FM::Class->new($RT::SystemUser);
($id,$msg) = $class->Create(Name => 'CFTests');
ok($id, $msg);

ok($class->CustomFields->Count == 0, "The class has no custom fields");
my $cf1 = RT::FM::CustomField->new($RT::SystemUser);
($id, $msg) =$cf1->Create(Name => "ListTest1", Type => "SelectMultiple");
ok ($id, $msg);
ok($cf1->AddToClass($class->Id));
ok($class->CustomFields->Count == 1, "The class has 1 custom field");

my $cf2 = RT::FM::CustomField->new($RT::SystemUser);
($id, $msg) =$cf2->Create(Name => "ListTest2", Type => "SelectMultiple");
ok ($id, $msg);

# We're not going to do global custom fields

#ok($cf2->AddToClass(0));
#ok($class->CustomFields->Count == 2, "The class has 1 custom field and one global custom field");
#ok ($class->CustomFields->HasEntry($cf2->Id), "The class knows that it has the global cf specifically");

ok ($class->CustomFields->HasEntry($cf1->Id), "The class knows that it has the local cf specifically");
ok (!$class->CustomFields->HasEntry(9899), "The class knows that it doesn't have some random cf");

=end testing

=cut


sub CustomFields {
    my $self      = shift;
    
    my $cfs       = RT::FM::CustomFieldCollection->new( $self->CurrentUser );
    my $class_cfs = $cfs->NewAlias('FM_ClassCustomFields');
    $cfs->Join( ALIAS1 => 'main',
                FIELD1 => 'id',
                ALIAS2 => $class_cfs,
                FIELD2 => 'CustomField' );
    $cfs->Limit( ALIAS           => $class_cfs,
                 FIELD           => 'Class',
                 OPERATOR        => '=',
                 VALUE           => $self->Id,
                 ENTRYAGGREGATOR => 'OR' );
    if (0) {
    $cfs->Limit( ALIAS           => $class_cfs,
                 FIELD           => 'Class',
                 OPERATOR        => '=',
                 VALUE           => "0",
                 ENTRYAGGREGATOR => 'OR' );
    }
    return($cfs);                
}
# }}}


# {{{ ACCESS CONTROL

# {{{ sub _Set
sub _Set {
    my $self = shift;

    unless ( $self->CurrentUserHasRight('AdminQueue') ) {
        return ( 0, $self->loc('Permission Denied') );
    }
    return ( $self->SUPER::_Set(@_) );
}

# }}}

# {{{ sub _Value

sub _Value {
    my $self = shift;

    unless ( $self->CurrentUserHasRight('SeeQueue') ) {
        return (undef);
    }

    return ( $self->__Value(@_) );
}

# }}}

sub CurrentUserHasRight {
    my $self = shift;
    my $right = shift;

    return ($self->CurrentUser->HasRight( Right => $right,
                                          Object => $self, 
                                          EquivObjects => [$RT::FM::System] ));

}

1;
