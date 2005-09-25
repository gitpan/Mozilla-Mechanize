use strict;
use warnings;

#use Module::Build '0.26';
use Module::Build;

#my $subclass = Module::Build->subclass(code => <<'EOF');
#    sub ACTION_distdir {
#        my $self = shift;
#        $self->SUPER::ACTION_distdir(@_);
#        my $metafile = $self->dist_dir . '/META.yml';
#        open(my $out, ">>$metafile") || die "Can't write to $metafile: $!";
#        print $out "no_index:\n  dir:\n  - eg\n";
#        close($out);
#    }
#    sub ACTION_docs {
#        # use `perldoc`
#    }
#EOF

#my $build = $subclass->new(

my $build = Module::Build->new(
    'module_name' => 'Mozilla::Mechanize',
    'dist_author' => 'Scott Lanning <slanning@cpan.org>',
    'license' => 'perl',

    'requires' => {
        'Gtk2::MozEmbed' => '0.04',
        'Mozilla::DOM' => '0.18',    # 0.18 for DocumentRange
        'perl' => '5.8.0',
    },
    'build_requires' => {
        'Test::More' => '0.54',
    },

    'create_makefile_pl' => 'passthrough',
);

$build->create_build_script;
