package Mozilla::Mechanize::Browser;

use strict;
use warnings;

use Glib qw(FALSE G_PRIORITY_LOW);
use Gtk2 '-init';
use Mozilla::Mechanize::Browser::Gtk2MozEmbed;


sub new {
    my $pkg = shift;
    my $opts = shift;
    my $debug = delete $opts->{debug};

    my $self = {
        netstopped => 0,
        debug => $debug,
    };
    bless($self, $pkg);

    $self->debug('Browser->new, opts: ' . join(', ', map("$_=$opts->{$_}", keys(%$opts))));

    my $window = Mozilla::Mechanize::Browser::Gtk2MozEmbed->new();
    $window->set_default_size($opts->{width}, $opts->{height});
    $window->iconify() unless $opts->{visible};
    $window->fullscreen() if $opts->{fullscreen};

    # XXX: maybe this isn't necessary (or even working)
    $window->signal_connect(delete_event => sub {
        $self->debug('delete_event signal');

        # XXX: how do you check to make sure that the main loop
        # is actually running before calling main_quit?
        # Something in Glib::MainLoop, maybe.
        Gtk2->main_quit;
        return FALSE;
    });

    my $embed = $window->{embed};
    $self->{embed} = $embed;         # XXX
    $self->{window} = $window;

    $embed->signal_connect(net_start => sub {
        $self->debug('net_start signal');
        $self->{netstopped} = 0;
        FALSE;
    });

    # Any time a new page loads, this adds a "single-shot" idle callback
    # that stops the main loop. Thanks to muppet for the idea.
    $embed->signal_connect(net_stop => sub {
        $self->debug('net_stop signal');
        Glib::Idle->add(sub {
            $self->debug('net_stop Idle, main_quit');
            $self->{netstopped} = 1;

            Gtk2->main_quit;
            FALSE;  # uninstall
        }, undef, G_PRIORITY_LOW);
        FALSE;      # let any other handlers run
    });

    # Start off with a blank page
    $embed->load_url('about:blank');
    $window->show_all();

    $self->debug('Browser->new, main');
    Gtk2->main;   # quits after net_stop event fires

    return $self;
}

sub quit {
    my $self = shift;
    warn "Browser->quit\n" if $self->{debug};

    # XXX: I assume this is right...
    $self->{window}->destroy();
}


sub debug {
    my ($self, $msg) = @_;
    my (undef, $file, $line) = caller();
    print STDERR "$msg at $file line $line\n" if $self->{debug};
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
