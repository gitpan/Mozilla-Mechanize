package Mozilla::Mechanize::Browser;

use strict;
use warnings;

use Glib qw(FALSE G_PRIORITY_LOW);
use Gtk2 '-init';
use Mozilla::Mechanize::Browser::Gtk2MozEmbed;


sub new {
    my $pkg = shift;

    my $window = Mozilla::Mechanize::Browser::Gtk2MozEmbed->new();
    $window->set_default_size(600, 400);

    # XXX: maybe this isn't necessary (or even working)
    $window->signal_connect(delete_event => sub {
        # XXX: how do you check to make sure that the main loop
        # is actually running before calling main_quit?
        # Something in Glib::MainLoop, maybe.
        Gtk2->main_quit;
        return FALSE;
    });

    my $embed = $window->{embed};

    my $self = {
        embed => $embed,         # XXX
        window => $window,
        netstopped => 0,
    };
    bless($self, $pkg);

    $embed->signal_connect(net_start => sub {
        $self->{netstopped} = 0;
        FALSE;
    });

    # Any time a new page loads, this adds a "single-shot" idle callback
    # that stops the main loop. Thanks to muppet for the idea.
    $embed->signal_connect(net_stop => sub {
        Glib::Idle->add(sub {
            $self->{netstopped} = 1;

            Gtk2->main_quit;
            FALSE;  # uninstall
        }, undef, G_PRIORITY_LOW);
        FALSE;      # let any other handlers run
    });

    # Start off with a blank page
    $embed->load_url('about:blank');
    $window->show_all();

    Gtk2->main;   # quits after net_stop event fires

    return $self;
}

sub quit {
    my $self = shift;
    # XXX: I assume this is right
    $self->{window}->destroy();
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
