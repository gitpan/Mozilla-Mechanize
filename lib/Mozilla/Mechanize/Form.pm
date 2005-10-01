package Mozilla::Mechanize::Form;
use strict;
use warnings;

# $Id: Form.pm,v 1.1.1.1 2005/09/25 00:09:34 slanning Exp $

use Mozilla::Mechanize::Input;

=head1 NAME

Mozilla::Mechanize::Form - Mimic L<HTML::Form>

=head1 SYNOPSIS

Read the code for now

=head1 DESCRIPTION

The C<Mozilla::Mechanize::Form> object is a thin wrapper around
L<Mozilla::DOM::HTMLFormElement|Mozilla::DOM::HTMLFormElement>.

=head1 METHODS

=head2 Mozilla::Mechanize::Form->new($form_node, $moz);

Initialize a new object. $form_node is a
L<Mozilla::DOM::HTMLFormElement|Mozilla::DOM::HTMLFormElement>
(or a node that can be QueryInterfaced to one).
$moz is a L<Mozilla::Mechanize|Mozilla::Mechanize> object.
(This latter is a hack for `submit' and `reset',
so that new pages can load in the browser. The GUI has to be
able to enter its main loop. If you don't plan to use those
methods, you don't have to pass it in.)


=cut

sub new {
    my $class = shift;
    my $node = shift;
    my $moz = shift;

    # turn the Node into an HTMLFormElement
    my $iid = Mozilla::DOM::HTMLFormElement->GetIID;
    my $form = $node->QueryInterface($iid);

    my $self = { form => $form };
    $self->{moz} = $moz if defined $moz;
    bless($self, $class);
}

=head2 $form->method( [$new_method] )

Get/Set the I<method> used to submit the from (i.e. B<GET> or
B<POST>).

=cut

sub method {
    my $self = shift;
    my $val = shift;
    my $form = $self->{form};
    $form->SetMethod($val) if defined $val;
    return $form->GetMethod;
}

=head2 $form->action( [$new_action] )

Get/Set the I<action> for submitting the form.

=cut

sub action {
    my $self = shift;
    my $val = shift;
    my $form = $self->{form};
    $form->SetAction($val) if defined $val;
    return $form->GetAction;
}

=head2 $form->enctype( [$new_enctype] )

Get/Set the I<enctype> of the form.

=cut

sub enctype {
    my $self = shift;
    my $val = shift;
    my $form = $self->{form};
    $form->SetEnctype($val) if defined $val;
    return $form->GetEnctype;
}

=head2 $form->name()

Return the name of this form.

=cut

sub name {
    my $self = shift;
    my $val = shift;
    my $form = $self->{form};
    $form->SetName($val) if defined $val;
    return $form->GetName;
}

=head2 $form->attr( $name[, $new_value] )

Get/Set any of the attributes from the FORM-tag
(acceptcharset, action, enctype, method, name, target).

=cut

sub attr {
    my $self = shift;
    return unless @_;
    my $name = shift;
    my $form = $self->{form};

    my $attr = grep $name =~ /^$_$/i, qw(AcceptCharset Action Enctype Method Name Target);
    my $method = "Set$attr";
    $form->$method(shift) if @_;
    $method = "Get$attr";
    return $form->$method;
}

=head2 $form->inputs()

Returns a list of L<Mozilla::Mechanize::Input> objects.
In scalar context it will return the number of inputs.

B<XXX: I'm confused about how radio buttons are implemented.
Win32::IE::Mechanize only pushes on the first one for some reason.
(I push them all for now.)>

=cut

sub inputs {
    my $self = shift;
    my $form = $self->{form};

    my(@inputs, %radio_seen);

    foreach my $tag (qw(input button select textarea)) {
        my $nodelist = $form->GetElementsByTagName($tag);
        for (my $i = 0; $i < $nodelist->GetLength; $i++) {
            my $node = $nodelist->Item($i);
            push @inputs, Mozilla::Mechanize::Input->new($node);
        }
    }

    return wantarray ? @inputs : scalar @inputs;
}

=head2 $form->find_input( $name[, $type[, $index]] )

This method is used to locate specific inputs within the form.  All
inputs that match the arguments given are returned.  In scalar context
only the first is returned, or C<undef> if none match.

If $name is specified, then the input must have the indicated name.

If $type is specified, then the input must have the specified type.
The following type names are used: "text", "password", "hidden",
"textarea", "file", "image", "submit", "radio", "checkbox" and "option".

The $index is the sequence number of the input matched where 1 is the
first.  If combined with $name and/or $type then it select the I<n>th
input with the given name and/or type.

(This method is ported from L<HTML::Form>)

=cut

sub find_input {
    my $self = shift;
    my( $name, $type, $index ) = @_;

    my $form = $self->{form};

    my $typere = qr/.*/;
    # ???
    $type and $typere = $type =~ /^select/i ? qr/^$type/i : qr/^$type$/i;

    if ( wantarray ) {
        my( $cnt, @res ) = ( 0 );
        for my $input ( $self->inputs ) {
            if ( defined $name ) {
                $input->name or next;
                $input->name ne $name and next;
            }
            $input->type =~ $typere or next;
            $cnt++;
            $index && $index ne $cnt and next;
            push @res, $input;
        }
        return @res;
    } else {
        $index ||= 1;
        for my $input ( $self->inputs ) {
            if ( defined $name ) {
                $input->name or next;
                $input->name ne $name and next;
            }
            $input->type =~ $typere or next;
            --$index and next;
            return $input;
        }
        return undef;
    }
}

=head2 $form->value( $name[, $new_value] )

Get/Set the value for the input-control with specified name.

=cut

sub value {
    my $self = shift;
    my $input = $self->find_input( shift );
    return $input->value( @_ );
}

=head2 $form->submit()

Submit this form. (Note: does B<not> trigger onSubmit.)

=cut

sub submit {
    my $self = shift;
    my $form = $self->{form};
    $form->Submit();

    # XXX: if they didn't pass $moz to `new', they're stuck..
    my $moz = $self->{moz} || return;
    $moz->_wait_while_busy();
}

=head2 $form->reset()

Reset inputs to their default values.
(Note: I added this method, though it wasn't in WWW::Mechanize.)

=cut

sub reset {
    my $self = shift;
    my $form = $self->{form};
    $form->Reset();

    # XXX: if they didn't pass $moz to `new', they're stuck..
    my $moz = $self->{moz} || return;
    $moz->_wait_while_busy();
}

=head2 $self->_radio_group( $name )

Equivalent to C<< $self->find_input($name, 'radio') >>.

=cut

sub _radio_group {
    my $self = shift;
    my $form = $self->{form};

    my $name = shift or return;
    my @rgroup;

#     for ( my $i = 0; $i < $form->all->length; $i++ ) {
#         next unless $form->all( $i )->tagName =~ /input/i;
#         next unless $form->all( $i )->type =~ /radio/i;
#         next unless $form->all( $i )->name eq $name;
#         push @rgroup, $form->all( $i );
#     }

    @rgroup = $self->find_input($name, 'radio');

    return wantarray ? @rgroup : \@rgroup;
}


1;

__END__

=head1 COPYRIGHT AND LICENSE

Copyright 2005, Scott Lanning <slanning@cpan.org>. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut
