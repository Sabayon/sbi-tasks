# run it inside weekly particles and set your own path of essentials

my @particles = <*.particle>;
my $WHERE     = "~/sbi-tasks/next/amd64/essentials";

print "Particles: @particles\n";

foreach my $particle (@particles) {
    my @packs = read_particle_packages($particle);

    my $repo_def = <<'REPO_DEF';
repository:
  description: Essentials
build:
  equo:
    repositories:
      - https://downloads.svc.sabayon.org/namespace/core-staging-amd64/core-amd64
  qa_checks: 0
  emerge:
   # Install each package separately
    split_install: 1
    preserved_rebuild: 1
    default_args: --accept-properties=-interactive -t --quiet --nospinner --oneshot --complete-graph --buildpkg
    features: assume-digests binpkg-logs -userpriv config-protect-if-modified distlocks ebuild-locks fixlafiles merge-sync parallel-fetch preserve-libs protect-owned sandbox sfperms splitdebug strict
  target:
REPO_DEF
    open OUT, ">$WHERE/$particle.yaml";
    print OUT $repo_def;
    print OUT "    - $_\n" for @packs;
    print "SAB_BUILDFILE=$particle.yaml ./sark-localbuild\n";
}
close OUT;

sub read_particle_packages() {
    my $file = shift;
    open FILE, "<$file";
    my @L = <FILE>;
    close FILE;

    my $mark = 0;
    my @p;

    foreach my $line (@L) {
        $mark-- if $line =~ /\:/;
        $mark += 2 if $line =~ /.*packages\:/;
        push( @p, $line ) if $mark == 0 && $line =~ /\//;
    }

    return map { s/,|\s//g; $_ } @p;
}
