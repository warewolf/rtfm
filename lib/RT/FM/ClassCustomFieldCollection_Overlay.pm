no warnings qw/redefine/;

# {{{ sub HasEntryForClass
          
=item HasEntryForClass CLASS_ID

If this Collection has an entry for the class with the id CLASS_ID returns that entry. Otherwise returns
undef

=cut

sub HasEntryForClass {
    my $self = shift;
    my $id = shift;

    my @items = grep {$_->Class == $id } @{$self->ItemsArrayRef};

    if ($#items > 1) {
    die "$self HasEntry had a list with more than one of $item in it. this can never happen";
    }

    if ($#items == -1 ) {
    return undef;
    }
    else {
    return ($items[0]);
    }  

}
# }}}

# {{{ sub HasEntryForCustomField
          
=item HasEntryForCustomField CustomField_ID

If this Collection has an entry for the CustomField with the id CustomField_ID returns that entry. Otherwise returns
undef

=cut

sub HasEntryForCustomField {
    my $self = shift;
    my $id = shift;

    my @items = grep {$_->CustomField == $id } @{$self->ItemsArrayRef};

    if ($#items > 1) {
    die "$self HasEntry had a list with more than one of $item in it. this can never happen";
    }

    if ($#items == -1 ) {
    return undef;
    }
    else {
    return ($items[0]);
    }  

}

1;
