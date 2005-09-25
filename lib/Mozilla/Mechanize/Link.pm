package Mozilla::Mechanize::Link;
use strict;
use warnings;

# $Id: Link.pm,v 1.1.1.1 2005/09/25 00:09:34 slanning Exp $

=head1 NAME Mozilla::Mechanize::Link

Mozilla::Mechanize::Link - Mimic WWW::Mechanize::Link

=head1 SYNOPSIS

sorry, read the source for now

=head1 DESCRIPTION

The C<Mozilla::Mechanize::Link> object is a thin wrapper around
HTML link elements.

=head1 METHODS

=head2 Mozilla::Mechanize::Link->new( $element )

C<$element> is a L<Mozilla::DOM::HTML*Element|Mozilla::DOM::HTML*Element>
object with a C<tagName()> of B<IFRAME>, B<FRAME>, <AREA> or <A>.

B<Note>: Although it supports the same methods as
L<WWW::Mechanize::Link|WWW::Mechanize::Link>, it is a
completely different implementation.

=cut

sub new {
    my ($class, $node) = @_;

    my $iid = 0;

    # turn the Node into the appropriate HTMLElement
    if (lc $node->GetNodeName eq 'a') {
        $iid = Mozilla::DOM::HTMLAnchorElement->GetIID;
    } elsif (lc $node->GetNodeName eq 'frame') {
        $iid = Mozilla::DOM::HTMLFrameElement->GetIID;
    } elsif (lc $node->GetNodeName eq 'iframe') {
        $iid = Mozilla::DOM::HTMLIFrameElement->GetIID;
    } elsif (lc $node->GetNodeName eq 'area') {
        $iid = Mozilla::DOM::HTMLAreaElement->GetIID;
    }
    my $link = $node->QueryInterface($iid);

    my $self = { link => $link };
    bless($self, $class);
}

=head2 $link->url

Returns the url from the link.

=cut

sub url {
    my $self = shift;
    my $link = $self->{link};

    if ($link->GetTagName =~ /^i?frame$/i) {
        return $link->GetSrc;
    } else {
        return $link->GetHref;
    }
}

=head2 $link->text

Text of the link (innerHTML, so includes any HTML markup).

=cut

sub text {
    my $self = shift;
    my $link = $self->{link};

    my $iid = Mozilla::DOM::NSHTMLElement->GetIID;
    my $nshtmlelem = $link->QueryInterface($iid);

    return $nshtmlelem->GetInnerHTML;
}

=head2 $link->name

NAME attribute from the source tag, if any.

=cut

sub name {
    my $self = shift;
    my $link = $self->{link};

    return $link->HasAttribute('name') ? $link->GetName : '';
}

=head2 $link->tag

Tag name ("A", "AREA", "FRAME" or "IFRAME").

=cut

sub tag {
    my $self = shift;
    my $link = $self->{link};

    return $link->GetTagName;
}

=head2 $link->click

B<XXX: to-do
(does this fire onClick?)>

=cut

sub click {
die "Link's click method isn't implemented yet\n";

    my $self = shift;
    my $link = $self->{link};

    # Create the click event
    my $doc = $link->GetOwnerDocument;
    my $deiid = Mozilla::DOM::DocumentEvent->GetIID();
    my $docevent = $doc->QueryInterface($deiid);
    my $event = $docevent->CreateEvent('MouseEvents');
    $event->InitEvent('click', 1, 1);

    # Dispatch the click event
    my $etiid = Mozilla::DOM::EventTarget->GetIID();
    my $target = $link->QueryInterface($etiid);
    $target->DispatchEvent($event);

    # XXX: gah, how do we do _wait_while_busy here?
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
